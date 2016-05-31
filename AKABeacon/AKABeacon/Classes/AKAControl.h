//
//  AKAControl.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
#import "AKAProperty.h"

#import "AKAControlConfiguration.h"
#import "AKAControlDelegate.h"
#import "AKAControlValidationState.h"
#import "AKABindingContextProtocol.h"
#import "AKAControlViewBinding.h"
#import "AKABindingOwnerProtocol.h"

@interface AKAControl: NSObject

 #pragma mark - Configuration

/**
 The composite control owning this control.
 */
@property(nonatomic, readonly, weak, nullable)AKACompositeControl*          owner;

@property(nonatomic, readonly, weak, nullable)AKAControlViewBinding*        controlViewBinding;

@property(nonatomic, readonly, weak, nullable)UIView*                       view;

+ (opt_AKAControl)                                 registeredControlForView:(req_UIView)view;

@property(nonatomic, readonly, nullable) NSString*                          name;

@property(nonatomic, readonly, nullable) NSSet<NSString*>*                  tags;

@property(nonatomic, readonly, nullable) NSString*                          role;

@property(nonatomic, readonly, nullable) id                                 dataContext;

#pragma mark - Validation

- (void)setValidationState:(AKAControlValidationState)validationState
                 withError:(opt_NSError)error;

@property(nonatomic, readonly) AKAControlValidationState                    validationState;

@property(nonatomic, readonly, nullable) NSError*                           validationError;

@property(nonatomic, readonly) BOOL                                         isValid;

@end


@interface AKAControl(BindingContext)<AKABindingContextProtocol>
@end


#import "AKABinding.h"
@interface AKAControl(BindingsOwner)<AKABindingOwnerProtocol>

#pragma mark - Adding and Removing Bindings

- (NSUInteger)                     addBindingsForView:(req_UIView)view;

- (BOOL)                            addBindingForView:(req_UIView)view
                                             property:(opt_SEL)bindingProperty
                                withBindingExpression:(req_AKABindingExpression)bindingExpression
                                                error:(out_NSError)error;

- (BOOL)                                removeBinding:(req_AKABinding)binding;

#pragma mark - Binding Ownership Events

- (BOOL)                       shouldAddBindingOfType:(req_Class)bindingType
                                              forView:(req_UIView)view
                                             property:(opt_SEL)bindingProperty
                                withBindingExpression:(req_AKABindingExpression)bindingExpression;

- (void)                               willAddBinding:(req_AKABinding)binding
                                              forView:(req_UIView)view
                                             property:(opt_SEL)bindingProperty
                                withBindingExpression:(req_AKABindingExpression)bindingExpression;

- (void)                                didAddBinding:(req_AKABinding)binding
                                              forView:(req_UIView)view
                                             property:(opt_SEL)bindingProperty
                                withBindingExpression:(req_AKABindingExpression)bindingExpression;

- (void)                            willRemoveBinding:(req_AKABinding)binding;

- (void)                             didRemoveBinding:(req_AKABinding)binding;

@end


@interface UIView(AKARegisteredControl)

/**
 * Returns the control participating in a control view binding with this view or nil if the view
 * is not bound to a control.
 */
@property(nonatomic, readonly, weak) opt_AKAControl aka_boundControl;

@end


@interface AKAControl(ObsoleteThemeSupport)

- (nullable AKAProperty*)themeNamePropertyForView:(req_UIView)view
                                   changeObserver:(void(^_Nullable)(opt_id oldValue, opt_id newValue))themeNameChanged;

- (void)setThemeName:(opt_NSString)themeName forClass:(req_Class)type;

@end


@interface AKAControl(Obsolete)

#pragma mark - Change Tracking
/// @name Change tracking

- (void)startObservingChanges;

- (void)stopObservingChanges;

@property(nonatomic, readonly) BOOL isObservingChanges;

#pragma mark - Keyboard Activation Sequence

@property(nonatomic, readonly) BOOL shouldAutoActivate;

@property(nonatomic, readonly) BOOL participatesInKeyboardActivationSequence;

#pragma mark - Diagnostics

@property(nonatomic, readonly, nullable) NSString* debugDescriptionDetails;

@end

