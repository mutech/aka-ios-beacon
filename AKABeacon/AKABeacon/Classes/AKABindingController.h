//
//  AKABindingController.h
//  AKABeacon
//
//  Created by Michael Utech on 18.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
#import "AKABindingControllerDelegate.h"
#import "AKABinding.h"


#pragma mark - AKABindingController Interface
#pragma mark -

@interface AKABindingController : NSObject <AKABindingDelegate>

#pragma mark - Initialization

+ (opt_instancetype)                     bindingControllerForViewController:(req_UIViewController)viewController
                                                            withDataContext:(opt_id)dataContext
                                                                   delegate:(opt_AKABindingControllerDelegate)delegate
                                                                      error:(out_NSError)error;

#pragma mark - Configuration

@property(nonatomic, readonly, weak, nullable) id<AKABindingControllerDelegate>delegate;

/**
 The parent binding controller or nil if this is the root binding controller.

 The root binding controller provides the data context referenced by scope `$root'. It's targetObjectHierarchy property is typically referencing a view controller.
 */
@property(nonatomic, readonly, weak, nullable) AKABindingController*        parent;

/**
 The target object hierarchy for which this controller manages bindings. This may be a view, a viewController or some other object that may serve as binding target object or container for such.

 Typically, the root binding controller references a view controller while child binding controllers manage independent or dynamic view hierarchies (like f.e. table view cells).
 */
@property(nonatomic, readonly, weak, nullable) id                           targetObjectHierarchy;

#pragma mark - Convenience Properties (computed)

/**
 targetObjectHierarchy, if it is an instance of UIView or otherwise viewController.view (may be nil).
 */
@property(nonatomic, weak, readonly, nullable) UIView*                      view;

/**
 targetObjectHierarchy, if it is an instance of UIViewController, parent.viewController if parent is not nil or nil otherwise.
 */
@property(nonatomic, weak, readonly, nullable) UIViewController*            viewController;

/**
 The data context used by bindings referencing key paths relative to the binding scope `$data'.

 @note The dataContext might be changed internally, do not assume that it's constant.

 @note This is a strong reference to ensure that observations will be valid during the live time of the binding controller.
 */
@property(nonatomic, readonly, nullable) id                                 dataContext;


#pragma mark - Access

/**
 Locates the closest binding controller with a targetObjectHierarchy that is (or contains) the specified view or one of its superviews and returns the controllers dataContext.

 @note This is used by [AKABindingBehavior +dataContextForSender:].

 @param view A view

 @return the data context of the binding controller managing bindings of the specified view or nil if no binding controller can be found for the view.
 */
- (opt_id)dataContextForView:(req_UIView)view;

/**
 Enumerates all bindings managed by this controller.
 
 @note bindings managed by child binding controllers are not enumerated.

 @param block Block with signature `void (^)(AKABinding* binding, BOOL** stop)`
 */
- (void)enumerateBindingsUsingBlock:(void (^_Nonnull)(AKABinding * _Nonnull, BOOL * _Nonnull))block;

- (void)enumerateBindingControllersUsingBlock:(void (^_Nonnull)(req_AKABindingController, outreq_BOOL))block;

#pragma mark - Change Tracking


/**
 Determines whether the binding controller is observing changes (dataContextProperty, bindings, childBindingControllers).
 */
@property(nonatomic, readonly) BOOL                                         isObservingChanges;

- (void)startObservingChanges;
- (void)stopObservingChanges;

@end
