//
//  AKABindingDelegate.h
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
#import "AKANullability.h"

#import "AKABeaconNullability.h"
#import "AKAControlDelegate.h"

@protocol AKABindingDelegate<NSObject>

@optional
- (void)                                            binding:(req_AKABinding)binding
                           sourceValueDidChangeFromOldValue:(id _Nullable)oldSourceValue
                                                         to:(id _Nullable)newSourceValue;

@optional
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
- (void)                                            binding:(req_AKABinding)binding
                           sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                             toInvalidValue:(opt_id)newSourceValue
                                                  withError:(opt_NSError)error;

@optional
/**
 Informs the delegate, that the source value of the array item at the specified index
 changed. Please note that this refers to binding expression array constants only (and
 then for items defined as non-constant binding expressions

 @param binding  a binding with a literal array constant primary binding expression.
 @param index    the index of the array item
 @param oldValue the old array item source value
 @param newValue the new array item source value.
 */
- (void)                                            binding:(req_AKABinding)binding
                                     sourceArrayItemAtIndex:(NSUInteger)index
                                                      value:(opt_id)oldValue
                                                didChangeTo:(opt_id)newValue;

@optional
- (void)                                            binding:(req_AKABinding)binding
                                     targetArrayItemAtIndex:(NSUInteger)index
                                                      value:(opt_id)oldValue
                                                didChangeTo:(opt_id)newValue;

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
/**
 Called when the bindings target value has been updated from oldTargetValue to newTargetValue as a result of the binding's oldSourceValue changing to newSourceValue.

 @note When the binding initializes the target value as part of startObservingChanges, the old and newSourceValue might have the same value. This may also be the case if the sourceValueProperty fires change events when its value has been çhanged to the same value.

 @note some bindings do not change the target value as response to source value changes but update its state instead.

 @param binding the binding which updated its target value or target value state
 @param oldTargetValue the target value before the binding updated it
 @param newTargetValue the new target value
 @param oldSourceValue the old source value
 @param newSourceValue the new source value
 */
- (void)                                            binding:(req_AKABinding)binding
                                       didUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
                                             forSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue;

@end

