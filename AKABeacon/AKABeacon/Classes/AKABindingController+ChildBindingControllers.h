//
//  AKABindingController+ChildBindingControllers.h
//  AKABeacon
//
//  Created by Michael Utech on 24.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController.h"

#pragma mark - AKABindingController(ChildBindingControllers) Interface
#pragma mark -

@interface AKABindingController(ChildBindingControllers)

#pragma mark - Managing Child Binding Controllers
/// @name      Managing Child Binding Controllers

/**
This should be called before createOrReuseBindingControllerForTargetObjectHierarchy:withDataContext:error: or removeBindingControllerForTargetObjectHierarchy:enqueForReuse: are called.

Enclosing these in begin- and endUpdatingChildControllers is required if createOrReuse might be called before remove for the same targetObjectHierarchy. That is, for example, the case when updating table views. Delegate methods tableView:willDisplayCell:forRowAtIndexPath may well be called before tableView:didEndDisplayCell:forRowAtIndexPath:.

In such cases, the binding controller will record pairs of removal and creation of child binding contents and will not remove a context that updated its data context in response to a previous createOrReuse call.
 */
- (void)beginUpdatingChildControllers;

/**
 See beginUpdatingChildControllers
 */
- (void)endUpdatingChildControllers;

/**
 Creates a new or reuses an existing child binding controller managing bindings for the specified targetObjectHierarchy (typically a view hierarchy) using the specified data context.

 The current binding controller will serve as parent binding context (which also means that this and the new binding controller will have the same root data context).

 If there already is a child binding controller for the specified view, then this controller will be returned. If the child binding controller's data context differs from the specified one, it will be updated. This may or may not involve bindings to be restarted.

 If a new binding controller has been created, it will scan the target object hierarchy for binding targets and create bindings for them. Otherwise the existing bindings will be reused.

 If this binding controller is observing changes, then the returned child controller will also start observing changes (if it did not already do).

 The primary use case for child binding contexts is to manage relatively independent view hierarchies which are bound to a different data context, like for example instances of UITableViewCell. Child controllers are typically created by delegate methods such as tableview:willDisplayCellForRowAtIndexPath: or tableview:willDisplayHeaderViewForSection:.

 @note Assumption: Changing the data context of a child binding controller (and thus the binding context of all related bindings) is sufficient to update the target object hierarchy correctly. If client code has to perform other manual initialization, it has to ensure that this is done indepently.

 @note If bindings create child binding controllers (f.e. the data source binding of a table view), then they have to remove all child controllers when they stop observing changes and have to be prepared to recreate them when they start observing changes. (TODO: verify once these bindings are refactored to use binding controllers).

 @note If an error occurs and the error parameter is nil, the controller might throw an exception.

 @param targetObjectHierarchy the root view (or target object) of the view hierarchy
 @param dataContext           the data context for bindings in the object hierarchy
 @param error                 error details

 @return a binding controller managing the specified targetObjectHierarchy's bindings using the specified data context or nil if an error occurred.
 */
- (opt_instancetype) createOrReuseBindingControllerForTargetObjectHierarchy:(req_id)targetObjectHierarchy
                                                            withDataContext:(opt_id)dataContext
                                                                      error:(out_NSError)error;

/**
 Removes (or recycles) a child binding controller with matching targetObjectHierarchy and dataContext.

 All bindings managed by the removed child binding controller will stop observing changes.

 If enqueForReuse is YES, the binding controller will attempt to preserve the removed child controller and its bindings to be able to reuse it for the same targetObjectHierarchy later on (this is only useful if targetObjectHierarchies are reused (such as UITableViewCell instances might be, if they have a defined reuse identifier and the table view data source supporting reuse).

 @note Even though the targetObjectHierarchy is a unique key for child controllers, a matching child controller is not removed if the data context does not also match. This is because the order in which delegate methods such as tableview:willDisplayCellForRowAtIndexPath: and tableview:didEndDisplayCellForRowAtIndexPath: is not always as expected (willDisplay for a new data context might preceed didEndDisplay for an old data context for one given cell).

 @param targetObjectHierarchy the target object (f.e view-) hierarchy
 @param enqueForReuse         determines if this binding context may preserve the child binding controller (and it's bindings) to be able to reuse it.

 @return YES if a matching child binding controller was found and removed.
 */
- (BOOL)                    removeBindingControllerForTargetObjectHierarchy:(req_id)targetObjectHierarchy
                                                              enqueForReuse:(BOOL)enqueueForReuse;

/**
 Removes or recycles all child binding controllers.
 
 This is called by stopObservingChanges and might be called by bindings that created this binding controller (for example a table view data source binding might wish to remove all dynamic bindings when reloading the table view).

 @param enqueueForReuse If YES, child bindings will be preserved if they are attached to target object hierarchies, otherwise all accessible child bindings will be discarded.
 */
- (void)                         removeAllBindingControllersEnqueueForReuse:(BOOL)enqueueForReuse;

/**
 Contains all currently active child binding controllers.

 Child binding controllers manage view hierarchies which (typically) use a different data context and/or are only loosely connected to the main view hierarchy, such as for example UITableViewCell or UICollectionViewCell instances.

 For reusable view hierarchies, such as table view cells, child binding contexts can also be reused which potentially saves the time to scan views for binding expressions and create bindings.

 @note the hash table references child controllers weakly. When creating a child binding controller, the target object hierarchy keeps the only strong reference to the binding controller to ensure that when the target gets released, the binding controller will stop observing changes and release the controller (also when it's enqueued for reuse).

 @see createOrReuseBindingControllerForTargetObjectHierarchy:withDataContext:error:
 @see removeBindingControllerForTargetObjectHierarchy:withDataContext:enqueueForReuse:
 */
//@property(nonatomic, readonly)       NSHashTable<AKABindingController*>*    childBindingControllers;

- (void)startObservingChangesInChildBindingControllers;
- (void)stopObservingChangesInChildBindingControllers;

#pragma mark - Access

/**
 Locates the closest binding controller with a targetObjectHierarchy that is (or contains) the specified view or one of its superviews.
 
 @param view A view

 @return the binding controller managing bindings of the specified view or nil if no binding controller can be found for the view.
 */
+ (opt_instancetype)bindingControllerManagingView:(req_UIView)view;

@end
