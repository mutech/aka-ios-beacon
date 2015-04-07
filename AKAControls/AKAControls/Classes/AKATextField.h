//
//  AKATextField.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAControlViewProtocol.h"
#import "AKATextFieldBinding.h"

IB_DESIGNABLE
@interface AKATextField: UITextField<AKAControlViewProtocol>

#pragma mark - Interface Builder properties
/// @name Interface Builder properties

/**
 * Configures the name of the control, which has to be unique in the scope of its owner
 * composite control or nil. Names are (not yet) used to address controls, for example
 * in (not yet implemented) extended binding expressions. Control view implementations
 * should mark the redeclaration of this property as IBInspectable.
 */
@property(nonatomic) IBInspectable NSString* controlName;

/**
 * Defines the role of a control in the context of its owner composite control.
 * The meaning and range of a role is determined by the owner. Roles are typically used
 * for layout and to identify a control, for example as label to hold a validation error
 * message. Control view implementations should mark the redeclaration of this property
 * as IBInspectable.
 */
@property(nonatomic) IBInspectable NSString* role;

/**
 * The key path refering to the controls model value relative to
 * the controls data context.
 */
@property(nonatomic) IBInspectable NSString* valueKeyPath;

/**
 * The key path refering to the converter used to convert between model and view values.
 *
 * @note Since converters are rarely defined relative to a controls data context,
 * it is preferrable to use the '$root' keypath extension to reference the top level
 * data context.
 */
@property(nonatomic) IBInspectable NSString* converterKeyPath;

/**
 * The key path refering to the validator used to validate model values.
 *
 * @note Since converters are rarely defined relative to a controls data context,
 * it is preferrable to use the '$root' keypath extension to reference the top level
 * data context.
 */
@property(nonatomic) IBInspectable NSString* validatorKeyPath;

@property(nonatomic) IBInspectable BOOL liveModelUpdates;
@property(nonatomic) IBInspectable BOOL autoActivate;
@property(nonatomic) IBInspectable BOOL KBActivationSequence;

@end
