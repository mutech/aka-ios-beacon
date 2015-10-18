//
// Created by Michael Utech on 08.09.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAControlViewProtocol.h"
#import "AKAThemableContainerView.h"

@interface AKAThemableCompositeControlView : AKAThemableContainerView<AKAControlViewProtocol>

#pragma mark - Configuration

@property(nonatomic, readonly) AKAControlConfiguration* aka_controlConfiguration;

#pragma mark - Interface Builder Properties

/**
 * Identifies the control in the scope of its owner (composite control).
 */
@property(nonatomic) IBInspectable NSString* controlName;

/**
 * A space separated list of tag names. Tag names are used to identify groups of controls.
 * A typical use case for tags is to hide, disable or highlight all controls which define
 * a tag. Tag names should be valid identifiers matching @c [a-z][a-zA-Z0-9_]*
 */
@property(nonatomic) IBInspectable NSString* controlTags;

/**
 * Defines the role of a control in the context of its owner (composite control).
 * The meaning and range of a role is determined by the owner. Roles are typically used
 * for layout and to identify a control, for example as label to hold a validation error
 * message.
 */
@property(nonatomic) IBInspectable NSString* controlRole;

@end

@interface AKAThemableCompositeControlView(Protected)

- (void)setupDefaultValues;

@end
