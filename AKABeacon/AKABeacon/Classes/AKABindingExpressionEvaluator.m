//
//  AKABindingExpressionEvaluator.m
//  AKABeacon
//
//  Created by Michael Utech on 14.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAProperty.h"

#import "AKABindingExpressionEvaluator.h"
#import "AKAChildBindingContext.h"

@interface AKABindingExpressionEvaluator()

@property(nonatomic, nonnull, readonly) id<AKABindingContextProtocol>  parentBindingContext;
@property(nonatomic, nonnull) AKAChildBindingContext*                  bindingContext;
@property(nonatomic, nonnull) AKAProperty*                             dataContextProperty;
@property(nonatomic, nullable) id                                      dataContext;

@property(nonatomic, nullable) id                                      evaluationResult;

@end


@implementation AKABindingExpressionEvaluator

- (instancetype)initWithFactoryBindingExpression:(AKABindingExpression *)bindingExpression
                                  bindingContext:(req_AKABindingContext)bindingContext
                                 bindingDelegate:(id<AKABindingDelegate>)delegate
                                           error:(out_NSError)error
{
    if (self = [self init])
    {
        // The evaluation result property is used as binding target by the binding
        req_AKAProperty evaluationResultProperty = [AKAProperty propertyOfWeakTarget:self
                                                                     getter:
                                           ^opt_id(req_id target) { return [target evaluationResult]; }
                                                                     setter:
                                           ^(req_id target, opt_id value) { [target setEvaluationResult:value]; }
                                                         observationStarter:nil
                                                         observationStopper:nil];

        _dataContextProperty = [AKAProperty propertyOfWeakTarget:self
                                                          getter:
                                ^opt_id(req_id target) { return [target dataContext]; }
                                                          setter:
                                ^(req_id target, opt_id value) { [target setDataContext:value]; }
                                              observationStarter:nil
                                              observationStopper:nil];
        _parentBindingContext = bindingContext;
        _bindingContext = [AKAChildBindingContext bindingContextWithParent:bindingContext
                                                       dataContextProperty:self.dataContextProperty];


        NSError* localError = nil;
        Class bindingType = bindingExpression.specification.bindingType;
        AKABinding* factoryBinding = [bindingType bindingToTarget:self
                                              targetValueProperty:evaluationResultProperty
                                                   withExpression:bindingExpression
                                                          context:self.bindingContext
                                                            owner:nil // TODO: add owner parameter and forward to this call?
                                                         delegate:delegate
                                                            error:error];
        if (factoryBinding)
        {
            _binding = factoryBinding;
        }
        else
        {
            self = nil;
            if (error)
            {
                *error = localError;
            }
            else
            {
                @throw [NSException exceptionWithName:@"InvalidOperation"
                                               reason:[NSString stringWithFormat:@"Unhandled error: %@", localError.localizedDescription]
                                             userInfo:@{ @"error": localError }];
            }
        }
    }
    return self;
}

#pragma mark - Properties

- (void)setDataContext:(id)dataContext
{
    id oldDataContext = self.dataContext;
    _dataContext = dataContext;

    [self.dataContextProperty notifyPropertyValueDidChangeFrom:oldDataContext to:dataContext];
}

#pragma mark - Mapping

- (id _Nullable)valueForDataContext:(id)dataContext
{
    NSAssert([NSThread isMainThread],
             @"%@ can only be called from main thread",
             NSStringFromSelector(_cmd));
    NSAssert(!self.isObserving,
             @"Internal inconsistency: mapping %@ is already active (it's not thread safe!)",
             self);

    id result = nil;

    if (!self.isObserving)
    {
        _isObserving = YES;
        [self.dataContextProperty startObservingChanges];
        self.dataContext = dataContext;
        [self.binding startObservingChanges];

        result = self.evaluationResult;

        [self.binding stopObservingChanges];
        [self.dataContextProperty stopObservingChanges];

        //self.dataContext = nil;
        self.evaluationResult = nil;

        _isObserving = NO;
    }

    return result;
}

- (id _Nullable)value
{
    return [self valueForDataContext:[self.parentBindingContext dataContextValueForKeyPath:nil]];
}

@end
