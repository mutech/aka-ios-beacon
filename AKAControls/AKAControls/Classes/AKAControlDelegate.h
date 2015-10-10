//
//  AKAControlDelegate.h
//  AKAControls
//
//  Created by Michael Utech on 17.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

@class AKAControl;
typedef AKAControl*_Nonnull req_AKAControl;

@class AKABinding;
typedef AKABinding*_Nonnull req_AKABinding;

@class AKACompositeControl;
typedef AKACompositeControl*_Nonnull req_AKACompositeControl;

@protocol AKAControlConverterDelegate <NSObject>

@optional
- (BOOL)                control:(AKAControl*_Nonnull)control
                      viewValue:(inout_id)viewValueStorage
      conversionFailedWithError:(out_NSError)error;

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
- (BOOL)                        control:(req_AKAControl)control
                              viewValue:(opt_id)viewValue
                  convertedToModelValue:(inout_id)modelValueStorage
              validationFailedWithError:(out_NSError)error;

@optional
- (BOOL)                        control:(req_AKAControl)control
                             modelValue:(inout_id)viewValueStorage
              validationFailedWithError:(out_NSError)error;

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
- (BOOL)                        control:(req_AKAControl)control
                        validationState:(opt_NSError)oldError
                              changedTo:(opt_NSError)newError
         updateValidationMessageDisplay:(void(^_Nullable)())block;

@end

@protocol AKAControlActivationDelegate <NSObject>

#pragma mark - Binding Activation

- (void)                                              control:(req_AKAControl)control
                                                      binding:(req_AKABinding)binding
                                        responderWillActivate:(req_UIResponder)responder;
#pragma mark - Activation

@optional
- (BOOL)shouldControlActivate:(req_AKAControl)memberControl;

@optional
- (void)controlWillActivate:(req_AKAControl)memberControl;

@optional
- (void)controlDidActivate:(req_AKAControl)memberControl;

@optional
- (BOOL)shouldControlDeactivate:(req_AKAControl)memberControl;

@optional
- (void)controlWillDeactivate:(req_AKAControl)memberControl;

@optional
- (void)controlDidDeactivate:(req_AKAControl)memberControl;

@end

@protocol AKAControlMembershipDelegate <NSObject>

@optional
- (BOOL)  shouldControl:(req_AKACompositeControl)compositeControl
             addControl:(req_AKAControl)memberControl
                atIndex:(NSUInteger)index;

@optional
- (void)        control:(req_AKACompositeControl)compositeControl
         willAddControl:(req_AKAControl)memberControl
                atIndex:(NSUInteger)index;

@optional
- (void)        control:(req_AKACompositeControl)compositeControl
          didAddControl:(req_AKAControl)memberControl
                atIndex:(NSUInteger)index;

@optional
- (BOOL)  shouldControl:(req_AKACompositeControl)compositeControl
          removeControl:(req_AKAControl)memberControl
                atIndex:(NSUInteger)index;

@optional
- (void)        control:(req_AKACompositeControl)compositeControl
      willRemoveControl:(req_AKAControl)memberControl
              fromIndex:(NSUInteger)index;

@optional
- (void)        control:(req_AKACompositeControl)compositeControl
       didRemoveControl:(req_AKAControl)memberControl
              fromIndex:(NSUInteger)index;

@end

@protocol AKAControlDelegate <
    AKAControlConverterDelegate,
    AKAControlValidationDelegate,
    AKAControlActivationDelegate,
    AKAControlMembershipDelegate
>

@optional
- (void)control:(req_AKAControl)control modelValueChangedFrom:(opt_id)oldValue to:(opt_id)newValue;

@end
