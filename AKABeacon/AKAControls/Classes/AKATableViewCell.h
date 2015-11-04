//
//  AKATableViewCell.h
//  AKABeacon
//
//  Created by Michael Utech on 25.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAControlViewProtocol.h"


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
@property(nonatomic) IBInspectable NSString* controlRole;

#pragma mark - Outlets

@end

