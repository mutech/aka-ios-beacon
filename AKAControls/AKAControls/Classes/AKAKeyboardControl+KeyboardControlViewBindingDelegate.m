//
//  AKAControl+KeyboardControlViewBindingDelegate.m
//  AKAControls
//
//  Created by Michael Utech on 14.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAKeyboardControl+KeyboardControlViewBindingDelegate.h"
#import "AKAKeyboardControlViewBinding.h"

#import "AKACompositeControl+BindingDelegatePropagation.h"

// All events arriving here are bubbled up to the owner control. The typical scenario is that
// an AKAFormControl will handle the events and/or forward them to its delegate.

@implementation AKAKeyboardControl(KeyboardControlViewBindingDelegate)

#pragma mark - Activation Control and Events

- (BOOL)                                shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder
{
    NSParameterAssert(binding != nil && (id)binding == self.controlViewBinding); // cast to id for nullability warning
    NSParameterAssert(responder != nil);

    AKACompositeControl* owner = self.owner;
    BOOL result = YES;
    if (owner)
    {
        result = [owner control:self shouldBinding:binding responderActivate:responder];
    }
    return result;
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder
{
    NSParameterAssert(binding != nil && (id)binding == self.controlViewBinding);
    NSParameterAssert(responder != nil);

    [self.owner control:self binding:binding responderWillActivate:responder];
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder
{
    NSParameterAssert(binding != nil && (id)binding == self.controlViewBinding);
    NSParameterAssert(responder != nil);

    [self.owner control:self binding:binding responderDidActivate:responder];
}

- (BOOL)                                shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder
{
    NSParameterAssert(binding != nil && (id)binding == self.controlViewBinding);
    NSParameterAssert(responder != nil);

    BOOL result = YES;

    AKACompositeControl* owner = self.owner;
    if (owner)
    {
        result = [owner control:self shouldBinding:binding responderDeactivate:responder];
    }
    return result;
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder
{
    NSParameterAssert(binding != nil && (id)binding == self.controlViewBinding);
    NSParameterAssert(responder != nil);

    [self.owner control:self binding:binding responderWillDeactivate:responder];
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder
{
    NSParameterAssert(binding != nil && (id)binding == self.controlViewBinding);
    NSParameterAssert(responder != nil);

    [self.owner control:self binding:binding responderDidDeactivate:responder];
}

#pragma mark - Keyboard Navigation Requests

/**
 * This enables keyboard driven controls to active the next control when the user typed
 * the "next" key.
 *
 * @note The previous and next buttons in the input accessory view are not using this method,
 * the keyboard activation sequence manages these actions.
 *
 * @param binding the active binding
 * @param responder the responder requesting the action
 *
 * @return YES if the next control/responder was activated.
 */
- (BOOL)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                       responderRequestedActivateNext:(req_UIResponder)responder
{
    BOOL result = NO;

    AKACompositeControl* owner = self.owner;
    if (owner)
    {
        result = [owner control:self binding:binding responderRequestedActivateNext:responder];
    }
    return result;
}

/**
 * This enables keyboard driven controls to active the next control when the user typed
 * the "next" key.
 *
 * @note The close button in the input accessory view is not using this method,
 * the keyboard activation sequence manages this action.
 *
 * @param binding the active binding
 * @param responder the responder requesting the action
 *
 * @return YES if the next control/responder was activated.
 */
- (BOOL)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                           responderRequestedGoOrDone:(req_UIResponder)responder
{
    BOOL result = NO;

    AKACompositeControl* owner = self.owner;
    if (owner)
    {
        result = [owner control:self binding:binding responderRequestedGoOrDone:responder];
    }
    return result;
}

@end

