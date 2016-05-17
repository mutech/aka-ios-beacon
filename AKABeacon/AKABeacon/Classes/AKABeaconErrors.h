//
//  AKABeaconErrors.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

#import "AKAErrors.h"

typedef NS_ENUM(NSInteger, AKAControlsErrorCodes)
{
    AKABeaconErrorCodesMin = 1,

    // TODO: review error codes and errors, much of this became obsolete:

    // Conversion Error Codes
    AKAConversionErrorInvalidModelValueType,
    AKAConversionErrorInvalidViewValueType,
    AKAConversionErrorInvalidViewValueNumberParseError,

    // Validation Error Codes
    AKAValidationErrorInvalidEmailValueType,
    AKAValidationErrorInvalidEmailNotMatchingRegEx,

    // Reserved error codes for binding errors
    AKABindingErrorCodesMin = 1000,
    AKABindingErrorCodesMax = 1999,
};

@class AKAControl;
@class AKACompositeControl;
@class AKAEditorControlView;
@class UIView;

/**
 * Provides common definitions and settings concerning errors originating in or detected
 * by AKAControls.
 */
@interface AKABeaconErrors : AKAErrors

/**
 * The error domain used for errors created by AKAControls.
 *
 * @return A string identifying errors created by this framework
 */
+ (NSString*)akaControlsErrorDomain;

/**
 * Determines whether error handling routines should attempt to perform recovery actions
 * to correct errors.
 *
 * @return YES if recovery actions are enabled.
 */
+ (BOOL)attemptRecoveryActions;

/**
 * Enables or disables recovery actions. To ensure that you don't miss errors in your code,
 * you should not enable this option during development.
 *
 * @param attemptRecoveryActions YES to enable recovery actions, NO otherwise.
 */
+ (void)setAttemptRecoveryActions:(BOOL)attemptRecoveryActions;

@end
