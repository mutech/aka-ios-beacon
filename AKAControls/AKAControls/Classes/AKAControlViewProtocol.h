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

/**
 * ControlViews are typically UIViews, but they might also represent things like the
 * title of a UIViewController.
 */
@protocol AKAControlViewProtocol <NSObject>

/**
 * The binding associating this control view with an AKAControl instance or nil
 * if the control view is not bound.
 */
@property(nonatomic, weak, readonly) AKAControlViewBinding* controlBinding;

/**
 * Binds the control view to the specified control. A control view can only be bound to
 * one control.
 *
 * @param control the control that should bound.
 */
- (AKAControlViewBinding*)bindToControl:(AKAControl*)control;

/**
 * Creates a new control suitable to manage this control view with the specified data context.
 *
 * @param dataContext an object that is KVC compliant with the key paths used in value bindings.
 */
- (AKAControl*)createControlWithDataContext:(id)dataContext;

/**
 * Creates a new control with the specified owner. The data context for value bindings is
 * provided by the new owner control.
 *
 * @param owner the composite control which will own the created control.
 */
- (AKAControl*)createControlWithOwner:(AKACompositeControl *)owner;

#pragma mark - Interface Builder Properties

// Implementation Note: IB does not recognize IBInspectable properties
// in protocols, you have to redeclare the properties in your
// UIView implementation to be able to set it in IB.

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