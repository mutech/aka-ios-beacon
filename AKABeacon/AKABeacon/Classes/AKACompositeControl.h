//
//  AKACompositeControl.h
//  AKABeacon
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;

#import "AKAControl.h"
#import "AKAControlConfiguration.h"

@class AKAKeyboardActivationSequence;


@interface AKACompositeControl: AKAControl<AKAControlDelegate>

#pragma mark - Adding and Removing Member Controls

- (BOOL)                                        insertControl:(req_AKAControl)control
                                                      atIndex:(NSUInteger)index;

- (req_AKAControl)                           createControlForView:(UIView*_Nonnull)view
                                            withConfiguration:(AKAControlConfiguration*_Nullable)configuration;

- (BOOL)                                 removeControlAtIndex:(NSUInteger)index;

- (NSUInteger)                              removeAllControls __unused;

- (void)                                 moveControlFromIndex:(NSUInteger)fromIndex
                                                      toIndex:(NSUInteger)toIndex;

@end


@interface AKACompositeControl(KeyboardActivationSequence)

- (AKAKeyboardActivationSequence*_Nullable) keyboardActivationSequence;

@end


@interface AKACompositeControl(MemberAccess)

#pragma mark - Accessing Members

- (NSUInteger)                             countOfControls;

- (req_id)                             objectInControlsAtIndex:(NSUInteger)index;

- (NSUInteger)                              indexOfControl:(req_AKAControl)control;

- (void)                      enumerateControlsUsingBlock:(void(^_Nonnull)(req_AKAControl          control,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block;

- (void)                      enumerateControlsUsingBlock:(void(^_Nonnull)(req_AKAControl          control,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block
                                               startIndex:(NSUInteger)startIndex
                                          continueInOwner:(BOOL)continueInOwner;

- (void)           enumerateControlsRecursivelyUsingBlock:(void(^_Nonnull)(req_AKAControl          control,
                                                                   opt_AKACompositeControl owner,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block;

- (void)           enumerateControlsRecursivelyUsingBlock:(void(^_Nonnull)(req_AKAControl          control,
                                                                   req_AKACompositeControl owner,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block
                                               startIndex:(NSUInteger)startIndex
                                          continueInOwner:(BOOL)continueInOwner;

- (void)                  enumerateLeafControlsUsingBlock:(void(^_Nonnull)(req_AKAControl          control,
                                                                   req_AKACompositeControl owner,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block __unused;

- (void)                  enumerateLeafControlsUsingBlock:(void(^_Nonnull)(req_AKAControl          control,
                                                                   req_AKACompositeControl owner,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block
                                               startIndex:(NSUInteger)startIndex
                                          continueInOwner:(BOOL)continueInOwner;

@end


@interface AKACompositeControl(MemberAdditionAndRemoval)

+ (opt_NSArray)             viewsToExcludeFromScanningViewController:(opt_UIViewController)viewController;

- (BOOL)                                                  addControl:(req_AKAControl)control __unused;

- (BOOL)                                               removeControl:(req_AKAControl)control;

- (NSUInteger)             addControlsForControlViewsInViewHierarchy:(opt_UIView)rootView
                                                        excludeViews:(opt_NSArray)childControllerViews;

- (NSUInteger)          insertControlsForControlViewsInViewHierarchy:(opt_UIView)rootView
                                                             atIndex:(NSUInteger)index
                                                        excludeViews:(opt_NSArray)childControllerViews;

/**
 * Called by createControlForView:withConfiguration: when a new composite control was
 * created. The new composite control can prevent recursive addition of controls and bindings
 * that would otherwise be added to the composite control. This is required to prevent
 * prototype (template) views represented by composite controls to create a control hierarchy
 * for their content.
 *
 * The default implementation calls @c addControlsForControlViewSubviewsInViewHierarchy:
 *
 * @param controlView the composite controls content view.
 *
 * @return the number of controls added.
 */
- (NSUInteger)  autoAddControlsForControlViewSubviewsInViewHierarchy:(opt_UIView)controlView
                                                        excludeViews:(opt_NSArray)childControllerViews;

- (NSUInteger)      addControlsForControlViewSubviewsInViewHierarchy:(opt_UIView)rootView
                                                        excludeViews:(opt_NSArray)childControllerViews;

- (NSUInteger)   insertControlsForControlViewSubviewsInViewHierarchy:(opt_UIView)rootView
                                                             atIndex:(NSUInteger)index
                                                        excludeViews:(opt_NSArray)childControllerViews;

- (void)                addControlsForControlViewsInOutletCollection:(NSArray<UIView*>*_Nullable)outletCollection
                                                        excludeViews:(opt_NSArray)childControllerViews;

- (void)             insertControlsForControlViewsInOutletCollection:(NSArray<UIView*>*_Nullable)outletCollection
                                                             atIndex:(NSUInteger)index
                                                        excludeViews:(opt_NSArray)childControllerViews;

- (void)               addControlsForControlViewsInOutletCollections:(NSArray<NSArray<UIView*>*>*_Nullable)arrayOfOutletCollections
                                                        excludeViews:(opt_NSArray)childControllerViews;

- (void)            insertControlsForControlViewsInOutletCollections:(NSArray<NSArray<UIView*>*>*_Nullable)arrayOfOutletCollections
                                                             atIndex:(NSUInteger)index
                                                        excludeViews:(opt_NSArray)childControllerViews;

- (void)                 addControlsForControlViewsInStaticTableView:(opt_UITableView)tableView
                                                          dataSource:(id<UITableViewDataSource>_Nullable)dataSource
                                                        excludeViews:(opt_NSArray)childControllerViews;

- (void)              insertControlsForControlViewsInStaticTableView:(UITableView*_Nullable)tableView
                                                          dataSource:(id<UITableViewDataSource>_Nullable)dataSource
                                                             atIndex:(NSUInteger)index
                                                        excludeViews:(opt_NSArray)childControllerViews;

@end


@interface AKACompositeControl (DelegatePropagation)

- (void)                  controlWillInsertMemberControls:(req_AKACompositeControl)compositeControl;

- (void)             controlDidEndInsertingMemberControls:(req_AKACompositeControl)compositeControl;

@end
