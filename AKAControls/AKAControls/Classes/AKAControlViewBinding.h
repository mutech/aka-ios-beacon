//
//  AKAControlViewBinding.h
//  AKAControls
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAViewBinding.h"
#import "AKAControlViewBindingDelegate.h"

@interface AKAControlViewBinding: AKAViewBinding

#pragma mark - Configuration

@property(nonatomic, readonly, weak) id<AKAControlViewBindingDelegate> delegate;

@end


@interface AKAControlViewBinding(Protected)

#pragma mark - Conversion

/**
 * Converts the specified targetValue to a source value and stores it in the specified
 * sourceValueStore if the conversion succeeded.
 *
 * @param targetValue the target value to convert
 * @param sourceValueStore storage reference for the conversion result
 * @param error storage result for error information used if the conversion failed
 *
 * @return YES if the conversion was successful and NO otherwise.
 */
- (BOOL)                                 convertTargetValue:(opt_id)targetValue
                                              toSourceValue:(out_id)sourceValueStore
                                                      error:(out_NSError)error;

#pragma mark - Change Tracking

/**
 * Processes changes of the binding target value. This should be called by the change observer
 * of the binding target value whenever the binding target value changes as a result of user
 * interaction. UIKit does not react to programmatic changes to controls (neither delegate methods
 * nor events take notice) and consequently, this method should also generally not be called if changes
 * are not triggered by user interactions.
 *
 * @param oldTargetValue the binding target value before the change
 * @param newTargetValue the new binding target value
 */
- (void)                   targetValueDidChangeFromOldValue:(opt_id)oldTargetValue
                                                 toNewValue:(opt_id)newTargetValue;

#pragma mark - Change Propagation

@end


@interface AKAControlViewBinding(Internal)

#pragma mark - Change Propagation

/**
 * Indicates whether the bindings source value is currently being updates as a result of
 * a binding target value change. This property is used to prevent the binding from being
 * trapped in update cycles.
 */
@property(nonatomic, readonly)BOOL isUpdatingSourceValueForTargetValueChange;

/**
 * Determines if the source (f.e. model-) value should be updated as a result of a changed
 * target (f.e. view-) value. The default implementation returns NO, if the target value is
 * currently being updated (and thus would trigger an update cycle).
 *
 * @warning: Sub classes redefining this method should always call the super implementation and never return YES if it returned NO.
 *
 * @param oldTargetValue the old target value
 * @param newTargetValue the new target value
 * @param targetValue the new target value or the result of the target value validation replacing an invalid value.
 *
 * @return YES if the source value should be updated, NO otherwise.
 */
- (BOOL)              shouldUpdateSourceValueForTargetValue:(opt_id)oldTargetValue
                                                   changeTo:(opt_id)newTargetValue
                                                validatedTo:(opt_id)targetValue;

@end
