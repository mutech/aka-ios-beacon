//
//  AKAControlsErrors.m
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlsErrors_Internal.h"
#import "AKALog.h"

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

#pragma mark - Control Ownership

+ (void)invalidAttemptToSetOwnerOfControl:(AKAControl*)control
                                  ownedBy:(AKACompositeControl*)currentOwner
                               toNewOwner:(AKACompositeControl*)owner
{
    NSString* message = [NSString stringWithFormat:@"Invalid attempt to set owner of control %@ to %@: control already owned by %@", control, owner, currentOwner];
    [self handleErrorWithMessage:message recovery:nil];
}

#pragma mark - Composite Control Member Activation

+ (void)invalidAttemptToActivateNonMemberControl:(AKAControl *)control
                                      inComposite:(AKACompositeControl *)composite
{
    NSString* message = [NSString stringWithFormat:@"Attempt to activate control %@ which is not a direct member of %@", control, composite];
    [self handleErrorWithMessage:message recovery:nil];
}

+ (void)    invalidAttemptToActivate:(AKAControl *)control
                         inComposite:(AKACompositeControl *)composite
     whileAnotherMemberIsStillActive:(AKAControl *)oldActive
                            recovery:(BOOL (^)())recover
{
    NSString* message = [NSString stringWithFormat:@"Attempt to activate control %@ while another member control %@ is active in composite control %@", control, oldActive, composite];
    [self handleErrorWithMessage:message recovery:recover];
}

#pragma mark - Control View Errors

+ (NSError *)errorForTextEditorControlView:(AKAEditorControlView *)editorControlView
                               invalidView:(id)view
                                   forRole:(NSString*)role
                              expectedType:(Class)type
{
    NSString* description = [NSString stringWithFormat:@"%@: Invalid view %@ for role %@", editorControlView, view, role];
    NSString* reason = [NSString stringWithFormat:@"Wrong type %@, subview is expected to be a kind of %@", [view class], type];
    return [NSError errorWithDomain:[self akaControlsErrorDomain]
                               code:AKATextEditorControlViewRequiresUITextFieldEditor
                           userInfo:@{ NSLocalizedDescriptionKey: description,
                                       NSLocalizedFailureReasonErrorKey: reason }];
}

#pragma mark - Binding Errors

+ (void)invalidAttemptToBindView:(id)view
                       toBinding:(AKAViewBinding*)binding
{
    NSString* message = [NSString stringWithFormat:@"Invalid attempt to bind view %@ to binding %@", view, binding];
    [self handleErrorWithMessage:message recovery:nil];
}


#pragma mark - Themes

+ (void)invalidLayoutRelationSpecification:(id)relationSpecification
{
    NSString* message = [NSString stringWithFormat:@"Invalid relation specification %@. Relations can be specified as NSString (<=, ==, >=) or as NSNumber containing a NSLayoutRelation constant.", relationSpecification];
    [self handleErrorWithMessage:message recovery:nil];
}

@end
