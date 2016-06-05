//
//  AKABinding.h
//  AKABeacon
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
#import "AKAProperty.h"

#import "AKABeaconNullability.h"
#import "AKABindingOwnerProtocol.h"
#import "AKABindingDelegate.h"
#import "AKABindingController.h"
#import "AKABindingExpression.h"
#import "AKABindingSpecification.h"

@interface AKABinding: NSObject

#pragma mark - Initialization

/**
 Creates a new binding to the specified target object using the specified parameters.

 Please note that this factory method is only supported for binding types with specific target support (like for example
 view bindings) and that the type of the target has to match the binding type's specification.

 @param targetView        the target object.
 @param bindingExpression the view or conditional binding expression
 @param bindingContext    the binding context used to evaluate binding expressions; this is typically a binding controller.
 @param owner             the binding owner; this is typically a binding controller or another binding.
 @param delegate          the delegate
 @param error             error details

 @return Either an instance of an AKAViewBinding or AKAConditionalBinding which in turn has/may have a view binding at activeClause.binding
 */
+ (opt_AKABinding)bindingToTarget:(req_id)target
                   withExpression:(req_AKABindingExpression)bindingExpression
                          context:(req_AKABindingContext)bindingContext
                            owner:(opt_AKABindingOwner)owner
                         delegate:(opt_AKABindingDelegate)delegate
                            error:(out_NSError)error;

/**
 Creates a new binding to the specified target property using the specified parameters.

 Please note that this factory method is only supported for binding types which do not implement a specific target type
 support and use AKAProperty instances to read and/or write target values.

 Please note that this factory method is only supported for binding types
 @param target            the target object. This may be nil.
 @param targetValueProperty a property providing access to the binding's target value.
 @param bindingExpression the view or conditional binding expression
 @param bindingContext    the binding context used to evaluate binding expressions; this is typically a binding controller.
 @param owner             the binding owner; this is typically a binding controller or another binding.
 @param delegate          the delegate
 @param error             error details

 @return Either an instance of an AKABinding or AKAConditionalBinding which in turn has/may have a binding at activeClause.binding
 */
+ (opt_AKABinding)bindingToTarget:(opt_id)target
              targetValueProperty:(req_AKAProperty)targetValueProperty
                   withExpression:(req_AKABindingExpression)bindingExpression
                          context:(req_AKABindingContext)bindingContext
                            owner:(req_AKABindingOwner)owner
                         delegate:(opt_AKABindingDelegate)delegate
                            error:(out_NSError)error;

/**
 The object owning this binding. This is typically another binding or a binding controller.
 */
@property(nonatomic, readonly, weak, nullable) id<AKABindingOwnerProtocol>    owner;

/**
 The context used by the binding to resolve binding expressions (for sourceValueProperty.value and sub bindings).
 */
@property(nonatomic, readonly, weak, nullable) id<AKABindingContextProtocol>  bindingContext;

/**
 Property wrapping the source value of the binding. Bindings which do not support a binding source have to provide a property that refers to an undefined (nil) value, changing this value will typically have no effect.
 */
@property(nonatomic, readonly, nonnull) AKAProperty*                          sourceValueProperty;

/**
 The target object of the binding.
 */
@property(nonatomic, readonly, weak, nullable) id                             target;

/**
 Property wrapping the target value of the binding. Bindings which do not support a binding target have to provide a property that refers to an undefined (nil) value, changing this value will typically have no effect.
 */
@property(nonatomic, readonly, nonnull) AKAProperty*                          targetValueProperty;

/**
 The binding controller owning and managing this binding.

 @note This uses the bindingContext property as storage and will return nil if bindingContext is not an instance of AKABindingController.
 */
@property(nonatomic, readonly, weak, nullable) AKABindingController*          controller;

/**
 The binding delegate.
 
 Please note that delegate messages are propagated to the binding's controller and from there up to a binding behavior (if present) independent of this property.
 
 The delegate is typically used by owner bindings.
 */
@property(nonatomic, weak, nullable) id<AKABindingDelegate>         delegate;

#pragma mark - Conversion

- (BOOL)                                         convertSourceValue:(opt_id)sourceValue
                                                      toTargetValue:(out_id)targetValueStore
                                                              error:(out_NSError)error;

#pragma mark - Validation

- (BOOL)                                        validateSourceValue:(inout_id)sourceValueStore
                                                              error:(out_NSError)error;

- (BOOL)                                        validateTargetValue:(inout_id)targetValueStore
                                                              error:(out_NSError)error;

#pragma mark - Change Tracking

- (void)                       processSourceValueChangeFromOldValue:(opt_id)oldSourceValue
                                                         toNewValue:(opt_id)newSourceValue;

/**
 Starts observing changes to binding property bindings, binding target, binding source and binding target property bindings (typically in this order) and initializes the binding target value (right before starting to observe target property bindings).
 
 Sub classes should not override this method. If you need to perform additional actions, consider overriding a suitable method exposed in the protected interface.

 @return YES if starting all observable items succeeded. A negative result may leave the binding in a partially observing state.
 */
- (BOOL)                                      startObservingChanges;

- (BOOL)                                       stopObservingChanges;

#pragma mark - Updating

/**
 Triggers an update of the target value from source.
 
 This can be used by subclasses to initialize the target value or to reset it, for example if configuration parameters have been changed and the target needs to be reinitialized.
 
 @note Please note that source value changes are tracked automatically if change observation is started and do not require this method to be called.
 */
- (void)                                          updateTargetValue;

@end


@interface AKABinding(Internal)

@property(nonatomic, readonly)BOOL isUpdatingTargetValueForSourceValueChange;

/**
 * Determines if the target (f.e. view-) value should be updated as a result of a changed
 * source (f.e. model-) value.
 *
 * @note: This is used before the corresponding delegate method is called and serves as
 *   shortcut to prevent update cycles. For this purpose, an unnecessary and potentially
 *   expensive conversion of source to target values is skipped. The default implementation
 *   returns YES.
 * @warning: Sub class redefining this method should always call the super implementation and never return YES if it returned NO.
 *
 * @param oldSourceValue the old source value
 * @param newSourceValue the new source value
 * @param sourceValue the new source value or the result of the source value validation replacing an invalid value.
 *
 * @return YES if the target value should be updated, NO otherwise.
 */
- (BOOL)              shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
                                                validatedTo:(opt_id)sourceValue;

@end


@interface AKABinding(BindingSpecification)

#pragma mark - Binding Expression Specification

+ (req_AKABindingSpecification)                           specification;

+ (opt_AKABindingAttributeSpecification) specificationForAttributeNamed:(req_NSString)attributeName;

+ (opt_Class)   bindingTypeForBindingExpressionInPrimaryExpressionArray;

@end

