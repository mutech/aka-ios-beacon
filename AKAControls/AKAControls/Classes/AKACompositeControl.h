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

- (NSUInteger)countOfControls;

- (id)objectInControlsAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfControl:(AKAControl*)control;

#pragma mark - Adding and Removing Member Controls

- (BOOL)insertControl:(AKAControl*)control atIndex:(NSUInteger)index;

- (AKAControl*)createControlForView:(UIView*)view
                  withConfiguration:(AKAViewBindingConfiguration*)configuration;

- (BOOL)removeControlAtIndex:(NSUInteger)index;

- (NSUInteger)removeAllControls;

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

- (void)enumerateControlsRecursivelyUsingBlock:(void(^)(AKAControl* control, AKACompositeControl* owner, NSUInteger index, BOOL* stop))block;

- (void)enumerateControlsRecursivelyUsingBlock:(void(^)(AKAControl* control, AKACompositeControl* owner, NSUInteger index, BOOL* stop))block
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

- (NSUInteger)   addControlsForControlViewsInViewHierarchy:(UIView*)rootView;
- (NSUInteger)insertControlsForControlViewsInViewHierarchy:(UIView*)rootView
                                                   atIndex:(NSUInteger)index;

- (void)      addControlsForControlViewsInOutletCollection:(NSArray*)outletCollection;
- (void)   insertControlsForControlViewsInOutletCollection:(NSArray*)outletCollection
                                                   atIndex:(NSUInteger)index;

- (void)     addControlsForControlViewsInOutletCollections:(NSArray*)arrayOfOutletCollections;
- (void)  insertControlsForControlViewsInOutletCollections:(NSArray*)arrayOfOutletCollections
                                                   atIndex:(NSUInteger)index;

- (void)       addControlsForControlViewsInStaticTableView:(UITableView*)tableView
                                                dataSource:(id<UITableViewDataSource>)dataSource;
- (void)    insertControlsForControlViewsInStaticTableView:(UITableView*)tableView
                                                dataSource:(id<UITableViewDataSource>)dataSource
                                                   atIndex:(NSUInteger)index;

@end
