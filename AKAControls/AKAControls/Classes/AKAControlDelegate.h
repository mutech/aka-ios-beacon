//
//  AKAControlDelegate.h
//  AKAControls
//
//  Created by Michael Utech on 17.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKAControl;
@class AKACompositeControl;

@protocol AKAControlConverterDelegate <NSObject>

@optional
- (BOOL)                control:(AKAControl*)control
                      viewValue:(inout id*)viewValueStorage
      conversionFailedWithError:(NSError*__autoreleasing*)error;

@end

@protocol AKAControlValidationDelegate <NSObject>

@optional
/**
 * The specified control validated the specified view value resulting
 * in the specified error.
 *
 * The delegate can correct the view value by assigning a valid value and
 * returning YES. It can also replace the error instance.
 *
 * @note The corrected value will be revalidated. Please take care to ensure
 * that this process will not result in an endless loop.
 *
 * @note The specified value in viewValueStorage is not necessarily the value
 *       in <viewValue> (either because another value has been validated or
 *       because another delegate changed the value and re-validation failed.
 *
 * @warning Do not assign to the control's <viewValue property> from this delegate method.
 *
 * @param control The control which performed the validation
 * @param viewValueStorage A pointer to the invalid view value
 * @param error A pointer referring to the error instance describing the problem of nil
 *              if the validation routine did not supply an error.
 *
 * @return YES if the delegate corrected the view value, NO otherwise.
 */
- (BOOL)                        control:(AKAControl*)control
                              viewValue:(id)viewValue
                  convertedToModelValue:(inout id*)modelValueStorage
              validationFailedWithError:(inout NSError*__autoreleasing*)error;

@optional
- (BOOL)                        control:(AKAControl*)control
                             modelValue:(inout id*)viewValueStorage
              validationFailedWithError:(inout NSError*__autoreleasing*)error;

@optional
/**
 * The specified control changed its validation state from the specified oldError
 * to the specified newError.
 *
 * Calling the specified block will - if it is not nil - update the validation state
 * display (e.g. an error message) in the controls view hierarchy. You can embed a call
 * to this block, for example to animate layout changes resulting from this update.
 * If no delegate in the notification chain returns YES, the block will
 * be called after the notification chain has been traversed.
 *
 * @note The delegate has to return YES if it calls the block to ensure that the block
 *      is only called once.
 *
 * @param control the control that changed its validation state
 * @param oldError the previous validation state (nil means the control was valid)
 * @param newError the current validation state (nil means the control is valid)
 * @param block a block that will update the controls validation state display. An undefined value
 *              (nil) indicates that the control does not support displaying validation states
 *              of that the display was already updated.
 * @return YES if the delegate called the specified block (or if it wishes to suppress the
 *          update of the validation display), NO otherwise
 */
- (BOOL)                        control:(AKAControl*)control
                        validationState:(NSError*)oldError
                              changedTo:(NSError*)newError
         updateValidationMessageDisplay:(void(^)())block;

@end

@protocol AKAControlActivationDelegate <NSObject>

#pragma mark Activation

@optional
- (BOOL)shouldControlActivate:(AKAControl*)memberControl;

@optional
- (void)controlWillActivate:(AKAControl*)memberControl;

@optional
- (void)controlDidActivate:(AKAControl*)memberControl;

@optional
- (BOOL)shouldControlDeactivate:(AKAControl*)memberControl;

@optional
- (void)controlWillDeactivate:(AKAControl*)memberControl;

@optional
- (void)controlDidDeactivate:(AKAControl*)memberControl;

@end

@protocol AKAControlMembershipDelegate <NSObject>

@optional
- (void)        control:(AKACompositeControl*)compositeControl
         willAddControl:(AKAControl*)memberControl
                atIndex:(NSUInteger)index;

@optional
- (void)        control:(AKACompositeControl*)compositeControl
          didAddControl:(AKAControl*)memberControl
                atIndex:(NSUInteger)index;

@optional
- (void)        control:(AKACompositeControl*)compositeControl
      willRemoveControl:(AKAControl*)memberControl
              fromIndex:(NSUInteger)index;

@optional
- (void)        control:(AKACompositeControl*)compositeControl
       didRemoveControl:(AKAControl*)memberControl
              fromIndex:(NSUInteger)index;

@end

@protocol AKAControlDelegate <
    AKAControlConverterDelegate,
    AKAControlValidationDelegate,
    AKAControlActivationDelegate,
    AKAControlMembershipDelegate
>

@optional
- (void)control:(AKAControl*)control modelValueChangedFrom:(id)oldValue to:(id)newValue;

@end
