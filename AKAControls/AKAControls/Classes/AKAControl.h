//
//  AKAControl.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKAProperty.h"
#import "AKAControlDelegate.h"
#import "AKAControlConverterProtocol.h"
#import "AKAControlValidatorProtocol.h"
#import "AKAControlViewBinding.h"

@class AKACompositeControl;
@class AKAControlViewBinding;

@interface AKAControl : NSObject

#pragma mark - Initialization

+ (instancetype)controlWithOwner:(AKACompositeControl*)owner;
+ (instancetype)controlWithOwner:(AKACompositeControl*)owner keyPath:(NSString*)keyPath;
+ (instancetype)controlWithDataContext:(id)dataContext;
+ (instancetype)controlWithDataContext:(id)dataContext keyPath:(NSString*)keyPath;

#pragma mark - Configuration

@property(nonatomic, weak) id<AKAControlDelegate> delegate;

#pragma mark - Control Hierarchy

@property(nonatomic, readonly, weak)AKACompositeControl* owner;

#pragma mark - Value Access

@property(nonatomic, readonly) UIView* view;
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

#pragma mark - Activation

@property(nonatomic, readonly) BOOL isActive;
@property(nonatomic, readonly) BOOL canActivate;
@property(nonatomic, readonly) BOOL shouldActivate;
@property(nonatomic, readonly) BOOL shouldDeactivate;
- (BOOL)activate;
- (BOOL)deactivate;

@property(nonatomic, readonly) BOOL shouldAutoActivate;
@property(nonatomic, readonly) BOOL participatesInKeyboardActivationSequence;
@property(nonatomic, readonly) AKAControl* nextControlInKeyboardActivationSequence;
- (void)setupKeyboardActivationSequenceWithPredecessor:(AKAControl*)previous
                                              successor:(AKAControl*)next;

@end
