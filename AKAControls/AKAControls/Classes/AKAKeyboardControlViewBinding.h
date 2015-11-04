//
//  AKAKeyboardControlViewBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlViewBinding.h"
#import "AKAKeyboardControlViewBinding.h"
#import "AKAKeyboardControlViewBindingDelegate.h"
#import "AKAKeyboardActivationSequenceItemProtocol.h"

@interface AKAKeyboardControlViewBinding: AKAControlViewBinding

#pragma mark - Configuration

@property(nonatomic, readonly, weak) id<AKAKeyboardControlViewBindingDelegate> delegate;

#pragma mark - Binding Configuration

@property(nonatomic) BOOL liveModelUpdates;
@property(nonatomic) BOOL autoActivate;
@property(nonatomic) BOOL shouldParticipateInKeyboardActivationSequence;

@end


@interface AKAKeyboardControlViewBinding(Protected)

#pragma mark - Abstract methods

/**
 * Subclasses have to override the setter (setResponderInputAccessoryView:) unless 
 * self.view responds to the @c selector(setInputAccessoryView:).
 *
 * This is used by installInputAccessoryView: and restoreInputAccessoryView: 
 */
@property(nonatomic, nullable) UIView*                              responderInputAccessoryView;

#pragma mark - UIResponder Events

- (BOOL)                                    shouldResponderActivate:(req_UIResponder)responder;

- (void)                                      responderWillActivate:(req_UIResponder)responder;

- (void)                                       responderDidActivate:(req_UIResponder)responder;

- (BOOL)                                  shouldResponderDeactivate:(req_UIResponder)responder;

- (void)                                    responderWillDeactivate:(req_UIResponder)responder;

- (void)                                     responderDidDeactivate:(req_UIResponder)responder;


@end


@interface AKAKeyboardControlViewBinding(KeyboardActivationSequence)<AKAKeyboardActivationSequenceItemProtocol
>

/**
 * Determines if the binding's responder should participate in the keyboard
 * activation sequence.
 *
 * @return the default implementation returns true if responderForKeyboardActivationSequence
 *      is not @c nil
 */
@property(nonatomic, readonly) BOOL                                 shouldParticipateInKeyboardActivationSequence;

@property(nonatomic, readonly) BOOL                                 participatesInKeyboardActivationSequence;

@property(nonatomic, weak, readonly) AKAKeyboardActivationSequence* keyboardActivationSequence;

/**
 * The responder participating in the keyboard activation sequence.
 *
 * @return the default implementation returns self.view.
 */
@property(nonatomic, readonly) opt_UIResponder                      responderForKeyboardActivationSequence;

#pragma mark - Activation (First Responder)

/**
 * Determines if the bindings's responder is active.
 *
 * @return the default implementation returns YES if the bindings's responder isFirstResponder.
 */
@property(nonatomic, readonly)       BOOL                           isResponderActive;

/**
 * Activates the bindings's responder. The default implementation calls responderWillActivate
 * and then attempts to make the responder becomeFirstResponder. If that succeeds, it
 * calls responderDidActivate.
 *
 * @note: If you override this method, make sure that you call willActivate before the responder
 * becomes first responder, otherwise the keyboard actiation sequence will probably fail
 * to install the input accessory view in time.
 *
 * @return YES if the responder could be activated.
 */
- (BOOL)                                          activateResponder;

/**
 * Deactivates the bindings's responder. The default implementation calls responderWillDeactivate
 * and then attempts to make the responder resignFirstResponder. If that succeeds, it
 * calls responderDidDeactivate.
 *
 * @return YES if the responder could be deactivated.
 */
- (BOOL)                                        deactivateResponder;

#pragma mark - Input Accessory Installation

/**
 * Saves the responders current input accessory view and then installs the specified view using
 * setResponderInputAccessoryView:
 *
 * Please note that you typically have to override setResponderInputAccessoryView: unless the
 * responder is responding to the selector setInputAccessoryView:
 *
 * @param inputAccessoryView the input accessory view.
 *
 * @return YES if the input accessory was installed successfully.
 */
- (BOOL)                                  installInputAccessoryView:(req_UIView)inputAccessoryView;

/**
 * Restores a previously saved input accessory view of the responder.
 *
 * Please note that you typically have to override setResponderInputAccessoryView: unless the
 * responder is responding to the selector setInputAccessoryView:
 *
 * @return YES if the input accessory was restored successfully.
 */
- (BOOL)                                  restoreInputAccessoryView;

@end
