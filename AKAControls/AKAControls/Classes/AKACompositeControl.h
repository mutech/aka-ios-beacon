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

#pragma mark Access to Member Controls

@property(nonatomic, readonly)NSArray* controls;

- (NSUInteger)indexOfControl:(AKAControl*)control;

#pragma mark - Adding and Removing Member Controls

- (BOOL)insertControl:(AKAControl*)control atIndex:(NSUInteger)index;

- (NSUInteger)insertControl:(out AKAControl**)controlStorage
                    forView:(UIView*)view
          withConfiguration:(AKAViewBindingConfiguration*)configuration
                    atIndex:(NSUInteger)index;

- (BOOL)removeControlAtIndex:(NSUInteger)index;

#pragma mark - Activation

@property(nonatomic, readonly) AKAControl* activeControl;
@property(nonatomic, readonly) AKAControl* activeLeafControl;

@end

@interface AKACompositeControl(Conveniences)

#pragma mark - Enumerating Members

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

#pragma mark - Adding and Removing Member Controls

- (BOOL)addControl:(AKAControl*)control;

- (BOOL)removeControl:(AKAControl*)control;


- (NSUInteger)addControlsForControlViewsInViewHierarchy:(UIView*)rootView;
- (NSUInteger)insertControlsForControlViewsInViewHierarchy:(UIView*)rootView
                                                   atIndex:(NSUInteger)index;

- (NSUInteger)addControlsForControlViewsInOutletCollection:(NSArray*)outletCollection;
- (NSUInteger)insertControlsForControlViewsInOutletCollection:(NSArray*)outletCollection
                                                      atIndex:(NSUInteger)index;

- (NSUInteger)addControlsForControlViewsInOutletCollections:(NSArray*)arrayOfOutletCollections;
- (NSUInteger)insertControlsForControlViewsInOutletCollections:(NSArray*)arrayOfOutletCollections
                                                       atIndex:(NSUInteger)index;

- (NSUInteger)addControlsForControlViewsInStaticTableView:(UITableView*)tableView
                                               dataSource:(id<UITableViewDataSource>)dataSource;
- (NSUInteger)insertControlsForControlViewsInStaticTableView:(UITableView*)tableView
                                                  dataSource:(id<UITableViewDataSource>)dataSource
                                                     atIndex:(NSUInteger)index;

@end
