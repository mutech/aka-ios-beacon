//
//  AKAControlViewBinding.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKAControlViewDelegate.h"

@class UIView;
@class AKAControl;
@class AKAProperty;

@interface AKAControlViewBinding : NSObject<AKAControlViewDelegate>

- (instancetype)initWithControl:(AKAControl*)control
                           view:(UIView*)view;

- (AKAProperty*)createViewValueProperty;

#pragma mark - Interface for binding implementations

@property(nonatomic, weak, readonly) AKAControl* control;

#pragma mark - Interface for AKAControl

// TODO: make view private
@property(nonatomic, weak, readonly) UIView* view;

/**
 * Provides access to the view's value.
 */
@property(nonatomic, strong, readonly) AKAProperty* viewValueProperty;

#pragma mark - Activation

/**
 * Indicates whether the view can be activated.
 */
@property(nonatomic, readonly) BOOL controlViewCanActivate;

@property(nonatomic, readonly) BOOL shouldAutoActivate;

@property(nonatomic, readonly) BOOL participatesInKeyboardActivationSequence;

- (void)setupKeyboardActivationSequenceWithPredecessor:(AKAControl*)previous
                                             successor:(AKAControl*)next;

- (BOOL)activateControlView;

- (BOOL)deactivateControlView;

@end
