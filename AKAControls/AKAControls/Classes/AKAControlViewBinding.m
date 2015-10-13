//
//  AKAControlViewBinding.m
//  AKAControls
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKALog;
@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKAControlViewBinding.h"

@interface AKAControlViewBinding() {
    BOOL _isUpdatingSourceValueForTargetValueChange;
}

@end

@implementation AKAControlViewBinding

@dynamic delegate;

#pragma mark - Conversion

- (BOOL)                                 convertTargetValue:(opt_id)targetValue
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

#pragma mark - Delegate Support

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

- (void)             sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                                     toSourceValueWithError:(opt_NSError)error
{
    if ([self.delegate respondsToSelector:@selector(binding:sourceUpdateFailedToConvertTargetValue:toSourceValueWithError:)])
    {
        [self.delegate                      binding:self
             sourceUpdateFailedToConvertTargetValue:targetValue
                             toSourceValueWithError:error];
    }
}

- (BOOL)              shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
                                                validatedTo:(opt_id)sourceValue
{
    // Break update cycles
    return !self.isUpdatingSourceValueForTargetValueChange;
}

- (BOOL)              shouldUpdateSourceValueForTargetValue:(opt_id)oldTargetValue
                                                   changeTo:(opt_id)newTargetValue
                                                validatedTo:(opt_id)targetValue
{
    // Break update cycles
    return !self.isUpdatingTargetValueForSourceValueChange;
}

- (void)                   targetValueDidChangeFromOldValue:(opt_id)oldTargetValue
                                             toInvalidValue:(opt_id)newTargetValue
                                                  withError:(opt_NSError)error
{

}


- (void)                              willUpdateSourceValue:(opt_id)oldSourceValue
                                                         to:(opt_id)newSourceValue
{
    _isUpdatingSourceValueForTargetValueChange = YES;
    if ([self.delegate respondsToSelector:@selector(binding:willUpdateSourceValue:to:)])
    {
        [self.delegate binding:self willUpdateSourceValue:oldSourceValue to:newSourceValue];
    }
}

- (void)                               didUpdateSourceValue:(opt_id)oldSourceValue
                                                         to:(opt_id)newSourceValue
{
    if ([self.delegate respondsToSelector:@selector(binding:didUpdateSourceValue:to:)])
    {
        [self.delegate binding:self didUpdateSourceValue:oldSourceValue to:newSourceValue];
    }
    _isUpdatingSourceValueForTargetValueChange = NO;
}

#pragma mark - Source Value Updates

- (void)                    updateSourceValueForTargetValue:(opt_id)oldTargetValue
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
                 NSAssert(!self.isUpdatingSourceValueForTargetValueChange, @"Nested source value update for target value change.");

                 id oldSourceValue = self.bindingSource.value;

                 [self willUpdateSourceValue:oldSourceValue to:sourceValue];

                 self.bindingSource.value = sourceValue;

                 [self didUpdateSourceValue:oldSourceValue to:sourceValue];
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

#pragma mark - Change Tracking

- (void)                   targetValueDidChangeFromOldValue:(opt_id)oldTargetValue
                                                 toNewValue:(opt_id)newTargetValue
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
        else
        {
            AKALogTrace(@"%@: Skipped source value update for target value '%@' change to '%@'",
                        self, oldTargetValue, newTargetValue);
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

