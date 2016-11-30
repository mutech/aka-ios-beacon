//
//  AKAPresentViewControllerOperation.h
//  AKABeacon
//
//  Created by Michael Utech on 03.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperation.h"

#pragma mark - AKAVCLifeCycleNotificationBehavior
#pragma mark -

@class AKAVCLifeCycleNotificationBehavior;


@protocol AKAVCLifeCycleNotificationBehaviorDelegate<NSObject>

@optional
- (void)           notificationBehavior:(nonnull AKAVCLifeCycleNotificationBehavior*)behavior
   didStartObservingEventsForController:(nonnull UIViewController*)controller;

@optional
- (void)      viewControllerViewDidLoad:(nullable UIViewController*)viewController;

@optional
- (void)                 viewController:(nullable UIViewController*)viewController
                         viewWillAppear:(BOOL)animated;

@optional
- (void)                 viewController:(nullable UIViewController*)viewController
                          viewDidAppear:(BOOL)animated;

@optional
- (void)                 viewController:(nullable UIViewController*)viewController
                      viewWillDisappear:(BOOL)animated;

@optional
- (void)                 viewController:(nullable UIViewController*)viewController
                       viewDidDisappear:(BOOL)animated;

@optional
- (void)  viewControllerWillBeDismissed:(nullable UIViewController*)viewController;

@optional
- (void) viewControllerHasBeenDismissed:(nullable UIViewController*)viewController;


@optional
- (void)           notificationBehavior:(nonnull AKAVCLifeCycleNotificationBehavior*)behavior
    didStopObservingEventsForController:(nonnull UIViewController*)controller;

@end


typedef NS_ENUM(NSUInteger, AKAVCLifeCycleState)
{
    AKAViewControllerLifeCycleStateUnknown,
    AKAViewControllerLifeCycleStateDidLoad,
    AKAViewControllerLifeCycleStateWillAppear,
    AKAViewControllerLifeCycleStateDidAppear,
    AKAViewControllerLifeCycleStateWillDisapear,
    AKAViewControllerLifeCycleStateWillBeDismissed,
    AKAViewControllerLifeCycleStateDidDisapear,
    AKAViewControllerLifeCycleStateHasBeenDismissed
};


@interface AKAVCLifeCycleNotificationBehavior: UIViewController

#pragma mark - Initialization

+ (nonnull AKAVCLifeCycleNotificationBehavior*)addToController:(nonnull UIViewController*)controller
                                                withDelegate:(nonnull id<AKAVCLifeCycleNotificationBehaviorDelegate>)delegate;

- (void)removeFromController:(nullable UIViewController*)controller;

#pragma mark - Configuration

@property(nonatomic, readonly, weak, nullable) id<AKAVCLifeCycleNotificationBehaviorDelegate>delegate;
@property(nonatomic, readonly) AKAVCLifeCycleState controllerState;

@end


#pragma mark - AKAPresentViewControllerOperation
#pragma mark -

@interface AKAPresentViewControllerOperation: AKAOperation<AKAVCLifeCycleNotificationBehaviorDelegate>

#pragma mark - Initialization

- (nonnull instancetype)initWithViewController:(nonnull UIViewController *)viewController
                           presentationContext:(nullable id)presenter;

/**
 Creates a new operation that will present the specified view controller from the specified presenter.

 If no presenter is specified, the operation will inspect the current key window and use it's root view controller (resolving UINavigationContoller and UITabBarController instances to their visible or selected view controllers).

 @param viewController  the view controller to be presented.
 @param presenter       the presenting view controller or nil to let the operation find a suitable view controller for presentation.

 @return a new operation
 */
+ (nonnull instancetype)operationForController:(nonnull UIViewController *)viewController
                           presentationContext:(nullable id)presenter;

#pragma mark - Configuration

/**
 Determines whether the operation will monitor life cycle events of the presented view controller.
 
 The default implementation returns YES.
 
 Since life cycle event monitoring adds a child view controller to the presented view controller, some implementations will not work (properly) with monitoring enabled, for example MFMailComposeViewController.

 Subclasses supporting such view controllers should redefine this method to return NO and use delegation or other means to determine when the presentation has finished.
 
 Such implementations have to call -viewControllerHasBeenDismissed: to notify the operation about the dismissal. Failure to do so will leave the operation in executing state (indefinitely).
 */
- (BOOL)shouldMonitorPresentedViewControllersLifeCycleEvents;

/**
 Determines whether the operation should create a presentation window if no presenter has been configured. If NO, the operation will use the current key window's rootViewController as presenter. (see presenter).
 
 The default implementation returns YES.
 */
- (BOOL)shouldCreatePresentationWindow;

@property(nonatomic, readonly, nonnull) UIViewController* viewController;

/**
 The presenting view controller.

 If the operation can tell that the presenter is not a proper view controller capable of presentation, it will recursively apply this algorithm to locate the presenting view controller:

 - If presenter is a view, the operation traverses the responder chain to locate its view controller.
 - If presenter is a UINavigationController, the operation uses its visibleViewController
 - If presenter is a UITabBarController, the operation uses its selectedViewController
 */
@property(nonatomic, readonly, nullable, weak) id presenter;

@property(nonatomic, readonly, nullable, weak) UIView* popoverAnchor;

@end
