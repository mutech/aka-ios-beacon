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

#pragma mark - Initialization

- (instancetype _Nullable)                     initWithView:(req_UIView)targetView
                                                 expression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                                   delegate:(opt_AKABindingDelegate)delegate
                                                      error:(out_NSError)error;

#pragma mark - Configuration

@property(nonatomic, readonly, weak) UIView*                view;

@end


@interface AKAViewBinding(Protected)

/**
 * Abstract method that subclasses have to implement to return an AKAProperty instance
 * that provides access to the binding target value.
 *
 * @param target the target view
 *
 * @return a property providing access to the binding target value.
 */
- (req_AKAProperty)      createBindingTargetPropertyForView:(req_UIView)target;

/**
 * Called by initWithView:expression:context:delegate, this method can be used to validate
 * the targetView and should throw an exception or fail with an assertion if the targetView
 * is invalid.
 *
 * @param targetView the view to validate.
 */
- (void)validateTargetView:(req_UIView)targetView;

@end
