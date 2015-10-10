//
//  AKATextFieldControlViewBinding.h
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAObsoleteViewBindingConfiguration.h"
#import "AKAObsoleteViewBinding.h"

#pragma mark - AKATextFieldBinding
#pragma mark -

/**
 * AKAControlViewAdapter implementation that can be used to bind AKATextField and other
 * UITextField subclasses to AKAControls.
 *
 * The binding uses the UITextFieldDelegate to observe view value changes.
 *
 * @bug Support for UITextField's is not yet implemented.
 */
@interface AKATextFieldBinding: AKAObsoleteViewBinding
@end

#pragma mark - AKATextFieldBindingConfiguration
#pragma mark -

/**
 * The default implementation of AKATextFieldControlViewBindingConfigurationProtocol
 * which is supposed to be used to configure bindings of UITextField instances which
 * are not AKATextField's.
 */
@interface AKATextFieldBindingConfiguration: AKAObsoleteViewBindingConfiguration

#pragma mark - Interface Builder Properties
/// @name Interface Builder Properties

/**
 * Determines whether changes the user makes while editing the views text
 * are immediately processed. If NO, changes will be processed as soon as the
 * view will resignFirstResponder (stops receiving keyboard input).
 *
 * @note If you enable this option, the keyboard plane (letters/numbers/symbols)
 * will reset to the default after each character typed.
 */
@property(nonatomic) /*IBInspectable*/ BOOL liveModelUpdates;

/**
 * Determines whether the view should automatically activate if the owner of the
 * bound control activates.
 */
@property(nonatomic) /*IBInspectable*/ BOOL autoActivate;

/**
 * Determines whether the view and thus its bound control should participate in
 * the keyboard activation sequence.
 */
@property(nonatomic) /*IBInspectable*/ BOOL KBActivationSequence;

@end


