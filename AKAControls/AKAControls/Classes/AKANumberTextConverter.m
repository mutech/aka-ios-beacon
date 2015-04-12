//
//  AKANumberTextConverter.m
//  AKAControls
//
//  Created by Michael Utech on 12.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKANumberTextConverter.h"
#import "AKAControlsErrors_Internal.h"

@interface AKANumberTextConverter()

@property(nonatomic, strong) NSNumberFormatter* numberFormatter;

@end

@implementation AKANumberTextConverter

- (instancetype)init
{
    if (self = [super init])
    {
        self.numberFormatter = [[NSNumberFormatter alloc] init];
        self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.numberFormatter.usesGroupingSeparator = NO;
        self.numberFormatter.maximumFractionDigits = 100; // TODO: specify the value corresponding to the maximum possible number of fractional digits representable as NSNumber
    }
    return self;
}

- (BOOL)convertModelValue:(id)modelValue
              toViewValue:(__autoreleasing id *)viewValueStorage
                    error:(NSError *__autoreleasing *)error
{
    BOOL result = YES;
    id viewValue = modelValue;
    if (modelValue != nil)
    {
        if ([modelValue isKindOfClass:[NSNumber class]])
        {
            viewValue = [self.numberFormatter stringFromNumber:modelValue];
        }
        else
        {
            result = NO;
            if (error)
            {
                *error = [AKAControlsErrors conversionErrorInvalidModelValue:modelValue
                                                                        type:[modelValue class] expectedType:[NSNumber class] forConversionToType:[NSString class]];
            }
        }
    }

    if (result)
    {
        *viewValueStorage = viewValue;
    }
    return result;
}

- (BOOL)convertViewValue:(id)viewValue
            toModelValue:(__autoreleasing id *)modelValueStorage
                   error:(NSError *__autoreleasing *)error
{
    BOOL result = YES;
    id modelValue = nil;
    if (viewValue != nil)
    {
        if ([viewValue isKindOfClass:[NSString class]])
        {
            NSString* text = viewValue;
            NSString* description = nil;
            result = [self.numberFormatter getObjectValue:&modelValue
                                                forString:text
                                         errorDescription:&description];
            if (result && [text hasSuffix:self.numberFormatter.decimalSeparator])
            {
                result = NO;
                description = @"Incomplete number (trailing decimal separator)";
            }
            if (!result && error != nil)
            {
                *error = [AKAControlsErrors conversionErrorInvalidViewValue:text
                                                  notAValidNumberParseError:description];
            }
        }
        else
        {
            result = NO;
            if (error)
            {
                *error = [AKAControlsErrors conversionErrorInvalidViewValue:viewValue
                                                                       type:[viewValue class] expectedType:[NSString class] forConversionToType:[NSNumber class]];
            }
        }
    }

    if (result)
    {
        *modelValueStorage = modelValue;
    }
    return result;
}

@end
