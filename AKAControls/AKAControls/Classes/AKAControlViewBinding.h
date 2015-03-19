//
//  AKAControlViewBinding.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKAControlViewBindingConfigurationProtocol.h"
#import "AKAControlViewDelegate.h"

@class UIView;
@class AKAControl;
@class AKACompositeControl;
@class AKAProperty;



@interface AKAControlViewBindingConfiguration: NSObject<AKAControlViewBindingConfigurationProtocol>

@property(nonatomic)Class     preferredBindingType;
@property(nonatomic)Class     preferredViewType;
@property(nonatomic)Class     preferredControlType;

@property(nonatomic)/*IBInspectable*/ NSString* name;
@property(nonatomic)/*IBInspectable*/ NSString* role;

@end

@interface AKAEditingControlViewBindingConfiguration: AKAControlViewBindingConfiguration

@property(nonatomic)NSString* valueKeyPath;

@end

@interface AKAControlViewBinding : NSObject<AKAControlViewDelegate>

+ (AKAControlViewBinding*)bindingOfType:(Class)preferredBindingType
                      withConfiguration:(id<AKAControlViewBindingConfigurationProtocol>)configuration
                                   view:(UIView*)view
                           controlOwner:(AKACompositeControl*)owner;

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
