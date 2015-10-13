//
//  AKAKeyboardControlViewBinding.m
//  AKAControls
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;

#import "AKAKeyboardControlViewBinding.h"


@interface AKAKeyboardControlViewBinding()

@property(nonatomic, nullable) UIView* savedInputAccessoryView;

@end

@implementation AKAKeyboardControlViewBinding

@dynamic delegate;

#pragma mark - Initialization

- (instancetype)                              initWithView:(req_UIView)targetView
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
{
    if (self = [super initWithView:targetView
                        expression:bindingExpression
                           context:bindingContext
                          delegate:delegate])
    {
        self.KBActivationSequence = YES;
        self.autoActivate = NO;
        self.liveModelUpdates = YES;
    }
    return self;
}

#pragma mark - Properties

- (opt_UIView)                 responderInputAccessoryView
{
    return self.responderForKeyboardActivationSequence.inputAccessoryView;
}

- (void)                    setResponderInputAccessoryView:(opt_UIView)inputAccessoryView
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

#pragma mark - AKAKeyboardActivationSequenceItemProtocol

- (BOOL)     shouldParticipateInKeyboardActivationSequence
{
    return self.KBActivationSequence && self.responderForKeyboardActivationSequence != nil;
}

- (opt_UIResponder) responderForKeyboardActivationSequence
{
    return self.view;
}

- (BOOL)                                 isResponderActive
{
    return self.responderForKeyboardActivationSequence.isFirstResponder;
}

- (BOOL)                                 activateResponder
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

- (BOOL)                               deactivateResponder
{
    UIResponder* responder = self.responderForKeyboardActivationSequence;
    BOOL result = [self shouldResponderDeactivate:responder];

    if (responder != nil)
    {
        [self responderWillDeactivate:responder];
        BOOL result = [responder resignFirstResponder];
        if (result)
        {
            [self responderDidDeactivate:responder];
        }
    }

    return result;
}

- (BOOL)                         installInputAccessoryView:(req_UIView)inputAccessoryView
{
    if (inputAccessoryView != self.responderInputAccessoryView)
    {
        NSAssert(self.savedInputAccessoryView == nil,
                 @"previously installed input accessory view was not restored");
        self.savedInputAccessoryView = self.responderInputAccessoryView;
        self.responderInputAccessoryView = inputAccessoryView;
    }
    return self.responderInputAccessoryView == inputAccessoryView;
}

- (BOOL)                         restoreInputAccessoryView
{
    self.responderInputAccessoryView = self.savedInputAccessoryView;
    BOOL result = self.responderInputAccessoryView == self.savedInputAccessoryView;
    self.savedInputAccessoryView = nil;
    return result;
}

#pragma mark - UIResponder Events

- (BOOL)                           shouldResponderActivate:(req_UIResponder)responder
{
    BOOL result = responder != nil;
    if (result && [self.delegate respondsToSelector:@selector(shouldBinding:responderActivate:)])
    {
        result = [self.delegate shouldBinding:self responderActivate:responder];
    }
    return result;
}

- (void)                             responderWillActivate:(req_UIResponder)responder
{
    if ([self.delegate respondsToSelector:@selector(binding:responderWillActivate:)])
    {
        [self.delegate binding:self responderWillActivate:responder];
    }
}

- (void)                              responderDidActivate:(req_UIResponder)responder
{
    if ([self.delegate respondsToSelector:@selector(binding:responderDidActivate:)])
    {
        [self.delegate binding:self responderDidActivate:responder];
    }
}

- (BOOL)                         shouldResponderDeactivate:(req_UIResponder)responder
{
    BOOL result = responder != nil;
    if (result && [self.delegate respondsToSelector:@selector(shouldBinding:responderDeactivate:)])
    {
        result = [self.delegate shouldBinding:self responderDeactivate:responder];
    }
    return result;
}

- (void)                           responderWillDeactivate:(req_UIResponder)responder
{
    if ([self.delegate respondsToSelector:@selector(binding:responderWillDeactivate:)])
    {
        [self.delegate binding:self responderWillDeactivate:responder];
    }
}

- (void)                            responderDidDeactivate:(req_UIResponder)responder
{
    if ([self.delegate respondsToSelector:@selector(binding:responderDidDeactivate:)])
    {
        [self.delegate binding:self responderDidDeactivate:responder];
    }
}

@end
