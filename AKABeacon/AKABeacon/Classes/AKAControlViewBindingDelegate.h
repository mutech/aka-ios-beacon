//
//  AKAControlViewBindingDelegate.h
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;

@class AKAControlViewBinding;
#define req_AKAControlViewBinding AKAControlViewBinding*_Nonnull


@protocol AKAControlViewBindingDelegate<AKAViewBindingDelegate>

#pragma mark - Change Tracking


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
- (void)                                            binding:(req_AKAControlViewBinding)binding
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
- (void)                                            binding:(req_AKAControlViewBinding)binding
                    sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                                   convertedFromTargetValue:(opt_id)targetValue
                                                  withError:(opt_NSError)error;

// TODO: support delegate method in AKAControlDelegate propagation:
/**
 * Informs the delegate, that the target (f.e. view-) value changed to the specified
 * invalid value. The source value will not be updated by the binding and the target
 * value remains "dirty". This is a common situation occuring when the user enters
 * invalid data. The delegate or the controls framework should present a validation
 * message (depending on the configuration and setup of the framework and the app).
 */
@optional
- (void)                                            binding:(req_AKAControlViewBinding)binding
                           targetValueDidChangeFromOldValue:(opt_id)oldTargetValue
                                             toInvalidValue:(opt_id)newTargetValue
                                                  withError:(opt_NSError)error;

@optional
/**
 * Determines whether the binding should update the source value from the specified
 * oldSourceValue to the specified newSourceValue as a result of a source value change
 * from oldTargetValue to newTargetValue.
 *
 * If the delegate returns NO, the source value is not updated. The target value will
 * never be updated. It is the responsability of the delegate to synchronize the
 * source and target values participating in the binding if it vetoes the update.
 *
 * @param binding the binding
 * @param oldSourceValue the old source (f.e. model-) value
 * @param newSourceValue the new source value
 * @param oldTargetValue the old target (f.e. view-) value
 * @param newTargetValue the new target value
 *
 * @return YES if the binding should update the source value, NO otherwise.
 */
- (BOOL)                                      shouldBinding:(req_AKAControlViewBinding)binding
                                          updateSourceValue:(opt_id)oldSourceValue
                                                         to:(opt_id)newSourceValue
                                             forTargetValue:(opt_id)oldTargetValue
                                                   changeTo:(opt_id)newTargetValue;

@optional
- (void)                                            binding:(req_AKAControlViewBinding)binding
                                      willUpdateSourceValue:(opt_id)oldSourceValue
                                                         to:(opt_id)newSourceValue;

@optional
- (void)                                            binding:(req_AKAControlViewBinding)binding
                                       didUpdateSourceValue:(opt_id)oldSourceValue
                                                         to:(opt_id)newSourceValue;
@end

