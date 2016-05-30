//
//  AKAPredicatePropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 29.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <objc/runtime.h>

#import "AKABinding_Protected.h"
#import "AKABinding+SubBindings.h"

#import "AKAPredicatePropertyBinding.h"
#import "AKABindingErrors.h"

@interface AKAPredicatePropertyBinding()

@property(nonatomic, readonly) NSMutableDictionary<NSString*, id>* substitutionValues;
@property(nonatomic, readonly) id predicateSource;
@property(nonatomic, readonly) NSPredicate* predicate;

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
    __weak typeof(self) weakSelf = self;

    AKAProperty* targetProperty = [AKAProperty propertyOfWeakKeyValueTarget:self.substitutionValues
                                                                    keyPath:attributeName
                                                             changeObserver:
                                   ^(id  _Nullable oldValue, id  _Nullable newValue)
                                   {
                                       [weakSelf substitutionValue:oldValue didChangeTo:newValue];
                                   }];
    AKABinding *attributeBinding = [AKAPropertyBinding bindingToTarget:self.substitutionValues
                                                   targetValueProperty:targetProperty
                                                        withExpression:attributeExpression
                                                               context:self.bindingContext
                                                              delegate:weakSelf error:error];
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

    if (self.predicateSource != sourceValue)
    {
        if ([sourceValue isKindOfClass:[NSString class]])
        {
            _predicateSource = sourceValue;
            if (error)
            {
                // If errors are handled by caller, we catch exceptions to provide error information. Exceptions thrown by NSPredicate are not documented
                @try
                {
                    _predicate = [NSPredicate predicateWithFormat:sourceValue];
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
                _predicate = [NSPredicate predicateWithFormat:sourceValue];
            }
        }
        else if ([sourceValue isKindOfClass:[NSPredicate class]])
        {
            _predicateSource = sourceValue;
            _predicate = sourceValue;
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
                                         NSDictionary<NSString *,id>* effectiveBindings =
                                         bindings ? bindings : strongSelf.substitutionValues;
                                         presult = [predicate evaluateWithObject:evaluatedObject
                                                           substitutionVariables:effectiveBindings];
                                     }
                                     return presult;
                                 }];
        }
    }
    
    return result;
}

@end
