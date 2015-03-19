//
//  AKAControl_Protected.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl.h"

/**
 * Provides functionality that is reserved for classes implementing controls.
 *
 * Please note that you should not need to subclass controls.
 */
@interface AKAControl (Protected)

#pragma mark - Initialization

- (instancetype)initWithOwner:(AKACompositeControl*)owner keyPath:(NSString*)keyPath;
- (instancetype)initWithDataContext:(id)dataContext keyPath:(NSString*)keyPath;

#pragma mark - View Binding

@property(nonatomic, strong, readonly) AKAControlViewBinding* viewBinding;

#pragma mark - Value Properties

@property(nonatomic, strong) AKAProperty* modelValueProperty;
@property(nonatomic, readonly) AKAProperty* viewValueProperty;

@end
