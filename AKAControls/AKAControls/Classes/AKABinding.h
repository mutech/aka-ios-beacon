//
//  AKABinding.h
//  AKAControls
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKAProperty;


@class AKABinding;
@protocol AKABindingDelegate;
typedef AKABinding* _Nullable                               opt_AKABinding;
typedef AKABinding* _Nonnull                                req_AKABinding;
typedef id<AKABindingDelegate>_Nullable                     opt_AKABindingDelegate;


@protocol AKABindingDelegate<NSObject>

@optional
/**
 * Informs the delegate, that an attempt to update the
 * target value for a source value change to the specified
 * value failed because the source value could not be converted
 * to a valid target value.
 *
 * @param binding the binding observing source value changes.
 * @param sourceValue the source value that could not be converted
 * @param error an error object providing additional information.
 */
- (void)                                binding:(req_AKABinding)binding
         targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                         toTargetValueWithError:(opt_NSError)error;

@optional
/**
 * Informs the delegate, that an attempt to update the
 * target value for a source value change to the specified
 * value failed because the new target value is not valid.
 *
 * @param binding the binding observing the source value change
 * @param targetValue the target value obtained by converstion from the source value.
 * @param sourceValue the source value which itself passed validation.
 * @param error an error object providing additional information.
 */
- (void)                                binding:(req_AKABinding)binding
        targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                       convertedFromSourceValue:(opt_id)sourceValue
                                      withError:(opt_NSError)error;

@optional
/**
 * Informs the delegate, that an attempt to update the
 * source (model) value for a target (view) value change to the specified
 * value failed, because the target value could not be converted
 * to a valid source value.
 *
 * @param binding the binding observing target value changes.
 * @param targetValue the target value that could not be converted.
 * @param error an error object providing additional information.
 */
- (void)                                binding:(req_AKABinding)binding
         sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                         toSourceValueWithError:(opt_NSError)error;

@optional
/**
 * Informs the delegate, that an attempt to update the
 * source value for a target value change to the specified
 * value failed because the target value is not valid.
 *
 * @param binding the binding observing the source value change
 * @param targetValue the invalid target value
 * @param error an error object providing additional information.
 */
- (void)                                binding:(req_AKABinding)binding
        sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                       convertedFromTargetValue:(opt_id)targetValue
                                      withError:(opt_NSError)error;

@end


@interface AKABinding : NSObject

@property(nonatomic, readonly, nonnull) AKAProperty*        bindingSource;
@property(nonatomic, readonly, nonnull) AKAProperty*        bindingTarget;
@property(nonatomic, readonly, weak) id<AKABindingDelegate> delegate;


- (instancetype _Nullable)           initWithDelegate:(opt_AKABindingDelegate)delegate;

- (void)             sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                           toNewValue:(opt_id)newSourceValue;

- (void)             targetValueDidChangeFromOldValue:(opt_id)oldTargetValue
                                           toNewValue:(opt_id)newTargetValue;

- (BOOL)startObservingChanges;
- (BOOL)stopObservingChanges;

@end