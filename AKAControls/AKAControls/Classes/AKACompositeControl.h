//
//  AKACompositeControl.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl.h"

@interface AKACompositeControl : AKAControl

#pragma mark - Initialization

#pragma mark - Member Controls

@property(nonatomic, readonly)NSArray* controls;

#pragma mark Control Membership

- (BOOL)addControl:(AKAControl*)control;
- (BOOL)insertControl:(AKAControl*)control atIndex:(NSUInteger)index;
- (BOOL)removeControl:(AKAControl*)control;
- (BOOL)removeControlAtIndex:(NSUInteger)index;

- (NSUInteger)addControlsForControlViewsInViewHierarchy:(UIView*)rootView;
- (NSUInteger)insertControlsForControlViewsInViewHierarchy:(UIView*)rootView
                                                   atIndex:(NSUInteger)index;

@end

