//
//  AKABinding.h
//  AKABeacon
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKANullability;
@import AKACommons.AKAProperty;

#import "AKABeaconNullability.h"
#import "AKABindingDelegate.h"
#import "AKABindingExpression.h"
#import "AKABindingSpecification.h"

@interface AKABinding: NSObject<AKABindingDelegate>

#pragma mark - Initialization

/**
 Initializes a binding with the specified parameters.
 
 If an error occurs, the initializer returns nil and sets the error output parameter or, if the error storage is nil, throws an exception.

 @param target            the binding target (eg. a view or property)
 @param bindingExpression the binding expression
 @param bindingContext    the context in which the expression is evaluated
 @param delegate          the binding delegate
 @param error             error storage, if undefined, the initializer will throw an exception if an error is encountered.
 @throws NSException if an error occurred and the @c error parameter is nil.

 @return a new binding
 */
- (opt_instancetype)                         initWithTarget:(req_AKAProperty)target
                                                 expression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                                   delegate:(opt_AKABindingDelegate)delegate
                                                      error:(out_NSError)error;


#pragma mark - Configuration

@property(nonatomic, readonly, nonnull) AKAProperty*                bindingSource;
@property(nonatomic, readonly, nonnull) AKAProperty*                bindingTarget;
@property(nonatomic, readonly, weak) id<AKABindingContextProtocol>  bindingContext;
@property(nonatomic, readonly, weak) id<AKABindingDelegate>         delegate;

#pragma mark - Conversion

- (BOOL)                                 convertSourceValue:(opt_id)sourceValue
                                              toTargetValue:(out_id)targetValueStore
                                                      error:(out_NSError)error;

#pragma mark - Validation

- (BOOL)                                validateSourceValue:(inout_id)sourceValueStore
                                                      error:(out_NSError)error;

- (BOOL)                                validateTargetValue:(inout_id)targetValueStore
                                                      error:(out_NSError)error;

#pragma mark - Change Tracking

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                                 toNewValue:(opt_id)newSourceValue;


/**
 Called before the target value will be updated.
 
 Subclasses overriding this method *have* to call the super implementation.

 @param oldTargetValue old value
 @param newTargetValue new value
 */
- (void)                              willUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue;

/**
 Called after the target value has been updated.

 Subclasses overriding this method *have* to call the super implementation.

 @param oldTargetValue old value
 @param newTargetValue new value
 */
- (void)                               didUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue;

- (void)                             sourceArrayItemAtIndex:(NSUInteger)index
                                         valueDidChangeFrom:(opt_id)oldValue
                                                         to:(opt_id)newValue;

- (void)                             targetArrayItemAtIndex:(NSUInteger)index
                                         valueDidChangeFrom:(opt_id)oldValue
                                                         to:(opt_id)newValue;

- (BOOL)                              startObservingChanges;

- (BOOL)                               stopObservingChanges;

#pragma mark - Updating

/**
 Triggers an update of the target value from source.
 
 This can be used by subclasses to initialize the target value or to reset it, for example if configuration parameters have been changed and the target needs to be reinitialized.
 
 @note Please note that source value changes are tracked automatically and do not require this method to be called.
 */
- (void)                                  updateTargetValue;

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

