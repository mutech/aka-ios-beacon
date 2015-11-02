//
//  AKAKeyboardControlViewBinding.m
//  AKAControls
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;

#import "AKAKeyboardControlViewBinding.h"
#import "AKAKeyboardActivationSequenceItemProtocol_Internal.h"
#import "AKAKeyboardActivationSequence.h"

#import "AKACompositeControl+BindingDelegatePropagation.h"

@interface AKAKeyboardControlViewBinding ()
{
    __weak AKAKeyboardActivationSequence* _keyboardActivationSequence;
    UIView*                               _savedInputAccessoryView;
}
@end


@implementation AKAKeyboardControlViewBinding

@dynamic delegate;

#pragma mark - Initialization

- (instancetype)                                 initWithView:(req_UIView)targetView
                                                   expression:(req_AKABindingExpression)bindingExpression
                                                      context:(req_AKABindingContext)bindingContext
                                                     delegate:(opt_AKABindingDelegate)delegate
                                                        error:(out_NSError)error
{
    if (self = [super initWithView:targetView
                        expression:bindingExpression
                           context:bindingContext
                          delegate:delegate
                             error:error])
    {
        self.shouldParticipateInKeyboardActivationSequence = YES;
        self.autoActivate = NO;
        self.liveModelUpdates = YES;
    }

    return self;
}

#pragma mark - Properties

- (opt_UIView)                    responderInputAccessoryView
{
    return self.responderForKeyboardActivationSequence.inputAccessoryView;
}

- (void)                       setResponderInputAccessoryView:(opt_UIView)inputAccessoryView
{
    UIResponder* responder = self.responderForKeyboardActivationSequence;

    if ([responder respondsToSelector:@selector(setInputAccessoryView:)])
    {
        [responder performSelector:@selector(setInputAccessoryView:) withObject:inputAccessoryView];
    }
    else
    {
        AKAErrorAbstractMethodImplementationMissing();
    }
}

#pragma mark - UIResponder Events

- (BOOL)                              shouldResponderActivate:(req_UIResponder)responder
{
    BOOL result = responder != nil;

    id<AKAKeyboardControlViewBindingDelegate> delegate = self.delegate;

    if (result && [delegate respondsToSelector:@selector(shouldBinding:responderActivate:)])
    {
        result = [delegate shouldBinding:self responderActivate:responder];
    }

    return result;
}

- (void)                                responderWillActivate:(req_UIResponder)responder
{
    [self.keyboardActivationSequence prepareToActivateItem:self];

    id<AKAKeyboardControlViewBindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:responderWillActivate:)])
    {
        [delegate binding:self responderWillActivate:responder];
    }
}

- (void)                                 responderDidActivate:(req_UIResponder)responder
{
    [self.keyboardActivationSequence activateItem:self];

    id<AKAKeyboardControlViewBindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:responderDidActivate:)])
    {
        [delegate binding:self responderDidActivate:responder];
    }
}

- (BOOL)                            shouldResponderDeactivate:(req_UIResponder)responder
{
    BOOL result = responder != nil;

    id<AKAKeyboardControlViewBindingDelegate> delegate = self.delegate;

    if (result && [delegate respondsToSelector:@selector(shouldBinding:responderDeactivate:)])
    {
        result = [delegate shouldBinding:self responderDeactivate:responder];
    }

    return result;
}

- (void)                              responderWillDeactivate:(req_UIResponder)responder
{
    id<AKAKeyboardControlViewBindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:responderWillDeactivate:)])
    {
        [delegate binding:self responderWillDeactivate:responder];
    }
}

- (void)                               responderDidDeactivate:(req_UIResponder)responder
{
    AKAKeyboardActivationSequence* sequence = self.keyboardActivationSequence;

    if (sequence.activeItem == self)
    {
        [sequence deactivate];
    }
    id<AKAKeyboardControlViewBindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:responderDidDeactivate:)])
    {
        [delegate binding:self responderDidDeactivate:responder];
    }
}

@end


@interface AKAKeyboardControlViewBinding (KeyboardActivationSequence_Internal) <
    AKAKeyboardActivationSequenceItemProtocol_Internal
    >
- (void)                        setKeyboardActivationSequence:(AKAKeyboardActivationSequence*)keyboardActivationSequence;
@end

@implementation AKAKeyboardControlViewBinding (KeyboardActivationSequence_Internal)

- (void)                        setKeyboardActivationSequence:(AKAKeyboardActivationSequence*)keyboardActivationSequence
{
    if (keyboardActivationSequence != _keyboardActivationSequence)
    {
        NSAssert(keyboardActivationSequence == nil || _keyboardActivationSequence == nil,
                 @"Invalid attempt to join keyboard activation sequence %@, %@ is already member of sequence %@", keyboardActivationSequence, self, _keyboardActivationSequence);

        _keyboardActivationSequence = keyboardActivationSequence;
    }
}

@end

@implementation AKAKeyboardControlViewBinding (KeyboardActivationSequence)


- (BOOL)             participatesInKeyboardActivationSequence
{
    return self.keyboardActivationSequence != nil;
}

- (AKAKeyboardActivationSequence*)keyboardActivationSequence
{
    return _keyboardActivationSequence;
}

- (opt_UIResponder)    responderForKeyboardActivationSequence
{
    return self.view;
}

#pragma mark - Activation (First Responder)

- (BOOL)                                    isResponderActive
{
    return self.responderForKeyboardActivationSequence.isFirstResponder;
}

- (BOOL)                                    activateResponder
{
    UIResponder* responder = self.responderForKeyboardActivationSequence;
    BOOL result = [self shouldResponderActivate:responder];

    if (result)
    {
        [self responderWillActivate:responder];
        result = [responder becomeFirstResponder];

        if (result)
        {
            [self responderDidActivate:responder];
        }
    }

    return result;
}

- (BOOL)                                  deactivateResponder
{
    UIResponder* responder = self.responderForKeyboardActivationSequence;
    BOOL result = [self shouldResponderDeactivate:responder];

    if (responder != nil)
    {
        [self responderWillDeactivate:responder];
        result = [responder resignFirstResponder];

        if (result)
        {
            [self responderDidDeactivate:responder];
        }
    }

    return result;
}

- (BOOL)                            installInputAccessoryView:(req_UIView)inputAccessoryView
{
    if ((UIView*)inputAccessoryView != self.responderInputAccessoryView)
    {
        NSAssert(_savedInputAccessoryView == nil,
                 @"previously installed input accessory view was not restored");
        _savedInputAccessoryView = self.responderInputAccessoryView;
        self.responderInputAccessoryView = inputAccessoryView;
    }

    return self.responderInputAccessoryView == inputAccessoryView;
}

- (BOOL)                            restoreInputAccessoryView
{
    self.responderInputAccessoryView = _savedInputAccessoryView;
    BOOL result = self.responderInputAccessoryView == _savedInputAccessoryView;
    _savedInputAccessoryView = nil;

    return result;
}

@end