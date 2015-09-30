//
//  AKAKeyboardActivationSequenceItemProtocol.h
//  AKAControls
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;


#pragma mark - AKAKeyboardActivationSequenceItemProtocol
#pragma mark -

@protocol AKAKeyboardActivationSequenceItemProtocol <NSObject>

#pragma mark - Configuration

- (BOOL) shouldParticipateInKeyboardActivationSequence;

@property(nonatomic, readonly, weak) opt_UIResponder   responderForKeyboardActivationSequence;

#pragma mark - Activation (First Responder)

@property(nonatomic, readonly)       BOOL              isResponderActive;

- (BOOL)                             activateResponder;

- (BOOL)                           deactivateResponder;

#pragma mark - Input Accessory Installation

- (BOOL)                     installInputAccessoryView:(req_UIView)inputAccessoryView;

- (BOOL)                     restoreInputAccessoryView;

@end

typedef id<AKAKeyboardActivationSequenceItemProtocol>               AKAKeyboardActivationSequenceItem;
typedef id<AKAKeyboardActivationSequenceItemProtocol> _Nullable     opt_AKAKeyboardActivationSequenceItem;
typedef id<AKAKeyboardActivationSequenceItemProtocol> _Nonnull      req_AKAKeyboardActivationSequenceItem;
