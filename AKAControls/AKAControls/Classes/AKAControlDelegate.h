//
//  AKAControlDelegate.h
//  AKAControls
//
//  Created by Michael Utech on 17.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKAControl;

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
 * returning YES.
 *
 * @note The corrected value will be revalidated. Please take care to ensure
 * that this process will not result in an endless loop.
 *
 * @note The specified value in viewValueStorage is not necessarily the value
 *       in <viewValue> (either because another value has been validated or
 *       because a delegate changed the value and re-validation failed.
 *
 * @warning Do not assign to the control's <viewValue property> from this delegate method.
 *
 * @param control The control which performed the validation
 * @param viewValueStorage A pointer to the invalid view value
 * @param error The error instance describing the problem of nil if the validation routine did not supply an error.
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
- (void)                        control:(AKAControl*)control
                        validationState:(NSError*)oldError
                              changedTo:(NSError*)newError;

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

@protocol AKAControlDelegate <
    AKAControlConverterDelegate,
    AKAControlValidationDelegate,
    AKAControlActivationDelegate
>
@end
