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

#pragma mark - Binding Delegate Message Propagation

- (void)propagateBindingDelegateMethod:(SEL)selector
                     usingBlock:(void(^)(id<AKABindingDelegate>, outreq_BOOL))block
{
    BOOL stop = NO;

    id<AKABindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:selector])
    {
        block(delegate, &stop);
    }

    AKABinding* binding = self;
    while (!stop && [binding.owner isKindOfClass:[AKABinding class]])
    {
        binding = (AKABinding*)binding.owner;
        if ([binding respondsToSelector:selector])
        {
            if (binding.shouldReceiveDelegateMessagesForSubBindings)
            {
                if (binding.shouldReceiveDelegateMessagesForTransitiveSubBindings ||
                    self.owner == binding)
                {
                    block((req_AKABindingDelegate)binding, &stop);
                }
            }
        }
    }

    AKABindingController* controller = self.controller;
    if (!stop && [controller respondsToSelector:selector])
    {
        block(controller, &stop);
    }
}

- (BOOL)shouldReceiveDelegateMessagesForSubBindings
{
    return NO;
}

- (BOOL)shouldReceiveDelegateMessagesForTransitiveSubBindings
{
    return NO;
}

#pragma mark - Delegate Support Methods

- (void)                   sourceValueDidChangeFromOldValue:(id _Nullable)oldSourceValue
                                                         to:(id _Nullable)newSourceValue
{
    [self propagateBindingDelegateMethod:@selector(binding:sourceValueDidChangeFromOldValue:to:)
                       usingBlock:
     ^(id<AKABindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self sourceValueDidChangeFromOldValue:oldSourceValue to:newSourceValue];
     }];
}

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                             toInvalidValue:(opt_id)newSourceValue
                                                  withError:(opt_NSError)error
{
    [self propagateBindingDelegateMethod:@selector(binding:sourceValueDidChangeFromOldValue:toInvalidValue:withError:)
                       usingBlock:
     ^(id<AKABindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self sourceValueDidChangeFromOldValue:oldSourceValue toInvalidValue:newSourceValue withError:error];
     }];
}

- (void)                             sourceArrayItemAtIndex:(NSUInteger)index
                                                      value:(opt_id)oldValue
                                                didChangeTo:(opt_id)newValue
{
    [self propagateBindingDelegateMethod:@selector(binding:sourceArrayItemAtIndex:value:didChangeTo:)
                       usingBlock:
     ^(id<AKABindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self sourceArrayItemAtIndex:index value:oldValue didChangeTo:newValue];
     }];
}

- (void)                             targetArrayItemAtIndex:(NSUInteger)index
                                                      value:(opt_id)oldValue
                                                didChangeTo:(opt_id)newValue
{
    [self propagateBindingDelegateMethod:@selector(binding:targetArrayItemAtIndex:value:didChangeTo:)
                       usingBlock:
     ^(id<AKABindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self targetArrayItemAtIndex:index value:oldValue didChangeTo:newValue];
     }];
}

- (void)             targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                                     toTargetValueWithError:(opt_NSError)error
{
    [self propagateBindingDelegateMethod:@selector(binding:targetUpdateFailedToConvertSourceValue:toTargetValueWithError:)
                       usingBlock:
     ^(id<AKABindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self targetUpdateFailedToConvertSourceValue:sourceValue toTargetValueWithError:error];
     }];
}

- (void)            targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                                   convertedFromSourceValue:(opt_id)sourceValue
                                                  withError:(opt_NSError)error
{
    [self propagateBindingDelegateMethod:@selector(binding:targetUpdateFailedToValidateTargetValue:convertedFromSourceValue:withError:)
                       usingBlock:
     ^(id<AKABindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self targetUpdateFailedToValidateTargetValue:targetValue convertedFromSourceValue:sourceValue withError:error];
     }];
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
    __block BOOL result = YES;
    [self propagateBindingDelegateMethod:@selector(shouldBinding:updateTargetValue:to:forSourceValue:changeTo:)
                       usingBlock:
     ^(id<AKABindingDelegate> delegate, outreq_BOOL stop)
     {
         result = [delegate shouldBinding:self updateTargetValue:oldTargetValue to:newTargetValue forSourceValue:oldSourceValue changeTo:newSourceValue];
         *stop = !result;
     }];

    return result;
}


- (void)                              willUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue

{
    [self propagateBindingDelegateMethod:@selector(binding:willUpdateTargetValue:to:)
                       usingBlock:
     ^(id<AKABindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self willUpdateTargetValue:oldTargetValue to:newTargetValue];
     }];

    self.isUpdatingTargetValueForSourceValueChange = YES;
}

- (void)                               didUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
                                             forSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
{
    self.isUpdatingTargetValueForSourceValueChange = NO;

    [self propagateBindingDelegateMethod:@selector(binding:didUpdateTargetValue:to:forSourceValue:changeTo:)
                       usingBlock:
     ^(id<AKABindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self didUpdateTargetValue:oldTargetValue to:newTargetValue forSourceValue:oldSourceValue changeTo:newSourceValue];
     }];
}

@end
