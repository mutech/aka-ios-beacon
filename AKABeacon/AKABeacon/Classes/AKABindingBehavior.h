 //
//  AKABindingBehavior.h
//  AKABeacon
//
//  Created by Michael Utech on 13.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
#import "AKAProperty.h"
#import "AKAControlDelegate.h"
#import "AKABindingController.h"


@protocol AKABindingBehaviorDelegate <AKABindingControllerDelegate>
// See AKABindingControllerDelegate

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
+ (void)addToViewController:(req_UIViewController)viewController;

/**
 Enables binding support for the specified viewController by creating a binding bahvior instance suitable for the specified view controller and adding it as child view controller.

 Bindings will use the specified dataContext and delegate.

 This should be called from the viewDidLoad: method of the viewController to ensure that the viewController's view hierarchy is loaded and that the behavior will receive life cycle events that trigger binding initializations. If the behavior is added after the viewController's viewWillAppear: or viewDidAppear: methods have been called before, the behavior will not initialize and activate bindings, and would require you to call its life cycle methods manually to update its life cycle state.

 @param viewController  the view controller to add this behavior.
 @param dataContext     the data context, used for resolving key paths in binding expressions
 @param delegate        the delegate receiving binding behavior (and thus control-) delegate messages
 */
+ (void)addToViewController:(req_UIViewController)viewController
            withDataContext:(req_id)dataContext
                   delegate:(id<AKABindingBehaviorDelegate>_Nullable)delegate;

#pragma mark - Activation

- (void)addToViewController:(req_UIViewController)viewController;

- (void)removeFromViewController:(req_UIViewController)viewController;

#pragma mark - Auxiliary Observations

- (void)addObservation:(req_AKAProperty)property;

- (void)removeObservation:(req_AKAProperty)property;

/**
 Observes changes of the target's key path and calls the specified block whenever a change occurs.

 The observation will be activated when the view controller appears (by binding behavior's viewWillAppear)
 and will be deactivated when it disappears (binding behavior's viewWillDisappear).

 The AKAProperty returned is owned by the binding behavior. You can keep a reference to the property
 and manually call startObservingChanges or stopObservingChanges to control individual observations.
 
 You can also remove the observation using the removeObservation: method.

 @param target         the KVO target. Please note that the property keeps only a weak reference to the target.
 @param keyPath        the key path to observer
 @param didChangeValue the change observer block

 @return An instance of AKAProperty controlling the observation or nil if the view controller does not have a binding behavior.
 */
- (opt_AKAProperty)observeWeakTarget:(opt_NSObject)target
                             keyPath:(req_NSString)keyPath
                   changesUsingBlock:(void(^_Nonnull)(id _Nullable oldValue, id _Nullable newValue))didChangeValue;


/**
 Attempts to identify a view associated with the specified sender and then locates the binding controller managing bindings for that view and returns its data context.
 
 @note this mechanism is not (yet) covering all UIKit sender types. If it works for you, it will work in the future, if it does not work, please file an issue at https://github/mutech/aka-ios-beacon

 Supported sender types (as of now): UIView, UIGestureRecognizer

 @param sender an object, typically the sender of an IBAction, that is (or is associated) with a view hierarchy that is managed by the behavior's binding controller or one of its child binding controllers.

 @return the senders associated data context or nil if no binding controller could be found.
 */
- (opt_id)dataContextForSender:(req_id)sender;

@end



@interface UIViewController(AKABindingBehavior)

@property(nonatomic, readonly, nullable) AKABindingBehavior* aka_bindingBehavior;

@end
