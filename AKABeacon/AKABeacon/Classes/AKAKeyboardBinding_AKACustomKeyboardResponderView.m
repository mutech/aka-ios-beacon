//
// Created by Michael Utech on 17.10.15.
// Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAKeyboardBinding_AKACustomKeyboardResponderView.h"
#import "AKACustomKeyboardResponderView.h"


@interface AKAKeyboardBinding_AKACustomKeyboardResponderView()

@property(nonatomic, nullable, weak) id<AKACustomKeyboardResponderDelegate> savedTriggerViewDelegate;

@end


@implementation AKAKeyboardBinding_AKACustomKeyboardResponderView

#pragma mark - Initialization

- (void)validateTarget:(req_id)target
{
    (void)target;
    NSParameterAssert([target isKindOfClass:[AKACustomKeyboardResponderView class]]);
}

#pragma mark - Custom Keyboard Responder View Delegate Attachment

- (void)                   attachToCustomKeyboardResponderView
{
    NSParameterAssert(self.triggerView.delegate == self || self.savedTriggerViewDelegate == nil);

    self.savedTriggerViewDelegate = self.triggerView.delegate;
    self.triggerView.delegate = self;

    return;
}

- (void)                 detachFromCustomKeyboardResponderView
{
    self.triggerView.delegate = self.savedTriggerViewDelegate;
}

#pragma mark - Properties

- (AKACustomKeyboardResponderView*)                triggerView
{
    UIView* result = self.view;
    NSParameterAssert(result == nil || [result isKindOfClass:[AKACustomKeyboardResponderView class]]);

    return (AKACustomKeyboardResponderView*)result;
}

- (void)                           setSavedTriggerViewDelegate:(id<AKACustomKeyboardResponderDelegate>)savedTriggerViewDelegate
{
    NSAssert(savedTriggerViewDelegate != self, @"Cannot register AKA custom keyboard trigger view binding as saved delegate, it already acts as replacement/proxy delegate");

    _savedTriggerViewDelegate = savedTriggerViewDelegate;
}

#pragma mark - Keyboard Activation Sequence

- (UIView *)                       responderInputAccessoryView
{
    return self.triggerView.inputAccessoryView;
}

- (void)                        setResponderInputAccessoryView:(UIView *)responderInputAccessoryView
{
    self.inputAccessoryView = responderInputAccessoryView;

    // self.triggerView.inputAccessory view will access self.inputAccessoryView via delegation:
    NSAssert(self.triggerView.inputAccessoryView == responderInputAccessoryView, @"Failed to install keyboard activation sequence input accessory view %@, installed view is %@", responderInputAccessoryView, self.triggerView.inputAccessoryView);
}

- (BOOL)                                     activateResponder
{
    // redefined to prevent base implementation from calling will/did activate methods. These
    // are called from custom keyboard responder view delegate methods instead.
    return [self.responderForKeyboardActivationSequence becomeFirstResponder];
}

- (BOOL)                                   deactivateResponder
{
    // redefined to prevent base implementation from calling will/did deactivate methods. These
    // are called from custom keyboard responder view delegate methods instead.
    return [self.responderForKeyboardActivationSequence resignFirstResponder];
}

#pragma mark - AKACustomKeyboardResponderDelegate Implementation

- (BOOL)    customKeyboardResponderViewCanBecomeFirstResponder:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    BOOL result = YES;

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewCanBecomeFirstResponder:)])
    {
        result = [secondary customKeyboardResponderViewCanBecomeFirstResponder:view];
    }

    return result;
}

- (UIView*)            inputViewForCustomKeyboardResponderView:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    UIView* result = nil; // We might want to make this depend on something

    // Let the original delegate replace our picker view
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(inputViewForCustomKeyboardResponderView:)])
    {
        result = [secondary inputViewForCustomKeyboardResponderView:view];
        // TODO: Add sanity checks on input view configuration:
        // - has to be a picker view, no delegate setup? Or should we proxy it?
    }

    return result;
}

- (UIView*)   inputAccessoryViewForCustomKeyboardResponderView:(AKACustomKeyboardResponderView*)view
{
    (void)view;
    NSParameterAssert(view == self.triggerView);

    return self.inputAccessoryView;
}

#pragma mark Key Input Protocol Support

- (BOOL)                    customKeyboardResponderViewHasText:(AKACustomKeyboardResponderView*)view
{
    BOOL result = YES;

    NSParameterAssert(view == self.triggerView);
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewHasText:)])
    {
        result = [secondary customKeyboardResponderViewHasText:view];
    }

    return result;
}

- (void)                           customKeyboardResponderView:(AKACustomKeyboardResponderView*)view
                                                    insertText:(NSString *)text
{
    NSParameterAssert(view == self.triggerView);
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderView:insertText:)])
    {
        [secondary customKeyboardResponderView:view insertText:text];
    }
}

- (void)             customKeyboardResponderViewDeleteBackward:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);
    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewDeleteBackward:)])
    {
        [secondary customKeyboardResponderViewDeleteBackward:view];
    }
}

#pragma mark First Responder Support

- (BOOL) customKeyboardResponderViewShouldBecomeFirstResponder:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    BOOL result = [self shouldResponderActivate:view];

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewCanBecomeFirstResponder:)])
    {
        result = [secondary customKeyboardResponderViewCanBecomeFirstResponder:view];
    }

    return result;
}

- (void)   customKeyboardResponderViewWillBecomeFirstResponder:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewWillBecomeFirstResponder:)])
    {
        [secondary customKeyboardResponderViewWillBecomeFirstResponder:view];
    }

    [self responderWillActivate:view];
}

- (void)    customKeyboardResponderViewDidBecomeFirstResponder:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    [self responderDidActivate:view];

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewDidBecomeFirstResponder:)])
    {
        [secondary customKeyboardResponderViewDidBecomeFirstResponder:view];
    }

    /* Failed attempt to fix resizing of keyboard after rotation to landscape (didn't work, not fixed yet)
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(deviceOrientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
     */
}

- (BOOL) customKeyboardResponderViewShouldResignFirstResponder:(AKACustomKeyboardResponderView*)view
{
    BOOL result = YES;

    NSParameterAssert(view == self.triggerView);

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewShouldResignFirstResponder:)])
    {
        result = [secondary customKeyboardResponderViewShouldResignFirstResponder:view];
    }

    return result;
}

- (void)   customKeyboardResponderViewWillResignFirstResponder:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    [self responderWillDeactivate:view];

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewWillResignFirstResponder:)])
    {
        [secondary customKeyboardResponderViewWillResignFirstResponder:view];
    }
}

- (void)    customKeyboardResponderViewDidResignFirstResponder:(AKACustomKeyboardResponderView*)view
{
    NSParameterAssert(view == self.triggerView);

    /* TODO: remove once the keyboard device-rotation bug is fixed:
     [[NSNotificationCenter defaultCenter] removeObserver:self
     name:UIDeviceOrientationDidChangeNotification
     object:nil];*/

    [self responderDidDeactivate:view];

    id<AKACustomKeyboardResponderDelegate> secondary = self.savedTriggerViewDelegate;
    if ([secondary respondsToSelector:@selector(customKeyboardResponderViewDidResignFirstResponder:)])
    {
        [secondary customKeyboardResponderViewDidResignFirstResponder:view];
    }
}

/* TODO: remove once the keyboard device-rotation bug is fixed:
- (void)deviceOrientationChanged:(NSNotification*)notification
{
    // Not working:
    //[self.pickerView.superview setNeedsLayout];
    //[self.pickerView.superview layoutIfNeeded];
}
*/

@end