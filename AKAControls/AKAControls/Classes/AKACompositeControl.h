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

- (BOOL)                                     insertControl:(AKAControl*)control
                                                   atIndex:(NSUInteger)index;

- (AKAControl*)                       createControlForView:(UIView*)view
                                         withConfiguration:(AKAControlConfiguration*)configuration;

- (BOOL)                              removeControlAtIndex:(NSUInteger)index;

- (NSUInteger)                           removeAllControls;

- (void)                            moveControlFromIndex:(NSUInteger)fromIndex
                                                 toIndex:(NSUInteger)toIndex;

@end


@interface AKACompositeControl(KeyboardActivationSequence)

- (AKAKeyboardActivationSequence*)keyboardActivationSequence;

@end


@interface AKACompositeControl(MemberAccess)

#pragma mark - Accessing Members

- (NSUInteger)                             countOfControls;

- (id)                             objectInControlsAtIndex:(NSUInteger)index;

- (NSUInteger)                              indexOfControl:(AKAControl*)control;

- (void)                      enumerateControlsUsingBlock:(void(^)(req_AKAControl          control,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block;

- (void)                      enumerateControlsUsingBlock:(void(^)(req_AKAControl          control,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block
                                               startIndex:(NSUInteger)startIndex
                                          continueInOwner:(BOOL)continueInOwner;

- (void)           enumerateControlsRecursivelyUsingBlock:(void(^)(req_AKAControl          control,
                                                                   opt_AKACompositeControl owner,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block;

- (void)           enumerateControlsRecursivelyUsingBlock:(void(^)(req_AKAControl          control,
                                                                   req_AKACompositeControl owner,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block
                                               startIndex:(NSUInteger)startIndex
                                          continueInOwner:(BOOL)continueInOwner;

- (void)                  enumerateLeafControlsUsingBlock:(void(^)(req_AKAControl          control,
                                                                   req_AKACompositeControl owner,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block;

- (void)                  enumerateLeafControlsUsingBlock:(void(^)(req_AKAControl          control,
                                                                   req_AKACompositeControl owner,
                                                                   NSUInteger              index,
                                                                   outreq_BOOL             stop))block
                                               startIndex:(NSUInteger)startIndex
                                          continueInOwner:(BOOL)continueInOwner;

@end


@interface AKACompositeControl(MemberAdditionAndRemoval)

- (BOOL)                                                  addControl:(AKAControl*)control;

- (BOOL)                                               removeControl:(AKAControl*)control;

- (NSUInteger)             addControlsForControlViewsInViewHierarchy:(UIView*)rootView;
- (NSUInteger)          insertControlsForControlViewsInViewHierarchy:(UIView*)rootView
                                                             atIndex:(NSUInteger)index;

/**
 * Called by createControlForView:withConfiguration: when a new composite control was
 * created. The new composite control can prevent recursive addition of controls and bindings
 * that would otherwise be added to the composite control. This is required to prevent
 * prototyp (template) views represented by composite controls to create a control hierarchy
 * for their content.
 *
 * The default implementation calls @c addControlsForControlViewSubviewsInViewHierarchy:
 *
 * @param controlView the composite controls content view.
 *
 * @return the number of controls added.
 */
- (NSUInteger)  autoAddControlsForControlViewSubviewsInViewHierarchy:(UIView*)controlView;

- (NSUInteger)      addControlsForControlViewSubviewsInViewHierarchy:(UIView*)rootView;

- (NSUInteger)   insertControlsForControlViewSubviewsInViewHierarchy:(UIView*)rootView
                                                             atIndex:(NSUInteger)index;

- (void)                addControlsForControlViewsInOutletCollection:(NSArray*)outletCollection;
- (void)             insertControlsForControlViewsInOutletCollection:(NSArray*)outletCollection
                                                             atIndex:(NSUInteger)index;

- (void)               addControlsForControlViewsInOutletCollections:(NSArray<NSArray*>*)arrayOfOutletCollections;
- (void)            insertControlsForControlViewsInOutletCollections:(NSArray<NSArray*>*)arrayOfOutletCollections
                                                             atIndex:(NSUInteger)index;

- (void)                 addControlsForControlViewsInStaticTableView:(UITableView*)tableView
                                                          dataSource:(id<UITableViewDataSource>)dataSource;
- (void)              insertControlsForControlViewsInStaticTableView:(UITableView*)tableView
                                                          dataSource:(id<UITableViewDataSource>)dataSource
                                                             atIndex:(NSUInteger)index;

@end



@interface AKACompositeControl (DelegatePropagation)
@end
