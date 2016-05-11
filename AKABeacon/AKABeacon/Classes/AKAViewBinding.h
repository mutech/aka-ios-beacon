//
//  AKAViewBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKABinding.h"
#import "AKAViewBindingDelegate.h"

/**
 * Abstract base class for bindings which target views.
 */
@interface AKAViewBinding: AKABinding

#pragma mark - Initialization

/**
 Creates a new binding based for the specified arguments.

 @param targetView        the target view
 @param bindingExpression the view or conditional binding expression
 @param bindingContext    the binding context
 @param delegate          the delegate
 @param error             error details

 @return Either an instance of an AKAViewBinding or AKAConditionalBinding which in turn has/may have a view binding at activeClause.binding
 */
+ (opt_AKABinding)bindingToView:(req_UIView)targetView
                 withExpression:(req_AKABindingExpression)bindingExpression
                        context:(req_AKABindingContext)bindingContext
                       delegate:(opt_AKABindingDelegate)delegate
                          error:(out_NSError)error;

@property(nonatomic, readonly, weak, nullable) UIView*                    view;
@property(nonatomic, readonly, weak, nullable) id<AKAViewBindingDelegate> delegate;

@end


