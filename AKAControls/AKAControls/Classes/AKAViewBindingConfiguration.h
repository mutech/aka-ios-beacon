//
//  AKABindingConfiguration.h
//  AKAControls
//
//  Created by Michael Utech on 06.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Default implementation of the AKABindingConfigurationProtocol.
 *
 * Binding configurations specify how view, controls and model values are bound.
 * Control views (views implementing the AKAControlViewProtocol) also conform to
 * the AKABindingConfigurationProtocol and allow you to configure bindings
 * and controls from storyboards. This is, depending on your workflow, usually preferrable
 * to using separate view and configurations. However, if you have a reason not to want
 * to use control views, or if they are missing, binding configurations can be used
 * instead.
 */
@interface AKAViewBindingConfiguration: NSObject

#pragma mark - Structural configuration
/// @name Structural configuration

@property(nonatomic, readonly) Class preferredBindingType;

/**
 * The preferred UIView type that should be used for this configuration. The view type
 * is used to create views.
 *
 * @note Dynamic or data driven view creation is not yet implemented.
 * @note This property will probably be replaced by a more complex specification that supports creating and configuring view hierarchies.
 */
@property(nonatomic, readonly) Class preferredViewType;

/**
 * The preferred AKAControl type that should be used for this configuration. The
 * control type is used when creating a control hierarchy for existing views
 * (the most common case for static forms defined in story boards)
 */
@property(nonatomic, readonly) Class preferredControlType;

#pragma mark - Interface Builder properties
/// @name Interface Builder properties

/**
 * Configures the name of the control, which has to be unique in the scope of its owner
 * composite control or nil. Names are (not yet) used to address controls, for example
 * in (not yet implemented) extended binding expressions. Control view implementations
 * should mark the redeclaration of this property as IBInspectable.
 */
@property(nonatomic)/*IBInspectable*/ NSString* controlName;

/**
 * Defines the role of a control in the context of its owner composite control.
 * The meaning and range of a role is determined by the owner. Roles are typically used
 * for layout and to identify a control, for example as label to hold a validation error
 * message. Control view implementations should mark the redeclaration of this property
 * as IBInspectable.
 */
@property(nonatomic)/*IBInspectable*/ NSString* role;

/**
 * The key path refering to the controls model value relative to
 * the controls data context.
 */
@property(nonatomic)/*IBInspectable*/ NSString* valueKeyPath;

/**
 * The key path refering to the converter used to convert between model and view values.
 *
 * @note Since converters are rarely defined relative to a controls data context,
 * it is preferrable to use the '$root' keypath extension to reference the top level
 * data context.
 */
@property(nonatomic)/*IBInspectable*/ NSString* converterKeyPath;

/**
 * The key path refering to the validator used to validate model values.
 *
 * @note Since converters are rarely defined relative to a controls data context,
 * it is preferrable to use the '$root' keypath extension to reference the top level
 * data context.
 */
@property(nonatomic)/*IBInspectable*/ NSString* validatorKeyPath;

@end

