//
//  AKAPredicatePropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 29.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <objc/runtime.h>

#import "AKABinding_Protected.h"
#import "AKABinding+BindingOwner.h"
#import "AKABinding+SubclassObservationEvents.h"

#import "AKAPredicatePropertyBinding.h"
#import "AKABindingErrors.h"
@interface AKAPredicatePropertyBinding()

@property(nonatomic, readonly) NSMutableDictionary* substitutionValues;
@property(nonatomic, readonly) id predicateSource;
@property(nonatomic, readonly) NSPredicate* predicate;

@property(nonatomic) NSMutableDictionary<NSString*, AKAPropertyBinding*>* propertyBindingsByDynamicSubstitutionVariables;
@property(nonatomic) NSMutableDictionary<NSString*, NSString*>* dynamicSubstitutionVariablesByKeyPath;
@property(nonatomic) BOOL bindingPropertiesAreObservingChanges;
@property(nonatomic) BOOL isRewritingExpressions;

@end


@implementation AKAPredicatePropertyBinding

+ (AKABindingSpecification*)                         specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":                  [AKAPredicatePropertyBinding class],
           @"targetType":                   [AKAProperty class],
           @"expressionType":               @((AKABindingExpressionTypeStringConstant |
                                               AKABindingExpressionTypeAnyKeyPath |
                                               AKABindingExpressionTypeBooleanConstant |
                                               AKABindingExpressionTypeClassConstant)),
           @"allowUnspecifiedAttributes":   @YES
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    
    return result;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _substitutionValues = [NSMutableDictionary new];
        _predicateSource = nil;
        _predicate = nil;
    }
    return self;
}

- (void)substitutionValue:(id)oldValue didChangeTo:(id)newValue
{
    (void)oldValue;
    (void)newValue;
    [self updateTargetValue];
}

- (BOOL)initializeUnspecifiedAttribute:(NSString *)attributeName
                   attributeExpression:(req_AKABindingExpression)attributeExpression
                                 error:(out_NSError)error
{
    BOOL result;

    id<AKABindingContextProtocol> bindingContext = self.bindingContext;
    NSAssert(bindingContext != nil, @"Binding context released or undefined");

    __weak typeof(self) weakSelf = self;

    AKAProperty* targetProperty = [AKAProperty propertyOfWeakKeyValueTarget:self.substitutionValues
                                                                    keyPath:attributeName
                                                             changeObserver:
                                   ^(id  _Nullable oldValue, id  _Nullable newValue)
                                   {
                                       if (self.bindingPropertiesAreObservingChanges)
                                       {
                                           // Only process substitution value changes if all binding properties are already in observing state.
                                           [weakSelf substitutionValue:oldValue didChangeTo:newValue];
                                       }
                                   }];
    AKABinding *attributeBinding = [AKAPropertyBinding bindingToTarget:self.substitutionValues
                                                   targetValueProperty:targetProperty
                                                        withExpression:attributeExpression
                                                               context:bindingContext
                                                                 owner:self
                                                              delegate:nil
                                                                 error:error];
    result = attributeBinding != nil;
    if (result)
    {
        [self addBindingPropertyBinding:attributeBinding];
    }
    return result;
}


- (BOOL)convertSourceValue:(id)sourceValue
             toTargetValue:(out_id)targetValueStore
                     error:(out_NSError)error
{
    BOOL result = YES;
    BOOL isConstant = NO;
    BOOL predicateMayNeedExpressionRewriting = NO;

    if (self.predicateSource != sourceValue)
    {
        [self removeDynamicSubstitutionVariablePropertyBindings];

        if ([sourceValue isKindOfClass:[NSString class]])
        {
            // A string source value is used as format string for a predicate.
            _predicateSource = sourceValue;
            if (error)
            {
                // If errors are handled by caller, we catch exceptions to provide error information. Exceptions thrown by NSPredicate are not documented
                @try
                {
                    _predicate = [NSPredicate predicateWithFormat:sourceValue];
                    predicateMayNeedExpressionRewriting = YES;
                }
                @catch (NSException *exception)
                {
                    result = NO;
                    *error = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                    sourceValuePredicateFormat:sourceValue
                                                           failedWithException:exception];
                }
            }
            else
            {
                // If error store is nil, let exceptions pass through
                _predicate = [NSPredicate predicateWithFormat:sourceValue];
            }
        }
        else if ([sourceValue isKindOfClass:[NSPredicate class]])
        {
            _predicateSource = sourceValue;
            _predicate = sourceValue;
            predicateMayNeedExpressionRewriting = YES;
        }
        else if ([sourceValue isKindOfClass:[NSNumber class]])
        {
            isConstant = YES;
            _predicateSource = sourceValue;
            _predicate = [NSPredicate predicateWithValue:[sourceValue boolValue]];
        }
        else if (class_isMetaClass(object_getClass(sourceValue)))
        {
            isConstant = YES;
            _predicateSource = sourceValue;
            _predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                (void)bindings;
                return [evaluatedObject isKindOfClass:(Class)sourceValue];
            }];
        }
        else if (sourceValue != nil)
        {
            result = NO;
            NSError* localError = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                                        sourceValue:sourceValue
                                                      failedWithInvalidTypeExpectedTypes:@[ [NSString class] ]];
            AKARegisterErrorInErrorStore(localError, error);
        }
    }

    if (result)
    {
        __weak typeof(self) weakSelf = self;

        if (predicateMayNeedExpressionRewriting)
        {
            _predicate = [self rewriteKeyPathExpressionsInPredicate:_predicate
                                                              error:error];
        }

        if (isConstant)
        {
            *targetValueStore = _predicate;
        }
        else
        {
            *targetValueStore = [NSPredicate predicateWithBlock:
                                 ^BOOL(id  _Nonnull evaluatedObject,
                                       NSDictionary<NSString *,id> * _Nullable bindings)
                                 {
                                     BOOL presult = NO;
                                     typeof(self)strongSelf = weakSelf;
                                     NSPredicate* predicate = strongSelf.predicate;
                                     if (predicate)
                                     {
                                         NSDictionary<NSString *,id>* effectiveBindings;
                                         if (bindings.count > 0 && strongSelf.substitutionValues.count > 0)
                                         {
                                             effectiveBindings = [NSMutableDictionary dictionaryWithDictionary:strongSelf.substitutionValues];
                                             [(NSMutableDictionary*)effectiveBindings addEntriesFromDictionary:bindings];
                                         }
                                         else
                                         {
                                             effectiveBindings = bindings.count > 0 ? bindings : strongSelf.substitutionValues;

                                         }
                                         presult = [predicate evaluateWithObject:evaluatedObject
                                                           substitutionVariables:effectiveBindings];
                                     }
                                     return presult;
                                 }];
            /* TODO: remove if dynamic subst variable bindings should really be started when adding them
            if (predicateMayNeedExpressionRewriting &&
                self.bindingPropertiesAreObservingChanges &&
                self.propertyBindingsByDynamicSubstitutionVariables.count > 0)
            {
                for (AKAPropertyBinding* binding in self.propertyBindingsByDynamicSubstitutionVariables.allValues)
                {
                    [binding startObservingChanges];
                }
            }
             */
        }
    }

    return result;
}


- (NSString*)addDynamicSubstitutionVariableForRewrittenExpressionWithKeyPath:(req_NSString)keyPath
                                                                       error:(out_NSError)error
{
    NSString* variableName = self.dynamicSubstitutionVariablesByKeyPath[keyPath];
    if (variableName == nil)
    {
        // Assumption: dynamic variables are only added to and possibly removed all together. So we can use the count as variable name.
        variableName = [NSString stringWithFormat:@"kp_%lu", self.dynamicSubstitutionVariablesByKeyPath.count + 1];
        NSAssert(self.substitutionValues[variableName] == nil,
                 @"%@.substitutionVariables[%@] already defined: %@", self, variableName, self.substitutionValues[variableName]);
        [self.substitutionValues setValue:[NSNull null] forKey:variableName];
    }

    BOOL result = (self.propertyBindingsByDynamicSubstitutionVariables[variableName] != nil);

    if (!result)
    {
        id<AKABindingContextProtocol> bindingContext = self.bindingContext;
        NSAssert(bindingContext != nil, @"Binding context released or undefined");

        __weak typeof(self) weakSelf = self;

        NSAssert(self.substitutionValues != nil, @"Substitution values undefined");
        AKAProperty* targetProperty = [AKAProperty propertyOfWeakTarget:self.substitutionValues
                                                                 getter:^id _Nullable(id  _Nonnull target) {
                                                                     NSMutableDictionary* values = target;

                                                                     id result = values[variableName];
                                                                     if (result == [NSNull null])
                                                                     {
                                                                         result = nil;
                                                                     }

                                                                     return result;
                                                                 }
                                                                 setter:^(id  _Nonnull target, id  _Nullable value) {
                                                                     NSMutableDictionary* values = target;

                                                                     id oldValue = values[variableName];
                                                                     if (oldValue == [NSNull null])
                                                                     {
                                                                         oldValue = nil;
                                                                     }

                                                                     id newValue = value ? value : [NSNull null];
                                                                     values[variableName] = newValue;

                                                                     __strong AKAPredicatePropertyBinding* strongSelf = weakSelf;
                                                                     if (strongSelf.bindingPropertiesAreObservingChanges && !strongSelf.isRewritingExpressions)
                                                                     {
                                                                         [strongSelf substitutionValue:oldValue didChangeTo:newValue];
                                                                     }
                                                                 }];

        AKABindingExpression* keyPathExpression =
        [AKABindingExpression bindingExpressionWithString:keyPath
                                              bindingType:[AKABinding class]
                                                    error:error];
        result = keyPathExpression != nil;

        AKAPropertyBinding *binding = nil;
        if (result)
        {
            binding = (id)[AKAPropertyBinding bindingToTarget:self.substitutionValues
                                          targetValueProperty:targetProperty
                                               withExpression:keyPathExpression
                                                      context:bindingContext
                                                        owner:self
                                                     delegate:nil
                                                        error:error];
        }
        result = binding != nil;

        if (result)
        {
            if (self.dynamicSubstitutionVariablesByKeyPath == nil)
            {
                self.dynamicSubstitutionVariablesByKeyPath = [NSMutableDictionary new];
            }
            self.dynamicSubstitutionVariablesByKeyPath[keyPath] = variableName;

            if (!self.propertyBindingsByDynamicSubstitutionVariables)
            {
                self.propertyBindingsByDynamicSubstitutionVariables = [NSMutableDictionary new];
            }
            self.propertyBindingsByDynamicSubstitutionVariables[variableName] = binding;

            [self addBindingPropertyBinding:binding];
            if (self.bindingPropertiesAreObservingChanges)
            {
                [binding startObservingChanges];
            }
        }
    }

    return result ? variableName : nil;
}

- (void)removeDynamicSubstitutionVariablePropertyBindings
{
    for (AKAPropertyBinding* propertyBinding in self.propertyBindingsByDynamicSubstitutionVariables.allValues)
    {
        [self removeBindingPropertyBinding:propertyBinding];
    }
    for (NSString* variableName in self.dynamicSubstitutionVariablesByKeyPath.allValues)
    {
        [self.substitutionValues removeObjectForKey:variableName];
    }

    self.propertyBindingsByDynamicSubstitutionVariables = nil;
    self.dynamicSubstitutionVariablesByKeyPath = nil;
}

- (NSPredicate*)rewriteKeyPathExpressionsInPredicate:(NSPredicate*)predicate
                                               error:(out_NSError)error
{
    BOOL wasRewritingExpressions = self.isRewritingExpressions;
    self.isRewritingExpressions = YES;
    NSPredicate* result = [self mapExpressionsInPredicate:predicate
                                usingBlock:
            ^NSExpression*_Nonnull(NSExpression*_Nonnull expression)
            {
                NSExpression* blockResult;

                switch (expression.expressionType)
                {
                    case NSKeyPathExpressionType:
                    {
                        NSString* keyPath = expression.keyPath;
                        NSString* variableName =
                            [self addDynamicSubstitutionVariableForRewrittenExpressionWithKeyPath:keyPath
                                                                                            error:error];
                        blockResult = variableName.length > 0 ? [NSExpression expressionForVariable:variableName] : nil;

                        break;
                    }

                    default:
                        blockResult = expression;
                        break;
                }

                return blockResult;
            }];
    if (!wasRewritingExpressions)
    {
        self.isRewritingExpressions = NO;
    }
    return result;
}


- (NSExpression*)rewriteExpressionTree:(NSExpression*)expression
                            usingBlock:(NSExpression*_Nonnull(^_Nonnull)(NSExpression*_Nonnull expression))block
{
    NSExpression* result;

    switch (expression.expressionType)
    {
        case NSConstantValueExpressionType:
        case NSEvaluatedObjectExpressionType:
        case NSKeyPathExpressionType:
        case NSVariableExpressionType:
        case NSAnyKeyExpressionType:
            result = expression;
            break;

        case NSBlockExpressionType:
            result = expression;
            break;

        case NSAggregateExpressionType:
            // collection
            result = expression;
            break;

        case NSUnionSetExpressionType:
        case NSIntersectSetExpressionType:
        case NSMinusSetExpressionType:
            // set and collection
            result = expression;
            break;

        case NSSubqueryExpressionType:
            // collection, predicate, variable name
            result = expression;
            break;

        case NSFunctionExpressionType:
            // arguments
            result = expression;
            break;

        case NSConditionalExpressionType:
            result = expression;
            break;

        default:
            result = expression;
            break;
    }

    result = block(result);

    return result;
}

- (NSPredicate*)mapExpressionsInPredicate:(nonnull NSPredicate*)predicate
                               usingBlock:(NSExpression*_Nonnull(^_Nonnull)(NSExpression*_Nonnull expression))block
{
    NSPredicate* result = predicate;

    if ([predicate isKindOfClass:[NSComparisonPredicate class]])
    {
        NSComparisonPredicate* comparisonPredicate = (NSComparisonPredicate*)predicate;

        NSExpression* leftExpression = block(comparisonPredicate.leftExpression);
        NSExpression* rightExpression = block(comparisonPredicate.rightExpression);

        if (leftExpression  != comparisonPredicate.leftExpression ||
            rightExpression != comparisonPredicate.rightExpression)
        {
            switch (comparisonPredicate.predicateOperatorType)
            {
                case NSBeginsWithPredicateOperatorType:
                case NSBetweenPredicateOperatorType:
                case NSContainsPredicateOperatorType:
                case NSEndsWithPredicateOperatorType:
                case NSEqualToPredicateOperatorType:
                case NSGreaterThanOrEqualToPredicateOperatorType:
                case NSGreaterThanPredicateOperatorType:
                case NSInPredicateOperatorType:
                case NSLessThanOrEqualToPredicateOperatorType:
                case NSLessThanPredicateOperatorType:
                case NSLikePredicateOperatorType:
                case NSMatchesPredicateOperatorType:
                case NSNotEqualToPredicateOperatorType:
                    comparisonPredicate = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                             rightExpression:rightExpression
                                                                                    modifier:comparisonPredicate.comparisonPredicateModifier
                                                                                        type:comparisonPredicate.predicateOperatorType
                                                                                     options:comparisonPredicate.options];
                    break;

                case NSCustomSelectorPredicateOperatorType:
                    NSAssert(comparisonPredicate.customSelector != NULL, nil);
                    comparisonPredicate = [NSComparisonPredicate predicateWithLeftExpression:leftExpression
                                                                             rightExpression:rightExpression
                                                                              customSelector:(SEL _Nonnull)comparisonPredicate.customSelector];
                    break;

                default:
                    NSAssert(NO, @"Unknown comparison predicate operator type");
                    break;
            }
        }

        result = comparisonPredicate;
    }
    else if ([predicate isKindOfClass:[NSCompoundPredicate class]])
    {
        NSCompoundPredicate* compoundPredicate = (NSCompoundPredicate*)predicate;

        NSMutableArray<NSPredicate*>* subPredicates = nil;
        NSUInteger index = 0;
        for (NSPredicate* subPredicate in compoundPredicate.subpredicates)
        {
            NSPredicate* mappedSubPredicate = [self mapExpressionsInPredicate:subPredicate
                                                                   usingBlock:block];
            if (mappedSubPredicate != subPredicate)
            {
                if (subPredicates == nil)
                {
                    subPredicates = [NSMutableArray arrayWithArray:compoundPredicate.subpredicates];
                }
                subPredicates[index]  = mappedSubPredicate;
            }
            ++index;
        }

        if (subPredicates)
        {
            switch (compoundPredicate.compoundPredicateType)
            {
                case NSAndPredicateType:
                    compoundPredicate = [compoundPredicate.class andPredicateWithSubpredicates:subPredicates];
                    break;

                case NSOrPredicateType:
                    compoundPredicate = [compoundPredicate.class orPredicateWithSubpredicates:subPredicates];
                    break;

                case NSNotPredicateType:
                    NSAssert(subPredicates.count == 1, nil);
                    compoundPredicate = [NSCompoundPredicate notPredicateWithSubpredicate:(NSPredicate*_Nonnull)subPredicates.firstObject];

                default:
                    NSAssert(NO, @"Unknown compund predicate type");
                    break;
            }
        }
        
        result = compoundPredicate;
    }
    else
    {
        result = predicate;
    }

    return result;
}

- (void)didStartObservingBindingPropertyBindings
{
    [super didStartObservingBindingPropertyBindings];
    self.bindingPropertiesAreObservingChanges = YES;
}

- (void)willStopObservingBindingPropertyBindings
{
    [super willStopObservingBindingPropertyBindings];
    self.bindingPropertiesAreObservingChanges = NO;
}

@end
