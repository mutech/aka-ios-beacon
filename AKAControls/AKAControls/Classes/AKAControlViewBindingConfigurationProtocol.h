//
//  AKAControlViewBindingConfigurationProtocol.h
//  AKAControls
//
//  Created by Michael Utech on 19.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Specifies parameters for control-view bindings. Specific control view binding implementations
 * will extend
 */
@protocol AKAControlViewBindingConfigurationProtocol <NSObject>

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

@end
