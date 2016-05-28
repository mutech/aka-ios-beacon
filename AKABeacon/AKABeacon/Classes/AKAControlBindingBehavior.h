//
//  AKAControlBindingBehavior.h
//  AKABeacon
//
//  Created by Michael Utech on 24.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

// New and obsolete: Support AKAFormControl based binding behavior until AKAControl's are completely replaced by AKABindingController's and can be removed.

@import UIKit;
#import "AKAProperty.h"
#import "AKAControlDelegate.h"

@class AKAFormControl;
@class AKABindingBehavior;


@protocol AKAControlBindingBehaviorDelegate <AKAControlDelegate>
// See AKAControlDelegate
@end


@interface AKAControlBindingBehavior : UIViewController

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
                   delegate:(id<AKAControlBindingBehaviorDelegate>_Nullable)delegate;

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


@end


@interface UIViewController(AKAControlBindingBehavior)

@property(nonatomic, readonly, nullable) AKABindingBehavior* aka_controlBindingBehavior;

@end