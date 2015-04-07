//
//  AKAControlViewAdapter.h
//  AKAControls
//
//  Created by Michael Utech on 06.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AKACommons/AKAProperty.h>

#import "AKAViewBindingConfiguration.h"

@class AKAViewBinding;

@protocol AKAViewBindingDelegate <NSObject>

- (void)viewBinding:(AKAViewBinding*)viewBinding
                      view:(UIView*)view
        valueDidChangeFrom:(id)oldValue to:(id)newValue;

- (BOOL)viewBindingShouldActivate:(AKAViewBinding*)viewBinding;

- (void)viewBinding:(AKAViewBinding*)viewBinding
           viewWillActivate:(UIView*)view;

- (void)viewBinding:(AKAViewBinding*)viewBinding
           viewDidActivate:(UIView*)view;

- (BOOL)viewBindingShouldDeactivate:(AKAViewBinding*)viewBinding;

- (void)viewBinding:(AKAViewBinding*)viewBinding
         viewDidDeactivate:(UIView*)view;

- (void)viewBinding:(AKAViewBinding*)viewBinding
        viewWillDeactivate:(UIView*)view;

- (BOOL)viewBindingRequestsActivateNextInKeyboardActivationSequence:(AKAViewBinding*)viewBinding;

#pragma mark - Theme Support
/// @name Theme support

/**
 * Creates a AKAProperty instance accessing the name of the theme that the specified view should use. the specified @c themeNameChanged block will be called whenever the specification of the theme changes.
 *
 * @note The theme name registry honors inheritance. If no theme name is associated for views of type @c B but for a super type @c A, then instances of type @c B will use the theme name associated with type @c A.
 *
 * @warning Please do not keep strong references to the view or other objects related to this control in themeNameChanged.
 *
 * @param view the view for which a theme name is searched.
 * @param themeNameChanged called whenever the theme name changes.
 *
 * @return A property providing the name of the theme. If no theme name can be associated with the view, the property will have a value of nil.
 */
- (AKAProperty*)themeNamePropertyForView:(UIView*)view
                          changeObserver:(void(^)(id oldValue, id newValue))themeNameChanged;

/**
 * Associates the specified themeName with the specified UIView class type. If the themeName is nil, an existing association will be removed,
 *
 * @param themeName <#themeName description#>
 * @param type <#type description#>
 */
- (void)setThemeName:(NSString*)themeName forClass:(Class)type;

@end

@interface AKAViewBinding: NSObject

#pragma mark - Initialization
/// @name Initialization

- (instancetype)initWithView:(UIView*)view
               configuration:(AKAViewBindingConfiguration*)configuration
                    delegate:(id<AKAViewBindingDelegate>)delegate;

#pragma mark - Configuration
/// @name Configuration

@property(nonatomic, weak, readonly) UIView* view;
@property(nonatomic, weak, readonly) AKAViewBindingConfiguration* configuration;
@property(nonatomic, weak, readonly) id<AKAViewBindingDelegate> delegate;

#pragma mark - View Value Access
/// @name View Value Access

@property(nonatomic, readonly) AKAProperty* viewValueProperty;

#pragma mark - Activation
/// @name Activation

@property(nonatomic, readonly) BOOL supportsActivation;
@property(nonatomic, readonly) BOOL shouldAutoActivate;

- (BOOL)activate;
- (BOOL)deactivate;

#pragma mark - Keyboard Activation Sequence

@property(nonatomic, readonly) BOOL participatesInKeyboardActivationSequence;

- (void)setupKeyboardActivationSequenceWithPredecessor:(UIView*)previous
                                             successor:(UIView*)next;

@end

@interface AKAViewBinding()

#pragma mark - Protected Interface - Abstract Methods
/// @name Protected: Abstract Methods

- (AKAProperty *)createViewValueProperty;

#pragma mark - Protected Interface - Delegate Support Methods
/// @name Protected: Delegate Support Methods

- (void)viewValueDidChangeFrom:(id)oldValue to:(id)newValue;
- (BOOL)shouldActivate;
- (void)viewWillActivate;
- (void)viewDidActivate;
- (BOOL)shouldDeactivate;
- (void)viewWillDeactivate;
- (void)viewDidDeactivate;
- (BOOL)activateNextInKeyboardActivationSequence;

@end