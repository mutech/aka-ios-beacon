//
//  AKAViewBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKABinding.h"

/**
 * Abstract base class for bindings which target views.
 */
@interface AKAViewBinding: AKABinding

#pragma mark - Configuration

@property(nonatomic, readonly, weak) UIView*                view;

@end


@interface AKAViewBinding(Protected)

/**
 Abstract method that subclasses have to implement to return an AKAProperty instance
 that provides access to the binding target value.

 @param target the target view

 @return a property providing access to the binding target value.
 */
- (req_AKAProperty)      createBindingTargetPropertyForView:(req_UIView)target;

/**
 Called by initWithView:expression:context:delegate, this method can be used to validate
 the targetView and should throw an exception or fail with an assertion if the targetView
 is invalid.
 
 @param targetView the view to validate.
 */
- (void)                                 validateTargetView:(req_UIView)targetView;

@end


@interface AKAViewBinding(IBPropertySupport)

#pragma mark - Interface Builder Property Support

// TODO: move to AKAViewBinding

/**
 * Gets the binding expression text associated with the specified property selector
 * of the specified view.
 *
 * @param selector the selector of a binding properties getter. The selector name will be used for KVC access to the property value.
 * @param view the view providing the binding property.
 *
 * @return the text of the binding expression or nil if the binding property is undefined.
 */
+ (opt_NSString)           bindingExpressionTextForSelector:(req_SEL)selector
                                                     inView:(req_UIView)view;

/**
 * Associates the binding expression specified by the expression text with the specified
 * property select of the specified view. If the binding expression text is nil, the
 * binding property will be cleared.
 *
 * @warn Please note that an exception is thrown if the binding expression is invalid.
 *
 * @param bindingExpressionText A valid binding expression or nil.
 * @param selector the selector of a binding properties getter. The selector name will be used for KVC access to the property value.
 * @param view the view providing the binding property.
 */
+ (void)                           setBindingExpressionText:(opt_NSString)bindingExpressionText
                                                forSelector:(req_SEL)selector
                                                     inView:(req_UIView)view;

@end
