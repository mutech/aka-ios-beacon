//
//  AKABooleanTextConverter.m
//  AKABeacon
//
//  Created by Michael Utech on 09.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABooleanTextConverter.h"
#import "AKAControlsErrors_Internal.h"

@implementation AKABooleanTextConverter

#pragma mark - Initialization

- (instancetype)initWithBaseConverter:(id<AKAControlConverterProtocol>)baseConverter
                           textForYes:(NSString*)textForYes
                            textForNo:(NSString*)textForNo
                     textForUndefined:(NSString*)textForUndefined
{
    if (self = [self init])
    {
        _baseConverter = baseConverter;
        _textForYes = textForYes;
        _textForNo = textForNo;
        _textForUndefined = textForUndefined;
    }
    return self;
}

- (instancetype)initWithTextForYes:(NSString *)textForYes
                         textForNo:(NSString *)textForNo
                  textForUndefined:(NSString *)textForUndefined
{
    return [self initWithBaseConverter:nil
                            textForYes:textForYes
                             textForNo:textForNo
                      textForUndefined:textForUndefined];
}

#pragma mark - Conversion

- (BOOL)convertModelValue:(id)modelValue
              toViewValue:(__autoreleasing id *)viewValueStorage
                    error:(NSError *__autoreleasing *)error
{
    BOOL result = YES;
    id booleanValue = modelValue;

    if (self.baseConverter)
    {
        result = [self.baseConverter convertModelValue:modelValue
                                           toViewValue:&booleanValue
                                                 error:error];
    }
    if (result)
    {
        if (booleanValue == nil || [booleanValue isKindOfClass:[NSNull class]])
        {
            *viewValueStorage = self.textForUndefined;
        }
        else if ([booleanValue isKindOfClass:[NSNumber class]])
        {
            *viewValueStorage = (((NSNumber*)booleanValue).boolValue
                                 ? self.textForYes
                                 : self.textForNo);
        }
        else
        {
            result = NO;
            if (error != nil)
            {
                *error = [AKAControlsErrors conversionErrorInvalidModelValue:booleanValue
                                                                        type:[booleanValue class]
                                                                expectedType:[NSNumber class]
                                                         forConversionToType:[NSString class]];
            }
        }
    }
    return result;
}

- (BOOL)convertViewValue:(id)viewValue
            toModelValue:(__autoreleasing id *)modelValueStorage
                   error:(NSError *__autoreleasing *)error
{
    BOOL result = NO;
    NSNumber* modelValue = nil;
    if ([viewValue isKindOfClass:[NSNumber class]])
    {
        result = YES;
        modelValue = viewValue;
    }
    else if ([viewValue isKindOfClass:[NSString class]])
    {
        result = YES;
        if ([viewValue isEqualToString:self.textForYes])
        {
            modelValue = @(YES);
        }
        else if ([viewValue isEqualToString:self.textForNo])
        {
            modelValue = @(NO);
        }
        else if ([viewValue isEqualToString:self.textForUndefined])
        {
            modelValue = nil;
        }
        else
        {
            result = NO;
            if (error != nil)
            {
                *error = [AKAControlsErrors conversionErrorInvalidViewValue:viewValue
                                                  notAValidNumberParseError:[NSString stringWithFormat:@"Not one of %@, %@ or %@", self.textForYes, self.textForNo, self.textForUndefined]];
            }
        }
    }
    else if (viewValue == nil || [viewValue isKindOfClass:[NSNull class]])
    {
        viewValue = nil;
    }
    else
    {
        if (error != nil)
        {
            *error = [AKAControlsErrors conversionErrorInvalidViewValue:viewValue
                                                                   type:[viewValue class]
                                                           expectedType:[NSString class]
                                                    forConversionToType:[NSNumber class]];
        }
    }
    if (result)
    {
        if (self.baseConverter)
        {
            result = [self.baseConverter convertViewValue:modelValue
                                             toModelValue:modelValueStorage
                                                    error:error];
        }
        else
        {
            *modelValueStorage = modelValue;
        }
    }
    return result;
}

@end
