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
#import "AKABindingDelegate.h"
#import "AKABindingController.h"
#import "AKABindingExpression.h"
#import "AKABindingSpecification.h"

@interface AKABinding: NSObject<AKABindingDelegate>

#pragma mark - Initialization

/**
 Creates a new binding to the specified target object using the specified parameters.

 Please note that this factory method is only supported for binding types with specific target support (like for example
 view bindings) and that the type of the target has to match the binding type's specification.

 @param targetView        the target view
 @param bindingExpression the view or conditional binding expression
 @param bindingContext    the binding context
 @param delegate          the delegate
 @param error             error details

 @return Either an instance of an AKAViewBinding or AKAConditionalBinding which in turn has/may have a view binding at activeClause.binding
 */
+ (opt_AKABinding)bindingToTarget:(req_id)target
                   withExpression:(req_AKABindingExpression)bindingExpression
                          context:(req_AKABindingContext)bindingContext
                         delegate:(opt_AKABindingDelegate)delegate
                            error:(out_NSError)error;

/**
 Creates a new binding to the specified target property using the specified parameters.

 Please note that this factory method is only supported for binding types
 @param target            the target property
 @param bindingExpression the view or conditional binding expression
 @param bindingContext    the binding context
 @param delegate          the delegate
 @param error             error details

 @return Either an instance of an AKABinding or AKAConditionalBinding which in turn has/may have a binding at activeClause.binding
 */
+ (opt_AKABinding)bindingToTargetProperty:(req_AKAProperty)target
                           withExpression:(req_AKABindingExpression)bindingExpression
                                  context:(req_AKABindingContext)bindingContext
                                 delegate:(opt_AKABindingDelegate)delegate
                                    error:(out_NSError)error;

#pragma mark - Configuration

/**
 Property wrapping the source value of the binding. Bindings which do not support a binding source provide a property that refers to an undefined (nil) value, changing this value will typically have no effect.

 @note TODO: rename to `sourceValueProperty`.
 */
@property(nonatomic, readonly, nonnull) AKAProperty*                          bindingSource;

/**
 Property wrapping the target value of the binding. Bindings which do not support a binding target provide a property that refers to an undefined (nil) value, changing this value will typically have no effect.

 @note TODO: rename to `targetValueProperty`.
 */
@property(nonatomic, readonly, nonnull) AKAProperty*                          bindingTarget;

/**
 The context used by the binding to resolve binding expressions.
 */
@property(nonatomic, readonly, weak, nullable) id<AKABindingContextProtocol>  bindingContext;

/**
 The binding controller owning and managing this binding.

 @note This uses the bindingContext property as storage and will return nil if bindingContext is not an instance of AKABindingController.
 */
@property(nonatomic, readonly, weak, nullable) AKABindingController*          controller;

/**
 The binding delegate.

 @note deprecated. Use the binding behavior delegates (public interface). TODO: this property will be made available for sub classes only (or maybe internal).
 */
@property(nonatomic, readonly, weak, nullable) id<AKABindingDelegate>         delegate;

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

