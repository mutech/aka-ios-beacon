//
//  AKAControlsErrors_Internal.h
//  AKABeacon
//
//  Created by Michael Utech on 04.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
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

#pragma mark - ControlView Errors


#pragma mark - Validation Errors

+ (NSError*)errorForInvalidEmailAddress:(NSString*)text
                  withRegularExpression:(NSString*)failedRegEx;

+ (NSError*)errorForInvalidEmailAddressValueType:(id)value;


#pragma mark - Themes

+ (void)invalidLayoutRelationSpecification:(id)relationSpecification;

@end
