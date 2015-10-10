//
//  AKAControlsErrors.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKAErrors;

typedef NS_ENUM(NSInteger, AKAControlsErrorCodes)
{
    AKATextEditorControlViewRequiresUITextFieldEditor,

    // Conversion Error Codes
    AKAConversionErrorInvalidModelValueType,
    AKAConversionErrorInvalidViewValueType,
    AKAConversionErrorInvalidViewValueNumberParseError,

    // Validation Error Codes
    AKAValidationErrorInvalidEmailValueType,
    AKAValidationErrorInvalidEmailNotMatchingRegEx,
};

@class AKAControl;
@class AKACompositeControl;
@class AKAEditorControlView;
@class AKAObsoleteViewBinding;
@class UIView;

/**
 * Provides common definitions and settings concerning errors originating in or detected
 * by AKAControls.
 */
@interface AKAControlsErrors : AKAErrors

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
