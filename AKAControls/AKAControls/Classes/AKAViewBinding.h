//
//  AKAControlViewAdapter.h
//  AKAControls
//
//  Created by Michael Utech on 06.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

// Obsolete: TODO: remove once new binding infrastructure is finished

@import UIKit;
@import AKACommons.AKAProperty;

#import "AKAViewBindingConfiguration.h"

#import "AKABindingContextProtocol.h"

@class AKAViewBinding;
@class AKAKeyboardActivationSequence;
@protocol AKAControlConverterProtocol;

@protocol AKAViewBindingDelegate <AKABindingContextProtocol>

#pragma mark - Activation
/// @name Activation

- (void)        viewBinding:(AKAViewBinding*)viewBinding
                       view:(UIView*)view
         valueDidChangeFrom:(id)oldValue to:(id)newValue;

- (BOOL)viewBindingShouldActivate:(AKAViewBinding*)viewBinding;

- (void)        viewBinding:(AKAViewBinding*)viewBinding
           viewWillActivate:(UIView*)view;

- (void)        viewBinding:(AKAViewBinding*)viewBinding
            viewDidActivate:(UIView*)view;

- (BOOL)viewBindingShouldDeactivate:(AKAViewBinding*)viewBinding;

- (void)        viewBinding:(AKAViewBinding*)viewBinding
          viewDidDeactivate:(UIView*)view;

- (void)        viewBinding:(AKAViewBinding*)viewBinding
         viewWillDeactivate:(UIView*)view;

@property(nonatomic, readonly)AKAKeyboardActivationSequence* keyboardActivationSequence;

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

@property(nonatomic, readonly) BOOL isObservingViewValueChanges;
@property(nonatomic, readonly) AKAProperty* viewValueProperty;

#pragma mark - Conversion

- (id<AKAControlConverterProtocol>) defaultConverter;

#pragma mark - Validation
/// @name Validation

/**
 * Announces to the view binding, that the specified validation context (typically
 * the control owning the view binding) has changed the validation state for the
 * specified view from oldError to newError.
 *
 * The default implementation calls <managesValidationStateForContext:view:> and if that
 * returns YES <setValidationState:forView:validationContext> using an appropriate animation.
 *
 * @param validationContext the object performing or controlling the validation process, typically the control owning this view binding.
 * @param the view that triggered the view value validation (should equal <view>)
 * @param oldError the previous validation state
 * @param newError the current validation state
 */
- (void)    validationContext:(id)validationContext
                      forView:(UIView*)view
   changedValidationStateFrom:(NSError*)oldError
                           to:(NSError*)newError;

/**
 * Determines whether this view binding manages the validation state for the specified
 * validationContext and the specified view. This typically means that the bound view
 * (hierarchy) displays validation error messages.
 */
- (BOOL)managesValidationStateForContext:(id)validationContext
                                    view:(UIView*)view;

/**
 * Updates the validation error display if the view binding manages the validation state for
 * the context and view.
 *
 * The default implementation does nothing.
 *
 * @param error the validation state to display.
 * @param view the view to which the validation state refers to.
 * @param validationContext the object performing or controlling the validation.
 */
- (void)setValidationState:(NSError*)error
                   forView:(UIView*)view
         validationContext:(id)validationContext;

#pragma mark - Activation
/// @name Activation

@property(nonatomic, readonly) BOOL supportsActivation;
@property(nonatomic, readonly) BOOL shouldAutoActivate;

- (BOOL)activate;
- (BOOL)deactivate;

#pragma mark - Keyboard Activation Sequence

@property(nonatomic, readonly) BOOL participatesInKeyboardActivationSequence;

@end


@interface AKAViewBinding(Protected)

#pragma mark - Protected Interface - Abstract Methods
/// @name Protected: Abstract Methods

- (AKAProperty*)createViewValueProperty;
- (AKAProperty*)createConverterPropertyWithDataContextProperty:(AKAProperty*)dataContextProperty;
- (AKAProperty*)createValidatorPropertyWithDataContextProperty:(AKAProperty*)dataContextProperty;

#pragma mark - Protected Interface - Delegate Support Methods
/// @name Protected: Delegate Support Methods

- (void)viewValueDidChangeFrom:(id)oldValue to:(id)newValue;
- (BOOL)shouldActivate;
- (void)viewWillActivate;
- (void)viewDidActivate;
- (BOOL)shouldDeactivate;
- (void)viewWillDeactivate;
- (void)viewDidDeactivate;

@end