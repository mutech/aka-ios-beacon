//
//  AKATableViewCell.h
//  AKAControls
//
//  Created by Michael Utech on 25.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKAControlViewProtocol.h"
#import "AKACompositeViewBindingConfiguration.h"
#import "AKAViewBinding.h"

IB_DESIGNABLE
@interface AKATableViewCell : UITableViewCell<AKAControlViewProtocol>

#pragma mark - Interface Builder and Binding Configuration Properties

/**
 * Configures the name of the control, which has to be unique in the scope of its owner
 * composite control or nil. Names are (not yet) used to address controls, for example
 * in (not yet implemented) extended binding expressions. Control view implementations
 * should mark the redeclaration of this property as IBInspectable.
 */
@property(nonatomic) IBInspectable NSString* controlName;

/**
 * A space separated list of tag names. A tag name has to start with a
 * letter (A-Z, a-z) and can contain letters and digits (A-Z, a-z, 0-9).
 * By convention, tag names should start with a lower case letter.
 */
@property(nonatomic) IBInspectable NSString* controlTags;

/**
 * Defines the role of a control in the context of its owner composite control.
 * The meaning and range of a role is determined by the owner. Roles are typically used
 * for layout and to identify a control, for example as label to hold a validation error
 * message. Control view implementations should mark the redeclaration of this property
 * as IBInspectable.
 */
@property(nonatomic) IBInspectable NSString* role;

// TODO: Binding properties (valueKeyPath, converterKeyPath, validatorKeyPath)are not currently exposed.
// It's not yet clear how to map the "view value" for standard and custom cell types
// Deferred to a later version.

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
@property(nonatomic) /*IBInspectable*/ NSString* converterKeyPath;

/**
 * The key path refering to the validator used to validate model values.
 *
 * @note Since converters are rarely defined relative to a controls data context,
 * it is preferrable to use the '$root' keypath extension to reference the top level
 * data context.
 */
@property(nonatomic) /*IBInspectable*/ NSString* validatorKeyPath;

/**
 * Determines whether the control is restricted to display the model value and will
 * not change the model value as a result of user interactions. Setting this property
 * to YES will disable user interactions.
 */
@property(nonatomic) IBInspectable BOOL readOnly;

#pragma mark - Outlets

@end

@interface AKATableViewCellBindingConfiguration : AKACompositeViewBindingConfiguration

@end

@interface AKATableViewCellBinding: AKAViewBinding
@end
