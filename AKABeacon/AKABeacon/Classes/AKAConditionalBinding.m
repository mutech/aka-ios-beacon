//
//  AKAConditionalBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 10.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAConditionalBinding.h"
#import "AKABinding_Protected.h"
#import "AKAPredicatePropertyBinding.h"

@interface AKAConditionalBindingClause()

@property(nonatomic) NSUInteger                     expressionClauseIndex;
@property(nonatomic) NSPredicate*                   predicate;

@property(nonatomic) AKAPredicatePropertyBinding*   predicateBinding;
@property(nonatomic) AKABinding*                    binding;

@end


@implementation AKAConditionalBindingClause
@end


@interface AKAConditionalBinding()

@property(nonatomic) NSMutableArray*                clauses;
@property(nonatomic) AKAConditionalBindingClause*   activeClause;
@property(nonatomic) AKAProperty*                   effectiveBindingTarget;
@property(nonatomic) BOOL                           isObservingChanges;

@end


@implementation AKAConditionalBinding

+ (AKABindingSpecification*)                         specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        NSDictionary* spec =
        @{ @"bindingType":                  [AKAConditionalBinding class],
           @"expressionType":               @(AKABindingExpressionTypeConditional),
           @"allowUnspecifiedAttributes":   @YES
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

- (void)predicateForClause:(AKAConditionalBindingClause*)clause
                   atIndex:(NSUInteger)index
               changedFrom:(NSPredicate*__unused)oldPredicate
                        to:(NSPredicate*)newPredicate
{
    if (self.activeClause && index <= self.activeClause.expressionClauseIndex)
    {
        if ([newPredicate evaluateWithObject:self.bindingSource.value])
        {
            self.activeClause = clause;
        }
        else
        {
            for (NSUInteger i = index + 1; i < self.clauses.count; ++i)
            {
                AKAConditionalBindingClause* nextClause = self.clauses[i];
                if ([nextClause.predicate evaluateWithObject:self.bindingSource.value])
                {
                    self.activeClause = nextClause;
                    break;
                }
            }
        }
    }
}

- (opt_instancetype)initWithTarget:(id)targetObjectOrProperty
              resultBindingFactory:(opt_AKABinding(^_Nonnull)(req_id,
                                                              req_AKABindingExpression,
                                                              req_AKABindingContext,
                                                              opt_AKABindingDelegate,
                                                              out_NSError))resultBindingFactory
                 resultBindingType:(Class)resultBindingType
                        expression:(req_AKABindingExpression)bindingExpression
                           context:(req_AKABindingContext)bindingContext
                          delegate:(opt_AKABindingDelegate)delegate
                             error:(out_NSError)error
{
    // The outer binding target is this instances actieClause property.
    AKAProperty* conditionBindingTarget = [AKAProperty propertyOfWeakTarget:self
                                                                     getter:^id _Nullable(id  _Nonnull target) {
                                                                         return ((AKAConditionalBinding*)target).activeClause;
                                                                     }
                                                                     setter:^(id  _Nonnull target, id  _Nullable value) {
                                                                         ((AKAConditionalBinding*)target).activeClause = value;
                                                                     }
                                                         observationStarter:nil
                                                         observationStopper:nil];
    if (self = [super initWithTarget:conditionBindingTarget
                          expression:bindingExpression
                             context:bindingContext
                            delegate:delegate
                               error:error])
    {
        NSAssert([bindingExpression isKindOfClass:[AKAConditionalBindingExpression class]], @"AKAConditionalBinding expects a conditional binding expression");
        AKAConditionalBindingExpression* conditionalExpression = (id)bindingExpression;

        // Initializes binding clauses

        NSMutableArray<AKAConditionalBindingClause*>* clauses = [NSMutableArray new];
        [conditionalExpression.clauses enumerateObjectsUsingBlock:
         ^(AKAConditionalBindingExpressionClause * _Nonnull expressionClause,
           NSUInteger index,
           BOOL * _Nonnull stop)
         {
             AKAConditionalBindingClause* clause = [AKAConditionalBindingClause new];
             clause.expressionClauseIndex = index;

             AKABindingExpression* predicateExpression = expressionClause.conditionBindingExpression;
             if (predicateExpression == nil)
             {
                 clause.predicate = [NSPredicate predicateWithValue:YES];
                 *stop = YES;
             }
             else
             {
                 __weak typeof(self) weakSelf = self;
                 AKAProperty* targetPredicateProperty =
                 [AKAProperty propertyOfWeakKeyValueTarget:clause
                                                   keyPath:@"predicate"
                                            changeObserver:
                  ^(id  _Nullable oldValue, id  _Nullable newValue)
                  {
                      [weakSelf predicateForClause:clause
                                           atIndex:index
                                       changedFrom:oldValue
                                                to:newValue];
                  }];

                 clause.predicateBinding =
                 [[AKAPredicatePropertyBinding alloc] initWithTarget:targetPredicateProperty
                                                          expression:(req_AKABindingExpression)expressionClause.conditionBindingExpression
                                                             context:bindingContext
                                                            delegate:delegate
                                                               error:error];
             }

             AKABindingExpression* resultExpression = expressionClause.resultBindingExpression;
             clause.binding = resultBindingFactory(targetObjectOrProperty,
                                                   resultExpression,
                                                   bindingContext,
                                                   delegate,
                                                   error);

             [clauses addObject:clause];
         }];
        _clauses = clauses;
    }

    return self;
}

- (BOOL)validateBindingTypeWithExpression:(opt_AKABindingExpression)bindingExpression
                                    error:(out_NSError)error
{
    BOOL result = YES;

    if ([bindingExpression isKindOfClass:[AKAConditionalBindingExpression class]])
    {
        // TODO: see if we can do some reasonable validation in place of specified binding type validation.
    }
    else
    {
        result = [super validateBindingTypeWithExpression:bindingExpression error:error];
    }

    return result;
}

- (AKAProperty *)bindingSourceForExpression:(AKABindingExpression *__unused)bindingExpression
                                    context:(req_AKABindingContext)bindingContext
                             changeObserver:(AKAPropertyChangeObserver)changeObserver
                                      error:(out_NSError __unused)error
{
    AKAProperty* result = [bindingContext dataContextPropertyForKeyPath:nil
                                                     withChangeObserver:changeObserver];
    return result;
}

- (void)setActiveClause:(AKAConditionalBindingClause *)activeClause
{
    if (activeClause != _activeClause)
    {
        if (_activeClause)
        {
            [_activeClause.binding stopObservingChanges];
        }

        _activeClause = activeClause;

        if (activeClause && self.isObservingChanges)
        {
            [activeClause.binding startObservingChanges];
        }
    }
}

- (BOOL)convertSourceValue:(id)sourceValue
             toTargetValue:(id  _Nullable __autoreleasing *)targetValueStore
                     error:(NSError *__autoreleasing  _Nullable * __unused)error
{
    BOOL result = YES;

    AKAConditionalBindingClause* targetValue = nil;

    for (AKAConditionalBindingClause* clause in self.clauses)
    {
        if ([clause.predicate evaluateWithObject:sourceValue])
        {
            targetValue = clause;
            break;
        }
    }

    if (targetValueStore)
    {
        *targetValueStore = targetValue;
    }

    return result;
}

- (void)willStartObservingChanges
{
    self.isObservingChanges = YES;
    [super willStartObservingChanges];
}

- (void)willStartObservingBindingSource
{
    for (AKAConditionalBindingClause* clause in self.clauses)
    {
        [clause.predicateBinding startObservingChanges];
    }
    [super willStartObservingBindingSource];
}

- (void)didStopObservingBindingSource
{
    for (AKAConditionalBindingClause* clause in self.clauses)
    {
        [clause.predicateBinding stopObservingChanges];
    }
    self.activeClause = nil;
    [super didStopObservingBindingSource];
}

- (void)didStopObservingChanges
{
    self.isObservingChanges = NO;
    [super didStopObservingChanges];
}

@end
