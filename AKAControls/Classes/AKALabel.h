//
//  AKALabel.h
//  AKACommons
//
//  Created by Michael Utech on 14.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAControlViewProtocol.h"

IB_DESIGNABLE
@interface AKALabel : UILabel<AKAControlViewProtocol>

#pragma mark - Interface Builder Properties

/**
 * Defines the role of a control in the context of its owner composite control.
 * The meaning and range of a role is determined by the owner. Roles are typically used
 * for layout and to identify a control, for example as label to hold a validation error
 * message.
 */
@property(nonatomic) IBInspectable NSString* role;

@property(nonatomic) IBInspectable NSString* textKeyPath;

@end
