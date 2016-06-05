//
//  AKAKeyboardControlViewBinding+DelegateSupport.m
//  AKABeacon
//
//  Created by Michael Utech on 05.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAKeyboardControlViewBinding+DelegateSupport.h"
#import "AKABinding+DelegateSupport.h"
#import "AKABindingController+KeyboardActivationSequence.h"

@implementation AKAKeyboardControlViewBinding (DelegateSupport)

- (BOOL)                              shouldResponderActivate:(req_UIResponder)responder
{
    __block BOOL result = YES;
    [self propagateBindingDelegateMethod:@selector(shouldBinding:responderActivate:)
                              usingBlock:
     ^(id<AKAKeyboardControlViewBindingDelegate> delegate, outreq_BOOL stop)
     {
         result = [delegate shouldBinding:self responderActivate:responder];
         *stop = !result;
     }];

    return result;
}

- (void)                                responderWillActivate:(req_UIResponder)responder
{
    [self.keyboardActivationSequence prepareToActivateItem:self];

    [self propagateBindingDelegateMethod:@selector(binding:responderWillActivate:)
                              usingBlock:
     ^(id<AKAKeyboardControlViewBindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self responderWillActivate:responder];
     }];
}

- (void)                                 responderDidActivate:(req_UIResponder)responder
{
    [self.keyboardActivationSequence activateItem:self];

    [self propagateBindingDelegateMethod:@selector(binding:responderDidActivate:)
                              usingBlock:
     ^(id<AKAKeyboardControlViewBindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self responderDidActivate:responder];
     }];
}

- (BOOL)                            shouldResponderDeactivate:(req_UIResponder)responder
{
    __block BOOL result = YES;
    [self propagateBindingDelegateMethod:@selector(shouldBinding:responderDeactivate:)
                              usingBlock:
     ^(id<AKAKeyboardControlViewBindingDelegate> delegate, outreq_BOOL stop)
     {
         result = [delegate shouldBinding:self responderDeactivate:responder];
         *stop = !result;
     }];

    return result;
}

- (void)                              responderWillDeactivate:(req_UIResponder)responder
{
    [self propagateBindingDelegateMethod:@selector(binding:responderWillDeactivate:)
                              usingBlock:
     ^(id<AKAKeyboardControlViewBindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self responderWillDeactivate:responder];
     }];
}

- (void)                               responderDidDeactivate:(req_UIResponder)responder
{
    AKAKeyboardActivationSequence* sequence = self.keyboardActivationSequence;
    if (sequence.activeItem == self)
    {
        [sequence deactivate];
    }

    [self propagateBindingDelegateMethod:@selector(binding:responderDidDeactivate:)
                              usingBlock:
     ^(id<AKAKeyboardControlViewBindingDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate binding:self responderDidDeactivate:responder];
     }];
}

@end
