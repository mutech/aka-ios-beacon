//
//  AKAPickerViewBinding.h
//  AKAControls
//
//  Created by Michael Utech on 14.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAViewBinding.h"

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
@interface AKAPickerViewBinding : AKAViewBinding
@end

#pragma mark - AKATextFieldBindingConfiguration
#pragma mark -

/**
 * The default implementation of AKATextFieldControlViewBindingConfigurationProtocol
 * which is supposed to be used to configure bindings of UITextField instances which
 * are not AKATextField's.
 */
@interface AKAPickerBindingConfiguration: AKAViewBindingConfiguration

#pragma mark - Interface Builder Properties
/// @name Interface Builder Properties

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


@interface AKAPickerViewBindingConfiguration: AKAViewBindingConfiguration

@property(nonatomic, strong) /*IBInspectable*/ NSString* pickerValuesKeyPath;
@property(nonatomic, strong) /*IBInspectable*/ NSString* titleKeyPath;
@property(nonatomic, strong) /*IBInspectable*/ NSString* titleConverterKeyPath;
@property(nonatomic, strong) /*IBInspectable*/ NSString* otherValueTitle;
@property(nonatomic, strong) /*IBInspectable*/ NSString* undefinedValueTitle;

@end
