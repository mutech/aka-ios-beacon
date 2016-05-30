//
//  AKABinding+DelegateSupport.m
//  AKABeacon
//
//  Created by Michael Utech on 28.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding+DelegateSupport.h"
#import "AKABinding_TargetValueUpdateProperties.h"

#pragma mark - AKABinding(DelegateSupport) - Implementation
#pragma mark -

@implementation AKABinding(DelegateSupport)

- (void)                   sourceValueDidChangeFromOldValue:(id _Nullable)oldSourceValue
                                                         to:(id _Nullable)newSourceValue
{
    [self.controller binding:self sourceValueDidChangeFromOldValue:oldSourceValue to:newSourceValue];

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:sourceValueDidChangeFromOldValue:to:)])
    {
        [delegate binding:self sourceValueDidChangeFromOldValue:oldSourceValue to:newSourceValue];
    }
}

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                             toInvalidValue:(opt_id)newSourceValue
                                                  withError:(opt_NSError)error
{
    [self.controller binding:self sourceValueDidChangeFromOldValue:oldSourceValue toInvalidValue:newSourceValue withError:error];

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:sourceValueDidChangeFromOldValue:toInvalidValue:withError:)])
    {
        [delegate binding:self sourceValueDidChangeFromOldValue:oldSourceValue toInvalidValue:newSourceValue withError:error];
    }
}

- (void)                             sourceArrayItemAtIndex:(NSUInteger)index
                                                      value:(opt_id)oldValue
                                                didChangeTo:(opt_id)newValue
{
    [self.controller binding:self sourceArrayItemAtIndex:index value:oldValue didChangeTo:newValue];

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:sourceArrayItemAtIndex:value:didChangeTo:)])
    {
        [delegate binding:self sourceArrayItemAtIndex:index value:oldValue didChangeTo:newValue];
    }
}

- (void)                             targetArrayItemAtIndex:(NSUInteger)index
                                                      value:(opt_id)oldValue
                                                didChangeTo:(opt_id)newValue
{
    [self.controller binding:self targetArrayItemAtIndex:index value:oldValue didChangeTo:newValue];

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:targetArrayItemAtIndex:value:didChangeTo:)])
    {
        [delegate binding:self targetArrayItemAtIndex:index value:oldValue didChangeTo:newValue];
    }
}

- (void)             targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                                     toTargetValueWithError:(opt_NSError)error
{
    [self.controller binding:self targetUpdateFailedToConvertSourceValue:sourceValue
      toTargetValueWithError:error];

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:targetUpdateFailedToConvertSourceValue:toTargetValueWithError:)])
    {
        [delegate binding:self targetUpdateFailedToConvertSourceValue:sourceValue toTargetValueWithError:error];
    }
}

- (void)            targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                                   convertedFromSourceValue:(opt_id)sourceValue
                                                  withError:(opt_NSError)error
{
    [self.controller binding:self targetUpdateFailedToValidateTargetValue:targetValue convertedFromSourceValue:sourceValue withError:error];

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:targetUpdateFailedToValidateTargetValue:convertedFromSourceValue:withError:)])
    {
        [delegate binding:self targetUpdateFailedToValidateTargetValue:targetValue convertedFromSourceValue:sourceValue withError:error];
    }
}

// This is not a delegate method, it serves as a shortcut to prevent updates in subclasses before
// the source value is converted to the target value.
- (BOOL)              shouldUpdateTargetValueForSourceValue:(opt_id __unused)oldSourceValue
                                                   changeTo:(opt_id __unused)newSourceValue
                                                validatedTo:(opt_id __unused)sourceValue
{
    // Implemented by subclasses to prevent update cycles:
    return YES;
}

- (BOOL)                            shouldUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
                                             forSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
{
    BOOL result = YES;

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(shouldBinding:updateTargetValue:to:forSourceValue:changeTo:)])
    {
        result = [delegate shouldBinding:self updateTargetValue:oldTargetValue to:newTargetValue forSourceValue:oldSourceValue changeTo:newSourceValue];
    }

    AKABindingController* controller = self.controller;
    if (result && controller)
    {
        result = [controller shouldBinding:self updateTargetValue:oldTargetValue to:newTargetValue forSourceValue:oldSourceValue changeTo:newSourceValue];
    }

    return result;
}


- (void)                              willUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue

{
    self.isUpdatingTargetValueForSourceValueChange = YES;

    [self.controller binding:self willUpdateTargetValue:oldTargetValue to:newTargetValue];

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:willUpdateTargetValue:to:)])
    {
        [delegate binding:self willUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
}

- (void)                               didUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
{
    [self.controller binding:self didUpdateTargetValue:oldTargetValue to:newTargetValue];

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:didUpdateTargetValue:to:)])
    {
        [delegate binding:self didUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
    self.isUpdatingTargetValueForSourceValueChange = NO;
}

@end
