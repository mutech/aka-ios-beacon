//
//  AKACompositeControl.h
//  AKAControls
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl.h"

@class AKAKeyboardActivationSequence;

@interface AKACompositeControl : AKAControl<AKAControlDelegate>

#pragma mark - Initialization

#pragma mark - Member Controls

@property(nonatomic, readonly)NSArray* controls;

- (NSUInteger)indexOfControl:(AKAControl*)control;

- (void)enumerateControlsUsingBlock:(void(^)(AKAControl* control,
                                             NSUInteger index,
                                             BOOL* stop))block;

- (void)enumerateControlsUsingBlock:(void(^)(AKAControl* control,
                                             NSUInteger index,
                                             BOOL* stop))block
                         startIndex:(NSUInteger)startIndex
                    continueInOwner:(BOOL)continueInOwner;

- (void)enumerateLeafControlsUsingBlock:(void(^)(AKAControl* control,
                                                 AKACompositeControl* owner,
                                                 NSUInteger index,
                                                 BOOL* stop))block;

- (void)enumerateLeafControlsUsingBlock:(void(^)(AKAControl* control,
                                                 AKACompositeControl* owner,
                                                 NSUInteger index,
                                                 BOOL* stop))block
                             startIndex:(NSUInteger)startIndex
                        continueInOwner:(BOOL)continueInOwner;

#pragma mark Control Membership

- (BOOL)addControl:(AKAControl*)control;

- (BOOL)insertControl:(AKAControl*)control atIndex:(NSUInteger)index;

- (BOOL)removeControl:(AKAControl*)control;

- (BOOL)removeControlAtIndex:(NSUInteger)index;

- (NSUInteger)addControlsForControlViewsInViewHierarchy:(UIView*)rootView;
- (NSUInteger)insertControlsForControlViewsInViewHierarchy:(UIView*)rootView
                                                   atIndex:(NSUInteger)index;

- (NSUInteger)addControlsForControlViewsInOutletCollection:(NSArray*)outletCollection;
- (NSUInteger)insertControlsForControlViewsInOutletCollection:(NSArray*)outletCollection
                                                      atIndex:(NSUInteger)index;

- (NSUInteger)addControlsForControlViewsInOutletCollections:(NSArray*)arrayOfOutletCollections;
- (NSUInteger)insertControlsForControlViewsInOutletCollections:(NSArray*)arrayOfOutletCollections
                                                       atIndex:(NSUInteger)index;


- (NSUInteger)addControlsForControlViewsInStaticTableView:(UITableView*)tableView;
- (NSUInteger)insertControlsForControlViewsInStaticTableView:(UITableView*)tableView
                                                     atIndex:(NSUInteger)index;

#pragma mark - Activation

@property(nonatomic, readonly) AKAControl* activeControl;
@property(nonatomic, readonly) AKAControl* activeLeafControl;

@end

