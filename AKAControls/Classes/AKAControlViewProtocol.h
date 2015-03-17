//
//  AKAControlViewProtocol.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AKAControl;
@class AKACompositeControl;
@class AKAControlViewBinding;
@class AKAProperty;

@protocol AKAControlViewProtocol <NSObject>

@property(nonatomic, weak, readonly) AKAControlViewBinding* controlBinding;

- (AKAControlViewBinding*)bindToControl:(AKAControl*)control;

- (AKAControl*)createControlWithDataContext:(id)dataContext;

- (AKAControl*)createControlWithOwner:(AKACompositeControl *)owner;

#pragma mark - Interface Builder Properties

/**
 * Defines the role of a control in the context of its owner composite control.
 * The meaning and range of a role is determined by the owner. Roles are typically used
 * for layout and to identify a control, for example as label to hold a validation error
 * message.
 */
@property(nonatomic) IBInspectable NSString* role;

@end

@protocol AKAEditingControlViewProtocol <AKAControlViewProtocol>

#pragma mark - Interface Builder Properties

// Implementation Note: IB does not recognize IBInspectable properties
// in protocols, you have to redeclare the properties in your
// UIView implementation to be able to set it in IB.

/**
 * The key path refering to the controls model value relative to
 * the controls data context.
 */
@property(nonatomic) IBInspectable NSString* valueKeyPath;

@end