//
//  AKABinding.m
//  AKAControls
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;
@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKABinding.h"

@interface AKABinding()

@end

#pragma mark - AKABinding Implementation
#pragma mark -

@implementation AKABinding

- (instancetype)initWithDelegate:(id<AKABindingDelegate>)delegate
{
    if (self = [super init])
    {
        _delegate = delegate;
    }
    return self;
}

- (AKAProperty *)bindingSource
{
    AKAErrorAbstractMethodImplementationMissing();
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

- (void)            sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                                   convertedFromTargetValue:(opt_id)targetValue
                                                  withError:(opt_NSError)error
{
    if ([self.delegate respondsToSelector:@selector(binding:sourceUpdateFailedToValidateSourceValue:convertedFromTargetValue:withError:)])
    {
        [self.delegate                      binding:self
            sourceUpdateFailedToValidateSourceValue:sourceValue
                           convertedFromTargetValue:targetValue
                                          withError:error];
    }
}

- (void)sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                        toSourceValueWithError:(opt_NSError)error
{
    if ([self.delegate respondsToSelector:@selector(binding:sourceUpdateFailedToConvertTargetValue:toSourceValueWithError:)])
    {
        [self.delegate                      binding:self
             sourceUpdateFailedToConvertTargetValue:targetValue
                             toSourceValueWithError:error];
    }
}


- (void)sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                          toInvalidValue:(opt_id)newSourceValue
                               withError:(opt_NSError)error
{

}

- (BOOL)shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                     changeTo:(opt_id)newSourceValue
                                  validatedTo:(opt_id)sourceValue
{
    return YES;
}

- (void)targetValueDidChangeFromOldValue:(opt_id)oldTargetValue
                          toInvalidValue:(opt_id)newTargetValue
                               withError:(opt_NSError)error
{

}

- (BOOL)shouldUpdateSourceValueForTargetValue:(opt_id)oldTargetValue
                                     changeTo:(opt_id)newTargetValue
                                  validatedTo:(opt_id)targetValue
{
    return YES;
}

#pragma mark - Target Value Updates

- (void)updateTargetValueForSourceValue:(opt_id)oldSourceValue
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
                 self.bindingTarget.value = targetValue;
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

- (BOOL)convertSourceValue:(opt_id)sourceValue
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

- (BOOL)validateTargetValue:(inout_id)targetValueStore
                      error:(out_NSError)error
{
    BOOL result = YES;
    return result;
}

#pragma mark - Source Value Updates

- (void)updateSourceValueForTargetValue:(opt_id)oldTargetValue
                               changeTo:(opt_id)newTargetValue
{
    [self aka_performBlockInMainThreadOrQueue:
     ^{
         NSError* error;

         id sourceValue = nil;
         if ([self convertTargetValue:newTargetValue
                        toSourceValue:&sourceValue
                                error:&error])
         {
             if ([self validateSourceValue:&sourceValue error:&error])
             {
                 self.bindingSource.value = sourceValue;
             }
             else
             {
                 [self sourceUpdateFailedToValidateSourceValue:sourceValue
                                      convertedFromTargetValue:newTargetValue
                                                     withError:error];
             }
         }
         else
         {
             [self sourceUpdateFailedToConvertTargetValue:newTargetValue
                                   toSourceValueWithError:error];
         }

     }
                            waitForCompletion:NO];
}

- (BOOL)convertTargetValue:(opt_id)targetValue
             toSourceValue:(out_id)sourceValueStore
                     error:(out_NSError)error
{
    BOOL result = YES;
    if (sourceValueStore)
    {
        *sourceValueStore = targetValue;
    }
    return result;
}

- (BOOL)validateSourceValue:(inout_id)sourceValueStore
                      error:(out_NSError)error
{
    BOOL result = YES;
    return result;
}

#pragma mark - Change Observation

- (BOOL)startObservingChanges
{
    BOOL result = YES;
    result &= [self.bindingSource startObservingChanges];
    result &= [self.bindingTarget startObservingChanges];
    [self updateTargetValueForSourceValue:[NSNull null] changeTo:self.bindingSource.value];
    return result;
}

- (BOOL)stopObservingChanges
{
    BOOL result = YES;
    result &= [self.bindingTarget stopObservingChanges];
    result &= [self.bindingSource stopObservingChanges];
    return result;
}

- (void)sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
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

- (void)targetValueDidChangeFromOldValue:(opt_id)oldTargetValue toNewValue:(opt_id)newTargetValue
{
    NSError* error;
    id targetValue = newTargetValue;
    if ([self validateTargetValue:&targetValue error:&error])
    {
        if ([self shouldUpdateSourceValueForTargetValue:oldTargetValue
                                               changeTo:newTargetValue
                                            validatedTo:targetValue])
        {
            [self updateSourceValueForTargetValue:oldTargetValue changeTo:targetValue];
        }
    }
    else
    {
        [self targetValueDidChangeFromOldValue:oldTargetValue
                                toInvalidValue:newTargetValue
                                     withError:error];
    }
}

@end