//
//  AKAControlsErrors_Internal.h
//  AKAControls
//
//  Created by Michael Utech on 04.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlsErrors.h"

@interface AKAControlsErrors ()

#pragma mark - Conversion Errors

+ (NSError*)conversionErrorInvalidModelValue:(id)modelValue
                                        type:(Class)modelValueType
                                expectedType:(Class)expectedType
                         forConversionToType:(Class)targetType;

+ (NSError*)conversionErrorInvalidViewValue:(id)modelValue
                                       type:(Class)modelValueType
                               expectedType:(Class)expectedType
                        forConversionToType:(Class)targetType;

+ (NSError*)conversionErrorInvalidViewValue:(id)viewValue
                  notAValidNumberParseError:(NSString*)reason;

#pragma mark - Control Ownership

+ (void)invalidAttemptToSetOwnerOfControl:(AKAControl*)control
                                  ownedBy:(AKACompositeControl*)currentOwner
                               toNewOwner:(AKACompositeControl*)owner;

#pragma mark - Composite Control Member Activation

+ (void)invalidAttemptToActivate:(AKAControl*)control
                     inComposite:(AKACompositeControl*)composite
 whileAnotherMemberIsStillActive:(AKAControl*)oldActive
                        recovery:(BOOL(^)())recover;

+ (void)invalidAttemptToActivateNonMemberControl:(AKAControl*)control
                                     inComposite:(AKACompositeControl*)composite;

#pragma mark - ControlView Errors


+ (NSError *)errorForTextEditorControlView:(AKAEditorControlView *)editorControlView
                               invalidView:(id)view
                                   forRole:(NSString*)role
                              expectedType:(Class)type;

#pragma mark - Binding Errors

+ (void)invalidAttemptToBindView:(id)view
                       toBinding:(AKAViewBinding*)binding;

#pragma mark - Themes

+ (void)invalidLayoutRelationSpecification:(id)relationSpecification;

@end
