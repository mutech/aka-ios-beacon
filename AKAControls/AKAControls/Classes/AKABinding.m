//
//  AKABinding.m
//  AKAControls
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;
@import AKACommons.AKAErrors;
@import AKACommons.AKALog;
@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKABinding.h"
#import "AKABindingExpression.h"


#pragma mark - AKABinding Private Interface
#pragma mark -

@interface AKABinding() {
    BOOL _isUpdatingTargetValueForSourceValueChange;
}

@end

#pragma mark - AKABinding Implementation
#pragma mark -

@implementation AKABinding

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init])
    {
        _isUpdatingTargetValueForSourceValueChange = NO;
    }
    return self;
}

- (instancetype _Nullable)         initWithTarget:(id)target
                                       expression:(req_AKABindingExpression)bindingExpression
                                          context:(req_AKABindingContext)bindingContext
                                         delegate:(opt_AKABindingDelegate)delegate
{
    if (self = [self init])
    {
        _bindingTarget = target;
        _delegate = delegate;

        __weak AKABinding* weakSelf = self;
        _bindingSource = [bindingExpression bindingSourcePropertyInContext:bindingContext
                                                             changeObserer:
                          ^(opt_id oldValue, opt_id newValue)
                          {
                              [weakSelf sourceValueDidChangeFromOldValue:oldValue
                                                              toNewValue:newValue];
                          }];
    }
    return self;
}

#pragma mark - Properties

- (BOOL)isUpdatingTargetValueForSourceValueChange
{
    return _isUpdatingTargetValueForSourceValueChange;
}

#pragma mark - Conversion

- (BOOL)                                 convertSourceValue:(opt_id)sourceValue
                                              toTargetValue:(out_id)targetValueStore
                                                      error:(out_NSError)error
{
    BOOL result = YES;
    if (targetValueStore)
    {
        *targetValueStore = sourceValue;
    }
    return result;
}

#pragma mark - Validation

- (BOOL)                                validateSourceValue:(inout_id)sourceValueStore
                                                      error:(out_NSError)error
{
    NSParameterAssert(sourceValueStore != nil);

    BOOL result = YES;

    id validatedValue = sourceValueStore == nil ? nil : *sourceValueStore;

    if (result && self.bindingSource != nil)
    {
        result = [self.bindingSource validateValue:&validatedValue error:error];
        if (validatedValue != *sourceValueStore)
        {
            *sourceValueStore = validatedValue;
        }
    }
    return result;
}

- (BOOL)                                validateTargetValue:(inout_id)targetValueStore
                                                      error:(out_NSError)error
{
    NSParameterAssert(targetValueStore != nil);

    BOOL result = YES;

    id validatedValue = targetValueStore == nil ? nil : *targetValueStore;

    if (result && self.bindingTarget != nil)
    {
        result = [self.bindingTarget validateValue:&validatedValue error:error];
        if (validatedValue != *targetValueStore)
        {
            *targetValueStore = validatedValue;
        }
    }
    return result;
}

#pragma mark - Delegate Support

- (void)             targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                                     toTargetValueWithError:(opt_NSError)error
{
    if ([self.delegate respondsToSelector:@selector(binding:targetUpdateFailedToConvertSourceValue:toTargetValueWithError:)])
    {
        [self.delegate                      binding:self
             targetUpdateFailedToConvertSourceValue:sourceValue
                             toTargetValueWithError:error];
    }
}

- (void)            targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                                   convertedFromSourceValue:(opt_id)sourceValue
                                                  withError:(opt_NSError)error
{
    if ([self.delegate respondsToSelector:@selector(binding:targetUpdateFailedToValidateTargetValue:convertedFromSourceValue:withError:)])
    {
        [self.delegate                      binding:self
            targetUpdateFailedToValidateTargetValue:targetValue
                           convertedFromSourceValue:sourceValue
                                          withError:error];
    }
}

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                             toInvalidValue:(opt_id)newSourceValue
                                                  withError:(opt_NSError)error
{
}

- (BOOL)              shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
                                                validatedTo:(opt_id)sourceValue
{
    return YES;
}

- (BOOL)                            shouldUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
                                             forSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(shouldUpdateTargetValue:to:forSourceValue:changeTo:)])
    {
        result = [self.delegate shouldBinding:self
                            updateTargetValue:oldTargetValue
                                           to:newTargetValue
                               forSourceValue:oldSourceValue
                                     changeTo:newSourceValue];
    }
    return result;
}

- (void)                              willUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
{
    _isUpdatingTargetValueForSourceValueChange = YES;
    if ([self.delegate respondsToSelector:@selector(binding:willUpdateTargetValue:to:)])
    {
        [self.delegate binding:self willUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
}

- (void)                               didUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
{
    if ([self.delegate respondsToSelector:@selector(binding:didUpdateTargetValue:to:)])
    {
        [self.delegate binding:self didUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
    _isUpdatingTargetValueForSourceValueChange = NO;
}


#pragma mark - Target Value Updates

- (void)                    updateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
{
    [self aka_performBlockInMainThreadOrQueue:
     ^{
         id targetValue = nil;
         NSError* error;
         if ([self convertSourceValue:newSourceValue
                        toTargetValue:&targetValue
                                error:&error])
         {
             if ([self validateTargetValue:&targetValue error:&error])
             {
                 id oldTargetValue = self.bindingTarget.value;
                 if ([self shouldUpdateTargetValue:oldTargetValue
                                                to:targetValue
                                    forSourceValue:oldSourceValue
                                          changeTo:newSourceValue])
                 {
                     [self willUpdateTargetValue:oldTargetValue
                                              to:targetValue];

                     self.bindingTarget.value = targetValue;

                     [self didUpdateTargetValue:oldTargetValue
                                             to:targetValue];
                 }
             }
             else
             {
                 [self targetUpdateFailedToValidateTargetValue:targetValue
                                      convertedFromSourceValue:newSourceValue
                                                     withError:error];
             }
         }
         else
         {
             [self targetUpdateFailedToConvertSourceValue:newSourceValue
                                   toTargetValueWithError:error];
         }
     }
                            waitForCompletion:NO];
}


#pragma mark - Change Tracking

- (BOOL)                              startObservingChanges
{
    BOOL result = YES;
    result &= [self.bindingSource startObservingChanges];
    result &= [self.bindingTarget startObservingChanges];
    [self updateTargetValueForSourceValue:[NSNull null] changeTo:self.bindingSource.value];
    return result;
}

- (BOOL)                               stopObservingChanges
{
    BOOL result = YES;
    result &= [self.bindingTarget stopObservingChanges];
    result &= [self.bindingSource stopObservingChanges];
    return result;
}

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                                 toNewValue:(opt_id)newSourceValue
{
    NSError* error;
    id sourceValue = newSourceValue;
    if ([self validateSourceValue:&sourceValue error:&error])
    {
        if ([self shouldUpdateTargetValueForSourceValue:oldSourceValue
                                               changeTo:newSourceValue
                                            validatedTo:sourceValue])
        {
            [self updateTargetValueForSourceValue:oldSourceValue
                                         changeTo:sourceValue];
        }
    }
    else
    {
        [self sourceValueDidChangeFromOldValue:oldSourceValue
                                toInvalidValue:newSourceValue
                                     withError:error];
    }
}

@end

