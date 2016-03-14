//
//  AKABindingBehavior.h
//  AKABeacon
//
//  Created by Michael Utech on 13.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
#import "AKAControlDelegate.h"

@class AKAFormControl;
@class AKABindingBehavior;


@protocol AKABindingBehaviorDelegate <AKAControlDelegate>
// See AKAControlDelegate
@end


/**
 * The binding behavior is used as child view controller to add binding support to its parent view controller.
 *
 * Use addToViewController:withDataSource:delegate to enable binding support for a view controller with a custom data context (view model) and delegate.
 *
 * Use addToViewController: to enable binding support for a view controller that is itself also used as data context and if it conforms to AKABindingBehaviorDelegate also as delegate.
 *
 * The behavior will receive view controller life cycle events along with its parent view controller and manage bindings accordingly.
 *
 * If the parent view controller has a property scrollView, the scrollView will be used to scroll first responders into the visible area of the screen if appropriate.
 */
@interface AKABindingBehavior : UIViewController

#pragma mark - Initialization

/**
 Enables binding support for the specified viewController by creating a binding bahvior instance suitable for the specified view controller and adding it as child view controller.
 
 Bindings will use the viewController as data context.
 
 If the viewController conforms to the AKABindingBehaviorDelegate protocol, it will be used as delegate.
 
 This should be called from the viewDidLoad: method of the viewController to ensure that the viewController's view hierarchy is loaded and that the behavior will receive life cycle events that trigger binding initializations. If the behavior is added after the viewController's viewWillAppear: or viewDidAppear: methods have been called before, the behavior will not initialize and activate bindings, and would require you to call its life cycle methods manually to update its life cycle state.

 @param viewController  the view controller also serving as binding data context and delegate (if it's conforming to AKABindingBehaviorDelegate).
 */
+ (void)addToViewController:(UIViewController*)viewController;

/**
 Enables binding support for the specified viewController by creating a binding bahvior instance suitable for the specified view controller and adding it as child view controller.

 Bindings will use the specified dataContext and delegate.

 This should be called from the viewDidLoad: method of the viewController to ensure that the viewController's view hierarchy is loaded and that the behavior will receive life cycle events that trigger binding initializations. If the behavior is added after the viewController's viewWillAppear: or viewDidAppear: methods have been called before, the behavior will not initialize and activate bindings, and would require you to call its life cycle methods manually to update its life cycle state.

 @param viewController  the view controller to add this behavior.
 @param dataContext     the data context, used for resolving key paths in binding expressions
 @param delegate        the delegate receiving binding behavior (and thus control-) delegate messages
 */
+ (void)addToViewController:(UIViewController*)viewController
            withDataContext:(id)dataContext
                   delegate:(id<AKABindingBehaviorDelegate>)delegate;

#pragma mark - Activation

- (void)addToViewController:(UIViewController*)viewController;

- (void)removeFromViewController:(UIViewController*)viewController;

@end