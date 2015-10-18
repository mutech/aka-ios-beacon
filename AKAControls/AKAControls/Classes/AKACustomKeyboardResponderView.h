//
//  AKACustomKeyboardResponderView.h
//  AKAControls
//
//  Created by Michael Utech on 02.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAControlViewProtocol.h"

@protocol AKACustomKeyboardResponderDelegate;


/**
 * Plain UIView subclass implementing UIResponder methods such that the view can
 * become first responder and use a custom input view as keyboard. The behavior is
 * controlled by a delegate which provides the concrete implementations for the
 * overridden methods and receives notifications when the view becomes or resigns
 * first responder.
 *
 * @sa AKACustomKeyboardResponderDelegate
 */
@interface AKACustomKeyboardResponderView : UIView<AKAControlViewProtocol>

#pragma mark - IB Binding Properties

@property(nonatomic) IBInspectable BOOL tapToOpen;

#pragma mark - Control Configuration

- (void)setupControlConfiguration:(AKAMutableControlConfiguration*)controlConfiguration;

#pragma mark - Outlets

/**
 * The delegate which defines the keyboard related behavior of the view and
 * optionally controls and monitors its first responder state.
 */
@property(nonatomic, weak) IBOutlet id<AKACustomKeyboardResponderDelegate> delegate;

/**
 * The tap gesture recognizer to use for "tapToOpen". If not specified,
 * setting tapToOpen to YES will create a new tap gesture recognizer.
 *
 * @note A manually specified tap gesture recognizer should be
 *      connected to the action becomeFirstResponderForSender. This view will only connect the recognizer if it created it.
 */
@property(nonatomic, strong) IBOutlet UITapGestureRecognizer* tapToOpenGestureRecognizer;

#pragma mark - Actions

/**
 * Makes the view first responder, if both canBecomeFirstResponder and
 * shouldBecomeFirstResponder return YES.
 *
 * @param sender the sender
 */
- (IBAction)becomeFirstResponderForSender:(id)sender;

#pragma mark - UIResponder redefinitions

/**
 * Determines if the view should become first responder. This returns YES, if
 * canBecomeFirstResponder returns YES and if the delegate (if defined) returns
 * YES for customKeyboardResponderViewShouldBecomeFirstResponder:
 *
 * @return YES if the view should become first responder.
 */
- (BOOL)shouldBecomeFirstResponder;

@end


/**
 * A delegate which defines the keyboard related behavior of a @c AKACustomKeyboardResponderView and optionally controls and monitors its first responder state.
 * @sa AKACustomKeyboardResponderView
 */
@protocol AKACustomKeyboardResponderDelegate <NSObject>

@optional
/**
 * Determines the result of the specified views canBecomeFirstResponder method.
 *
 * @param view a view using this delegate.
 *
 * @return YES if the view can become first responder.
 */
- (BOOL)    customKeyboardResponderViewCanBecomeFirstResponder:(AKACustomKeyboardResponderView*)view;

@optional
/**
 * The view that the specified view should return as as result of its inputView method.
 *
 * @param view a view using this delegate.
 *
 * @return the view that the specified view should return as result of its inputView method.
 */
- (UIView*)            inputViewForCustomKeyboardResponderView:(AKACustomKeyboardResponderView*)view;

@optional
/**
 * The view that the specified view should return as as result of its inputAccessoryView method. If the delegate does not implement this method, the view will return the result of its super class implementation of inputAccessoryView.
 *
 * @param view a view using this delegate.
 *
 * @return the view that the specified view should return as result of its inputAccessoryView method.
 */
- (UIView*)   inputAccessoryViewForCustomKeyboardResponderView:(AKACustomKeyboardResponderView*)view;

#pragma mark - Key Input Protocol

@optional
/**
 * Determines the result of the specified view's hasText method. If not implemented, the view returns
 * YES.
 *
 * @param view a view using this delegate
 *
 * @return the value that the view should return in hasText
 */
- (BOOL)                    customKeyboardResponderViewHasText:(AKACustomKeyboardResponderView*)view;

@optional
/**
 * Called by the specified view when its insertText method is called.
 *
 * @param view a view using this delegate
 * @param text the text send to the views insertText method.
 */
- (void)                           customKeyboardResponderView:(AKACustomKeyboardResponderView*)view
                                                    insertText:(NSString *)text;

@optional
/**
 * Called by the specified view when its deleteBackward method is called.
 *
 * @param view a view using this delegate
 */
- (void)             customKeyboardResponderViewDeleteBackward:(AKACustomKeyboardResponderView*)view;

#pragma mark - Controlling and observing first responder status

@optional
/**
 * Determines if the specified view should become first responder. If the delegate method is not
 * defined, the result of the views canBecomeFirstResponder method is assumed.
 *
 * @param view a view using this delegate
 *
 * @return YES to allow the view to become first responder, NO to prevent it from becoming first responder.
 */
- (BOOL) customKeyboardResponderViewShouldBecomeFirstResponder:(AKACustomKeyboardResponderView*)view;

@optional
/**
 * Called by the specified view before it becomes first responder.
 *
 * @param view a view using this delegate.
 */
- (void)   customKeyboardResponderViewWillBecomeFirstResponder:(AKACustomKeyboardResponderView*)view;

@optional
/**
 * Called by the specified view right after becoming first responder (and only if the views
 * super classes implementation of becomeFirstResponder returned YES).
 *
 * @param view a view using this delegate.
 */
- (void)    customKeyboardResponderViewDidBecomeFirstResponder:(AKACustomKeyboardResponderView*)view;

@optional
/**
 * Determines if the specified view should resign first responder. If the delegate method
 * is not defined, YES is assumed.
 *
 * @param view a view using this delegate
 *
 * @return YES to allow the view to resign first responder, NO to prevent it from resigning first responder.
 */
- (BOOL) customKeyboardResponderViewShouldResignFirstResponder:(AKACustomKeyboardResponderView*)view;

@optional
/**
 * Called by the specified view before it resigns first responder.
 *
 * @param view a view using this delegate.
 */
- (void)   customKeyboardResponderViewWillResignFirstResponder:(AKACustomKeyboardResponderView*)view;

@optional
/**
 * Called by the specified view right after resigning first responder (and only if the views
 * super classes implementation of resignFirstResponder returned YES).
 *
 * @param view a view using this delegate.
 */
- (void)    customKeyboardResponderViewDidResignFirstResponder:(AKACustomKeyboardResponderView*)view;

@end
