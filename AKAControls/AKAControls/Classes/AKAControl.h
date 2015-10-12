//
//  AKAControl.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKAProperty;

#import "AKAControlDelegate.h"
#import "AKABindingContextProtocol.h"
#import "AKAKeyboardActivationSequence.h"

// Obsolete: TODO: remove when new binding infrastruct is finished:
#import "AKAControlConverterProtocol.h"
#import "AKAControlValidatorProtocol.h"
#import "AKAObsoleteViewBinding.h"

@class AKACompositeControl;
@protocol AKAControlConfigurationProtocol;

typedef AKAControl* _Nullable opt_AKAControl;
typedef AKAControl* _Nonnull  req_AKAControl;


@interface AKAControl: NSObject

#pragma mark - Configuration

@property(nonatomic, weak, nullable) id<AKAControlDelegate>                 delegate;
@property(readonly, nonnull) NSSet*                                         tags;

#pragma mark - Control Hierarchy

@property(nonatomic, readonly, weak, nullable)AKACompositeControl*          owner;

#pragma mark - Validation

@property(nonatomic, readonly) BOOL                                         isValid;

#pragma mark - Activation

@property(nonatomic, readonly) BOOL                                         isActive;

// TODO: Make private:

#pragma mark - Bindings Storage

@property(nonatomic, nonnull) NSMutableArray*                               bindings;

#pragma mark - Value Access

@property(nonatomic, nullable) id                                           modelValue;

// TODO: Remove:

#pragma mark - View Binding

@property(nonatomic, readonly, nullable) AKAObsoleteViewBinding *           viewBinding;
@property(nonatomic, readonly, nullable) UIView*                            view;

@end


@interface AKAControl(BindingContext)<AKABindingContextProtocol>
@end


#import "AKABinding.h"
@interface AKAControl(BindingsOwner)<AKABindingDelegate>

- (NSUInteger)                     addBindingsForView:(req_UIView)view;

- (BOOL)                            addBindingForView:(req_UIView)view
                              bindingPropertyWithName:(req_NSString)propertyName;

- (BOOL)                                removeBinding:(req_AKABinding)binding;

@end


@interface AKAControl(KeyboardActivationSequence)<AKAKeyboardActivationSequenceItemProtocol>
@end


@interface AKAControl(Convenience)

@end


@interface AKAControl(Activation)

/**
 * Indicates whether the control supports the notion of an active state. If the result
 * is NO, isActive will always be false, shouldActivate and shouldDeactivate will always
 * return NO, activate and deactivate will have no effect and return NO and willActivate,
 * didActivate, willDeactivate and didDeactivate will never be called (internally).
 *
 * The control uses the specific binding to determine the result.
 *
 * @see [AKAControlViewBinding controlViewCanActivate]
 */
@property(nonatomic, readonly) BOOL canActivate;

/**
 * Determines whether the control should be activated. The default implementation calls
 * the shouldControlActivate: method of the delegate an then (if the result is positive) that of
 * the controls owner.
 *
 * @note There is no guarantee, that shouldActivate is called  before a control is activated.
 * Code calling shouldActivate is however expected to honor the result.
 *
 * @see [AKAControlDelegate shouldControlActivate:]
 */
@property(nonatomic, readonly) BOOL shouldActivate;

/**
 * Determines whether the control should be deactivated. The default implementation calls
 * the shouldControlDeactivate: method of the delegate an then (if the result is positive) that of
 * the controls owner.
 *
 * @note There is no guarantee, that shouldDeactivate is called  before a control is deactivated.
 * Code calling shouldDeactivate is however expected to honor the result.
 *
 * @see [AKAControlDelegate shouldControlDeactivate:]
 */
@property(nonatomic, readonly) BOOL shouldDeactivate;

/**
 * Activates the control. The default implementation calls the binding to activate its
 * control view which, if successful, will send the control willActivate and didActivate
 * messages.
 *
 * @note activate does not call shouldActivate, it's the responsibility of the caller
 * to do that.
 *
 * @return YES if the control has been activated or was already active
 */
- (BOOL)activate;

/**
 * Deactivates the control. The default implementation calls the binding to deactivate
 * its control view which, if successful, will send the control willDeactivate and
 * didDeactivate messages.
 *
 * @return YES if the control has been deactivated or was already inactive.
 */
- (BOOL)deactivate;

/**
 * Called by the binding when the associated view will be activated.
 * The default implementation calls the controlWillActivate: method of the delegate
 * and the owner control.
 *
 * @note There is no guarantee that willActivate is called
 */
- (void)willActivate;

/**
 * Called by the binding when the associated view has been activated.
 * The default implementation calls the controlDidActivate method of the delegate
 * and the owner control.
 */
- (void)didActivate;

/**
 * Called by the binding when the associated view will be deactivated.
 * The default implementation calls the controlWillDeactivate: method of the delegate
 * and the owner control.
 *
 * @note There is no guarantee that willDeactivate is called
 */
- (void)willDeactivate;

/**
 * Called by the binding when the associated view has been deactivated.
 * The default implementation calls the controlDidDeactivate method of the delegate
 * and the owner control.
 */
- (void)didDeactivate;

@end


@interface AKAControl(ObsoleteViewBindingDelegate)
@end

@interface AKAControl(ObsoleteThemeSupport)

- (nullable AKAProperty*)themeNamePropertyForView:(req_UIView)view
                                   changeObserver:(void(^_Nullable)(opt_id oldValue, opt_id newValue))themeNameChanged;

- (void)setThemeName:(opt_NSString)themeName forClass:(req_Class)type;

@end


@interface AKAControl(Obsolete)

#pragma mark - Initialization

+ (nullable instancetype)controlWithOwner:(AKACompositeControl* __nonnull)owner
                            configuration:(id<AKAControlConfigurationProtocol> __nullable)configuration;

+ (nullable instancetype)controlWithDataContext:(id __nullable)dataContext
                         configuration:(id<AKAControlConfigurationProtocol>__nullable)configuration;

#pragma mark - Change Tracking
/// @name Change tracking

- (void)startObservingChanges;

- (void)stopObservingChanges;

@property(nonatomic, readonly) BOOL isObservingChanges;

#pragma mark - Keyboard Activation Sequence

@property(nonatomic, readonly) BOOL shouldAutoActivate;

@property(nonatomic, readonly) BOOL participatesInKeyboardActivationSequence;

@property(nonatomic, readonly, nullable) AKAKeyboardActivationSequence* keyboardActivationSequence;

#pragma mark - Diagnostics

@property(nonatomic, readonly, nullable) NSString* debugDescriptionDetails;

@end

