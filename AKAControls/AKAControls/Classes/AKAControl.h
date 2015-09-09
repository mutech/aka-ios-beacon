//
//  AKAControl.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AKACommons/AKAProperty.h>
#import "AKAControlDelegate.h"
#import "AKAControlConverterProtocol.h"
#import "AKAControlValidatorProtocol.h"
#import "AKAViewBinding.h"

@class AKACompositeControl;
@class AKAViewBinding;
@protocol AKAControlConfigurationProtocol;

#pragma mark - AKAControl Interface
#pragma mark -

/**
 * The main purpose of a control is to unify the interface of various UIViews to support
 * a concept of a viewValue (the state of the view) and an associated modelValue and
 * to manage the process of updating one based on changes to the other.
 *
 * A control has a data context, which it either was explicitely provided with or which
 * it inherits from it's owner (an instance of AKACompositeControl). The modelValue is
 * derived from the data context by evaluating a key path using Key Value Coding. If no
 * key path is defined, the data context and model value are the same. In this case, changing
 * the model value only changes which data context the control uses and does not change
 * the data context itself.
 *
 * The connection between a control and its view is established by an instance of
 * (a specific implementation of) a AKAControlViewBinding which provides an abstract
 * interface to manage the view, extract its (view-)value and observe changes and other
 * events and finally to inform the control about these events.
 *
 *
 * @see AKAControlViewBinding
 */
@interface AKAControl: NSObject

#pragma mark - Initialization
/// @name Initialization

/**
 * Creates and initializes a new unbound control with the specified owner control. The new
 * control "inherits" its data context (model value) from the owner.
 *
 * @param owner the composite control owning the new control (not nil).
 * @param configuration the control configuration
 * @return the new control
 */
+ (nullable instancetype)controlWithOwner:(AKACompositeControl* __nonnull)owner
                            configuration:(id<AKAControlConfigurationProtocol> __nullable)configuration;

/**
 * Creates and initializes a new unbound toplevel control using the specified data context.
 *
 * @param dataContext the data context representing the controls model value.
 * @param configuration the control configuration
 *
 * @return the new control.
 */
+ (nullable instancetype)controlWithDataContext:(id __nullable)dataContext
                         configuration:(id<AKAControlConfigurationProtocol>__nullable)configuration;

#pragma mark - Configuration
/// @name Configuration

/**
 * The AKAControlDelegate which can be used to observe control events and to customize the controls
 * behavior. Please note that all delegate method calls are also forwarded transitively up the
 * control hierarchy. It is generally easier to attach a delegate to the root control.
 *
 * Delegate methods influencing the behavior of the control are called before forwarding messages
 * to owners, informative methods are called after forwarding messages to owners.
 */
@property(nonatomic, weak, nullable) id<AKAControlDelegate> delegate;

#pragma mark - Properties

/**
 * Tags (typically specified in the control view's binding configuration)
 */
@property(readonly, nonnull) NSSet* tags;

#pragma mark - Model-View Value Conversion
/// @name Model Value Validation

/**
 * Used to convert between model and view values.
 */
@property(nonatomic, readonly, nullable) id<AKAControlConverterProtocol> converter;

#pragma mark - Validation
/// @name Validation

@property(nonatomic, readonly, nullable) NSError* validationError;

@property(nonatomic, readonly) BOOL isValid;

/**
 * Used to validate model values.
 *
 * @note that in addition to this validator Key-Value-Coding validation is
 * used whenever model values are bound by means of Key-Value-Coding.
 */
@property(nonatomic, readonly, nullable) id<AKAControlValidatorProtocol> validator;

#pragma mark - Control Hierarchy
/// @name Control hierarchy

/**
 * The composite control owning this control or nil if the control is a toplevel (root) control.
 */
@property(nonatomic, readonly, weak, nullable)AKACompositeControl* owner;

#pragma mark - Rebinding

#pragma mark - Value Access
/// @name Accessing view and model values

@property(nonatomic, readonly, nullable) AKAViewBinding* viewBinding;

/**
 * The view presenting the control's state or nil if there is none.
 *
 * The view is provided by the controls binding. Some binding types might not have an associated
 * view or it might not be accessible or not an instance of UIView. In all these cases
 * or if the control is not bound, the returned value will be nil.
 */
@property(nonatomic, readonly, nullable) UIView* view;

/**
 * The value representing the views visual state.
 *
 * The value is provided by the controls binding which in turn uses its implementation specific
 * access methods to get and set the value from the bound view.
 *
 * The type and format of the view value is specific to the binding type.
 *
 * Please note that assigning a view value requires knowledge of the required type and format
 * and the result of assigning an invalid value is undefined.
 */
@property(nonatomic, nullable) id viewValue;

/**
 * The controls model value. The value is obtained from the data context by querying it
 * with the controls model value key path (or identical to the data context if no key path
 * is specified).
 */
@property(nonatomic, nullable) id modelValue;

#pragma mark - Change Tracking

- (void)startObservingOtherChanges;

- (void)stopObservingOtherChanges;

/// @name Controlling change tracking

/**
 * Starts observing changes of model and view values.
 */
- (void)startObservingChanges;

/**
 * Stops observing changes of model and view values.
 */
- (void)stopObservingChanges;

/**
 * Indicates whether changes to the view value are observed.
 *
 * @note Only changes originating from the view (thus the user) are observed. Programmatic changes
 * will not trigger change events.
 */
@property(nonatomic, readonly) BOOL isObservingViewValueChanges;

/**
 * Starts observing changes to the controls view value.
 *
 * @note Only changes originating from the view (thus the user) are observed. Programmatic changes
 * will not trigger change events.
 *
 * @return YES, if observation of view values was started or if the control was already observing them.
 */
- (BOOL)startObservingViewValueChanges;

/**
 * Starts observing changes to the controls view value.
 *
 * @return YES, if observation of view values was stopped or if the control was not observing them.
 */
- (BOOL)stopObservingViewValueChanges;

/**
 * Indicates whether changes to the model value are observed.
 *
 * @note Unlike for view value changes, all changes to model values are observed.
 */
@property(nonatomic, readonly) BOOL isObservingModelValueChanges;

/**
 * Starts observing changes to the controls model value.
 *
 * @note Unlike for view value changes, all changes to model values are observed.
 *
 * @return YES, if observation of model values was started or if the control was already observing them.
 */
- (BOOL)startObservingModelValueChanges;

/**
 * Stops observing changes to the controls model value.
 *
 * @return YES, if observation of model values was stopped or if the control was not observing them.
 */
- (BOOL)stopObservingModelValueChanges;

#pragma mark - Activation
/// @name Activation

/**
 * Indicates whether the control is active.
 */
@property(nonatomic, readonly) BOOL isActive;

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

/**
 * Indicates if the control should be automatically activated if the controls owner
 * has been automatically activated. Auto activation will of a composite control will
 * activate the first member control that responds with YES to shouldAutoActivate.
 */
@property(nonatomic, readonly) BOOL shouldAutoActivate;

/**
 * Indicates whether the control particaptes in the keyboard activation sequence.
 * The default implementation will call the corresponding method of the binding.
 */
@property(nonatomic, readonly) BOOL participatesInKeyboardActivationSequence;

@property(nonatomic, readonly, nullable) AKAKeyboardActivationSequence* keyboardActivationSequence;

#pragma mark - Theme Selection

- (nullable AKAProperty*)themeNamePropertyForView:(UIView* __nonnull)view
                          changeObserver:(void(^__nullable)(id __nullable oldValue, id __nullable newValue))themeNameChanged;

- (void)setThemeName:(NSString* __nullable)themeName forClass:(Class __nonnull)type;

@end
