//
//  AKAConditionalBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 10.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

#import "AKAConditionalBinding.h"
#import "AKABinding_Protected.h"
#import "AKABinding+SubclassInitialization.h"
#import "AKABinding+BindingOwner.h"
#import "AKABinding+SubclassObservationEvents.h"
#import "AKAErrors.h"
#import "AKAPredicatePropertyBinding.h"


#pragma mark - AKAConditionalBindingClause Interface
#pragma mark -

@interface AKAConditionalBindingClause ()

@property(nonatomic) NSUInteger expressionClauseIndex;
@property(nonatomic) NSPredicate*                   predicate;

@property(nonatomic) AKAPredicatePropertyBinding*   predicateBinding;
@property(nonatomic) AKABinding*                    binding;

@end

@implementation AKAConditionalBindingClause
@end


#pragma mark - AKAConditionalBinding Private Interface
#pragma mark -

@interface AKAConditionalBinding ()

@property(nonatomic) NSMutableArray*                clauses;
@property(nonatomic) AKAConditionalBindingClause*   activeClause;
@property(nonatomic) AKAProperty*                   effectiveBindingTarget;
@property(nonatomic) BOOL isObservingChanges;

@end


#pragma mark - AKAConditionalBinding Implementation
#pragma mark -

@implementation AKAConditionalBinding

+ (AKABindingSpecification*) specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
            @{ @"bindingType":                  [AKAConditionalBinding class],
               @"expressionType":               @(AKABindingExpressionTypeConditional),
               @"allowUnspecifiedAttributes":   @YES };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

#pragma mark - Initialization

- (opt_instancetype)        initWithTarget:(id)target
                         resultBindingType:(Class)resultBindingType
                                expression:(req_AKABindingExpression)bindingExpression
                                   context:(req_AKABindingContext)bindingContext
                                     owner:(opt_AKABindingOwner)owner
                                  delegate:(opt_AKABindingDelegate)delegate
                                     error:(out_NSError)error
{
    self = [self initWithTarget:target targetValueProperty:nil
           resultBindingFactory:^AKABinding *(id rTarget,
                                              AKAProperty*              rTargetValueProperty __unused,
                                              req_AKABindingExpression  rExpression,
                                              req_AKABindingContext     rContext,
                                              opt_AKABindingOwner       rOwner,
                                              id <AKABindingDelegate>   rDelegate,
                                              out_NSError               rError)
            {
               NSParameterAssert(rTargetValueProperty == nil);

               AKABinding *resultBinding = [resultBindingType alloc];
               return [resultBinding initWithTarget:rTarget
                                         expression:rExpression
                                            context:rContext
                                              owner:rOwner
                                           delegate:rDelegate
                                              error:rError];
           }
                     expression:bindingExpression
                        context:bindingContext
                          owner:owner
                       delegate:delegate
                          error:error];

    return self;
}

- (opt_instancetype)        initWithTarget:(opt_id)target
                       targetValueProperty:(req_AKAProperty)targetValueProperty
                         resultBindingType:(req_Class)resultBindingType
                                expression:(req_AKABindingExpression)bindingExpression
                                   context:(req_AKABindingContext)bindingContext
                                     owner:(opt_AKABindingOwner)owner
                                  delegate:(opt_AKABindingDelegate)delegate
                                     error:(out_NSError)error
{
    self = [self initWithTarget:target
            targetValueProperty:targetValueProperty
           resultBindingFactory:
                   ^AKABinding *(id                      rTarget,
                                 AKAProperty*            rTargetValueProperty,
                                 AKABindingExpression*   rExpression,
                                 req_AKABindingContext   rContext,
                                 opt_AKABindingOwner     rOwner,
                                 id <AKABindingDelegate> rDelegate,
                                 out_NSError             rError)
                   {
                       AKABinding *resultBinding = [resultBindingType alloc];
                       return [resultBinding initWithTarget:rTarget
                                        targetValueProperty:rTargetValueProperty
                                                 expression:rExpression
                                                    context:rContext
                                                      owner:rOwner
                                                   delegate:rDelegate
                                                      error:rError];
                   }
            expression:bindingExpression
                        context:bindingContext
                          owner:owner
                       delegate:delegate
                          error:error];

    return self;
}

- (opt_instancetype)initWithTarget:(opt_id)target
               targetValueProperty:(opt_AKAProperty)targetValueProperty
              resultBindingFactory:(opt_AKABinding (^ _Nonnull)(opt_id target,
                                                                opt_AKAProperty targetValueProperty,
                                                                req_AKABindingExpression bindingExpression,
                                                                req_AKABindingContext bindingContext,
                                                                opt_AKABindingOwner owner,
                                                                opt_AKABindingDelegate delegate,
                                                                out_NSError error))resultBindingFactory
                        expression:(req_AKABindingExpression)bindingExpression
                           context:(req_AKABindingContext)bindingContext
                             owner:(opt_AKABindingOwner)owner
                          delegate:(opt_AKABindingDelegate)delegate
                             error:(out_NSError)error
{
    NSParameterAssert(target != nil || targetValueProperty != nil);
    NSParameterAssert([bindingExpression isKindOfClass:[AKAConditionalBindingExpression class]]);

    // The outer binding target is this instances activeClause property.
    AKAProperty* conditionBindingTarget = [AKAProperty propertyOfWeakTarget:self
                                                                     getter:
                                           ^id _Nullable (id _Nonnull cbtarget)
                                           {
                                               return ((AKAConditionalBinding*)cbtarget).activeClause;
                                           }
                                                                     setter:
                                           ^(id _Nonnull cbtarget, id _Nullable value)
                                           {
                                               ((AKAConditionalBinding*)cbtarget).activeClause = value;
                                           }
                                                         observationStarter:nil
                                                         observationStopper:nil];

    if (self = [super initWithTarget:target
                 targetValueProperty:conditionBindingTarget
                          expression:bindingExpression
                             context:bindingContext
                               owner:owner
                            delegate:delegate
                               error:error])
    {
        AKAConditionalBindingExpression* conditionalExpression = (id)bindingExpression;

        // Initializes binding clauses

        __block BOOL failed = NO;
        __block NSError* blockError;

        NSMutableArray<AKAConditionalBindingClause*>* clauses = [NSMutableArray new];
        [conditionalExpression.clauses enumerateObjectsUsingBlock:
         ^(AKAConditionalBindingExpressionClause* _Nonnull expressionClause,
           NSUInteger index,
           BOOL* _Nonnull stop)
         {
             AKAConditionalBindingClause* clause = [AKAConditionalBindingClause new];
             clause.expressionClauseIndex = index;

             AKABindingExpression* predicateExpression = expressionClause.conditionBindingExpression;

             if (predicateExpression == nil)
             {
                 // $else part of a conditional binding expression
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
                      ^(id _Nullable oldValue, id _Nullable newValue)
                      {
                          [weakSelf predicateForClause:clause
                                               atIndex:index
                                           changedFrom:oldValue
                                                    to:newValue];
                      }];

                 clause.predicateBinding =
                         [[AKAPredicatePropertyBinding alloc] initWithTarget:clause
                                                         targetValueProperty:targetPredicateProperty
                                                                  expression:(req_AKABindingExpression)expressionClause.conditionBindingExpression
                                                                     context:bindingContext
                                                                       owner:self
                                                                    delegate:delegate
                                                                       error:&blockError];
                 if (clause.predicateBinding == nil)
                 {
                     failed = YES;
                     *stop = YES;
                 }
             }

             if (!failed)
             {
                 AKABindingExpression* resultExpression = expressionClause.resultBindingExpression;

                 clause.binding = resultBindingFactory(target,
                                                       targetValueProperty,
                                                       resultExpression,
                                                       bindingContext,
                                                       self,
                                                       delegate,
                                                       &blockError);
                 if (clause.binding)
                 {
                     [clauses addObject:clause];
                 }
                 else
                 {
                     failed = YES;
                     *stop = YES;
                 }
             }
         }];

        if (failed)
        {
            AKARegisterErrorInErrorStore(blockError, error);
            self = nil;
        }
        else
        {
            _clauses = clauses;
        }
    }

    return self;
}

- (void)                predicateForClause:(AKAConditionalBindingClause*)clause
                                   atIndex:(NSUInteger)index
                               changedFrom:(NSPredicate* __unused)oldPredicate
                                        to:(NSPredicate*)newPredicate
{
    if (self.activeClause && index <= self.activeClause.expressionClauseIndex)
    {
        if ([newPredicate evaluateWithObject:self.sourceValueProperty.value])
        {
            self.activeClause = clause;
        }
        else
        {
            for (NSUInteger i = index + 1; i < self.clauses.count; ++i)
            {
                AKAConditionalBindingClause* nextClause = self.clauses[i];

                if ([nextClause.predicate evaluateWithObject:self.sourceValueProperty.value])
                {
                    self.activeClause = nextClause;
                    break;
                }
            }
        }
    }
}

- (BOOL) validateBindingTypeWithExpression:(opt_AKABindingExpression)bindingExpression
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

- (AKAProperty*)bindingSourceForExpression:(AKABindingExpression* __unused)bindingExpression
                                   context:(req_AKABindingContext)bindingContext
                            changeObserver:(AKAPropertyChangeObserver)changeObserver
                                     error:(out_NSError __unused)error
{
    AKAProperty* result = [bindingContext dataContextPropertyForKeyPath:nil
                                                     withChangeObserver:changeObserver];

    return result;
}

#pragma mark - Properties

- (void)                   setActiveClause:(AKAConditionalBindingClause*)activeClause
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

#pragma mark - Conversion

- (BOOL)                convertSourceValue:(id)sourceValue
                             toTargetValue:(id _Nullable __autoreleasing*)targetValueStore
                                     error:(NSError* __autoreleasing _Nullable* __unused)error
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

#pragma mark - Change Tracking (observation status change events)

- (void)         willStartObservingChanges
{
    self.isObservingChanges = YES;
    [super willStartObservingChanges];
}

- (void)   willStartObservingBindingSource
{
    for (AKAConditionalBindingClause* clause in self.clauses)
    {
        [clause.predicateBinding startObservingChanges];
    }
    [super willStartObservingBindingSource];
}

- (void)     didStopObservingBindingSource
{
    for (AKAConditionalBindingClause* clause in self.clauses)
    {
        [clause.predicateBinding stopObservingChanges];
    }
    self.activeClause = nil;
    [super didStopObservingBindingSource];
}

- (void)           didStopObservingChanges
{
    self.isObservingChanges = NO;
    [super didStopObservingChanges];
}

@end
