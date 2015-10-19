//
//  AKABindingDelegate.h
//  AKAControls
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

#import "AKABinding.h"

@class AKABinding;
typedef AKABinding* _Nonnull                                req_AKABinding;

@protocol AKABindingDelegate;
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
- (void)                                            binding:(req_AKABinding)binding
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
- (void)                                            binding:(req_AKABinding)binding
                    targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                                   convertedFromSourceValue:(opt_id)sourceValue
                                                  withError:(opt_NSError)error;

// TODO: support delegate method in AKAControlDelegate propagation:
/**
 * Informs the delegate, that the source value changed to the specified invalid value.
 * The target value will not be updated. The delegate should react by indicating to the
 * user that the target value is outdated and cannot be updated.
 *
 * @note this is a kind of error that should not occur assuming that model values are
 *      required to be valid. This indicates a programming error (inconsistent
 *      and/or incomplete validation - the invalid data should not have made it to
 *      the data model/source).
 */
@optional
- (void)                                            binding:(req_AKABinding)binding
                           sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                             toInvalidValue:(opt_id)newSourceValue
                                                  withError:(opt_NSError)error;
@optional
/**
 * Determines whether the binding should update the target value from the specified
 * oldTargetValue to the specified newTargetValue as a result of a source value change
 * from oldSourceValue to newSourceValue.
 *
 * If the delegate returns NO, the target value is not updated. The source value will
 * never be updated. It is the responsability of the delegate to synchronize the
 * source and target values participating in the binding if it vetoes the update.
 *
 * @param binding the binding
 * @param oldTargetValue the old target (f.e. view-) value
 * @param newTargetValue the new target value
 * @param oldSourceValue the old source (f.e. model-) value
 * @param newSourceValue the new source value
 *
 * @return YES if the binding should update the target value, NO otherwise.
 */
- (BOOL)                                      shouldBinding:(req_AKABinding)binding
                                          updateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
                                             forSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue;

@optional
- (void)                                            binding:(req_AKABinding)binding
                                      willUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue;

@optional
- (void)                                            binding:(req_AKABinding)binding
                                       didUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue;

@end

