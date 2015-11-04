//
//  AKAControlsErrors.m
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAControlsErrors_Internal.h"
@import AKACommons.AKALog;

@implementation AKAControlsErrors

static NSString* const akaControlsErrorDomain = @"com.aka-labs.errors.AKAControls";
static BOOL _attemptRecoveryActions = YES;

+ (NSString *)akaControlsErrorDomain
{
    return akaControlsErrorDomain;
}

+ (BOOL)attemptRecoveryActions
{
    return _attemptRecoveryActions;
}

+ (void)setAttemptRecoveryActions:(BOOL)attemptRecoveryActions
{
    _attemptRecoveryActions = attemptRecoveryActions;
}

+ (void)handleErrorWithMessage:(NSString*)message
                      recovery:(BOOL (^)())recover
{
    BOOL recovered = NO;
    if (recover != nil && [self attemptRecoveryActions])
    {
        AKALogWarn(@"%@", message);
        AKALogInfo(@"Attempting to recover from previous error...");
        recovered = recover();
        if (!recovered)
        {
            AKALogError(@"Recovery action for error \"%@\" failed", message);
        }
    }

    if (!recovered)
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:message
                                     userInfo:nil];

    }
}

#pragma mark - Conversion Errors

+ (NSError*)conversionErrorInvalidModelValue:(id)modelValue
                                        type:(Class)modelValueType
                                expectedType:(Class)expectedType
                         forConversionToType:(Class)targetType
{
    NSString* reason = [NSString stringWithFormat:@"Invalid model value type %@, expected an instance of %@",
                        NSStringFromClass(modelValueType),
                        NSStringFromClass(expectedType)];
    NSString* description = [NSString stringWithFormat:@"Conversion error: Failed to convert `%@' to an instance of %@: %@",
                             modelValue,
                             targetType,
                             reason];
    NSError* result = [NSError errorWithDomain:[self akaControlsErrorDomain]
                                          code:AKAConversionErrorInvalidModelValueType
                                      userInfo:
                       @{ NSLocalizedDescriptionKey: description,
                          NSLocalizedFailureReasonErrorKey: reason
                          }];
    return result;
}

+ (NSError*)conversionErrorInvalidViewValue:(id)modelValue
                                       type:(Class)modelValueType
                               expectedType:(Class)expectedType
                        forConversionToType:(Class)targetType
{
    NSString* reason = [NSString stringWithFormat:@"Invalid view value type %@, expected an instance of %@",
                        NSStringFromClass(modelValueType),
                        NSStringFromClass(expectedType)];
    NSString* description = [NSString stringWithFormat:@"Conversion error: Failed to convert `%@' to an instance of %@: %@",
                             modelValue,
                             targetType,
                             reason];
    NSError* result = [NSError errorWithDomain:[self akaControlsErrorDomain]
                                          code:AKAConversionErrorInvalidViewValueType
                                      userInfo:
                       @{ NSLocalizedDescriptionKey: description,
                          NSLocalizedFailureReasonErrorKey: reason
                          }];
    return result;
}

+ (NSError*)conversionErrorInvalidViewValue:(id)viewValue
                  notAValidNumberParseError:(NSString*)reason
{
    NSString* description = [NSString stringWithFormat:@"`%@' is not a valid number: %@",
                             viewValue,
                             reason];
    NSError* result = [NSError errorWithDomain:[self akaControlsErrorDomain]
                                          code:AKAConversionErrorInvalidViewValueNumberParseError
                                      userInfo:
                       @{ NSLocalizedDescriptionKey: description,
                          NSLocalizedFailureReasonErrorKey: reason
                          }];
    return result;
}

#pragma mark - Validation Errors

+ (NSError *)errorForInvalidEmailAddressValueType:(id)value
{
    NSString* reason = [NSString stringWithFormat:@"Invalid type %@, expected an instance of %@",
                        NSStringFromClass([value class]),
                        NSStringFromClass([NSString class])];
    NSString* description = [NSString stringWithFormat:@"Validation error: Failed to validate `%@' as email address: %@",
                             value,
                             reason];
    NSError* result = [NSError errorWithDomain:[self akaControlsErrorDomain]
                                          code:AKAValidationErrorInvalidEmailValueType
                                      userInfo:
                       @{ NSLocalizedDescriptionKey: description,
                          NSLocalizedFailureReasonErrorKey: reason
                          }];
    return result;
}

+ (NSError *)errorForInvalidEmailAddress:(NSString *)text withRegularExpression:(NSString *)failedRegEx
{
    (void)text;
    NSError* result = [NSError errorWithDomain:[self akaControlsErrorDomain]
                                          code:AKAValidationErrorInvalidEmailNotMatchingRegEx
                                      userInfo:
                       @{ NSLocalizedDescriptionKey: @"Invalid (RFC 2822) email address",
                          @"REGEX": failedRegEx
                          }];
    return result;
}

#pragma mark - Control Ownership

+ (void)invalidAttemptToSetOwnerOfControl:(AKAControl*)control
                                  ownedBy:(AKACompositeControl*)currentOwner
                               toNewOwner:(AKACompositeControl*)owner
{
    NSString* message = [NSString stringWithFormat:@"Invalid attempt to set owner of control %@ to %@: control already owned by %@", control, owner, currentOwner];
    [self handleErrorWithMessage:message recovery:nil];
}

#pragma mark - Themes

+ (void)invalidLayoutRelationSpecification:(id)relationSpecification
{
    NSString* message = [NSString stringWithFormat:@"Invalid relation specification %@. Relations can be specified as NSString (<=, ==, >=) or as NSNumber containing a NSLayoutRelation constant.", relationSpecification];
    [self handleErrorWithMessage:message recovery:nil];
}

@end
