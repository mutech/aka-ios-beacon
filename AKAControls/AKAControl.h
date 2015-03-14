//
//  AKAControl.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKAProperty.h"
#import "AKAControlConverterProtocol.h"
#import "AKAControlValidatorProtocol.h"
#import "AKAControlViewBinding.h"

@class AKACompositeControl;
@class AKAControlViewBinding;

@interface AKAControl : NSObject

#pragma mark - Initialization

+ (instancetype)controlWithOwner:(AKACompositeControl*)owner keyPath:(NSString*)keyPath;
+ (instancetype)controlWithDataContext:(id)dataContext keyPath:(NSString*)keyPath;

#pragma mark - Control Hierarchy

@property(nonatomic, readonly, weak)AKACompositeControl* owner;

#pragma mark - View Binding

@property(nonatomic, strong) AKAControlViewBinding* viewBinding;

#pragma mark - Value Access

@property(nonatomic) id viewValue;
@property(nonatomic) id modelValue;

#pragma mark - Change Tracking

- (void)startObservingChanges;
- (void)stopObservingChanges;

@property(nonatomic, readonly) BOOL isObservingViewValueChanges;
- (BOOL)startObservingViewValueChanges;
- (BOOL)stopObservingViewValueChanges;

@property(nonatomic, readonly) BOOL isObservingModelValueChanges;
- (BOOL)startObservingModelValueChanges;
- (BOOL)stopObservingModelValueChanges;

@end
