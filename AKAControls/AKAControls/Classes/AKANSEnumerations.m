//
//  AKANSEnumerations.m
//  AKAControls
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKANSEnumerations.h"

@implementation AKANSEnumerations

+ (opt_NSNumber)                              enumeratedValueForName:(opt_NSString)name
                                                        inDictionary:(req_NSDictionary)dictionary
{
    NSNumber* result = name.length > 0 ? dictionary[(req_NSString)name] : nil;

    NSAssert(result != nil, @"%@ is not a valid enumeration value code", name);

    return result;
}

+ (opt_NSString)                              nameForEnumeratedValue:(opt_NSNumber)value
                                                        inDictionary:(NSDictionary*)dictionary
{
    __block NSString* result = nil;

    [dictionary enumerateKeysAndObjectsUsingBlock:^(req_id key, req_id obj, outreq_BOOL stop)
     {
         (void)stop;
         if (value != nil && [obj isKindOfClass:[NSNumber class]])
         {
             if ([((req_NSNumber)obj) isEqualToNumber:(req_NSNumber)value])
             {
                 result = key;
             }
         }
     }];

    return result;
}

#pragma mark - Locales

+ (NSLocale*)localeForObject:(id)localeOrName
{
    NSLocale* result = nil;

    if ([localeOrName isKindOfClass:[NSLocale class]])
    {
        result = localeOrName;
    }
    else if ([localeOrName isKindOfClass:[NSString class]])
    {
        result = [NSLocale localeWithLocaleIdentifier:localeOrName];
    }

    return result;
}

#pragma mark - NSNumberFormatter Enumerations

+ (NSNumber*)numberFormatterStyleForObject:(id)nameOrEnumeratedValue
{
    NSNumber* result = nil;

    if ([nameOrEnumeratedValue isKindOfClass:[NSString class]])
    {
        result = [AKANSEnumerations enumeratedValueForName:nameOrEnumeratedValue
                                              inDictionary:[AKANSEnumerations numberStylesByName]];
    }
    else if ([nameOrEnumeratedValue isKindOfClass:[NSNumber class]])
    {
        result = nameOrEnumeratedValue;
    }

    return result;
}

+ (NSDictionary<NSString*, NSNumber*>*)           numberStylesByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{ @"Currency":            @(NSNumberFormatterCurrencyStyle),
               @"Decimal":             @(NSNumberFormatterDecimalStyle),
               @"Percent":             @(NSNumberFormatterPercentStyle),
               @"Scientific":          @(NSNumberFormatterScientificStyle),
               @"SpellOut":            @(NSNumberFormatterSpellOutStyle) };
    });

    return result;
}

+ (NSNumber*)numberFormatterPadForObject:(id)nameOrEnumeratedValue
{
    NSNumber* result = nil;

    if ([nameOrEnumeratedValue isKindOfClass:[NSString class]])
    {
        result = [AKANSEnumerations enumeratedValueForName:nameOrEnumeratedValue
                                              inDictionary:[self padPositionsByName]];
    }
    else if ([nameOrEnumeratedValue isKindOfClass:[NSNumber class]])
    {
        result = nameOrEnumeratedValue;
    }

    return result;
}

+ (NSDictionary<NSString*, NSNumber*>*)           padPositionsByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{ @"BeforePrefix":       @(NSNumberFormatterPadBeforePrefix),
               @"AfterPrefix":        @(NSNumberFormatterPadAfterPrefix),
               @"BeforeSuffix":       @(NSNumberFormatterPadBeforeSuffix),
               @"AfterSuffix":        @(NSNumberFormatterPadAfterSuffix), };
    });

    return result;
}

+ (NSNumber*)numberFormatterRoundingModeForObject:(id)nameOrEnumeratedValue
{
    NSNumber* result = nil;

    if ([nameOrEnumeratedValue isKindOfClass:[NSString class]])
    {
        result = [AKANSEnumerations enumeratedValueForName:nameOrEnumeratedValue
                                              inDictionary:[self roundingModesByName]];
    }
    else if ([nameOrEnumeratedValue isKindOfClass:[NSNumber class]])
    {
        result = nameOrEnumeratedValue;
    }

    return result;
}

+ (NSDictionary<NSString*, NSNumber*>*)          roundingModesByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{ @"Ceiling":             @(NSNumberFormatterRoundCeiling),
               @"Floor":               @(NSNumberFormatterRoundFloor),
               @"Down":                @(NSNumberFormatterRoundDown),
               @"Up":                  @(NSNumberFormatterRoundUp),
               @"HalfEven":            @(NSNumberFormatterRoundHalfEven),
               @"HalfDown":            @(NSNumberFormatterRoundHalfDown),
               @"HalfUp":              @(NSNumberFormatterRoundHalfUp), };
    });

    return result;
}

#pragma mark - NSFormatter Enumerations

+ (NSNumber*)formattingContextForObject:(id)nameOrEnumeratedValue
{
    NSNumber* result = nil;

    if ([nameOrEnumeratedValue isKindOfClass:[NSString class]])
    {
        result = [AKANSEnumerations enumeratedValueForName:nameOrEnumeratedValue
                                              inDictionary:[self formattingContextsByName]];
    }
    else if ([nameOrEnumeratedValue isKindOfClass:[NSNumber class]])
    {
        result = nameOrEnumeratedValue;
    }

    return result;
}

+ (NSDictionary<NSString*, NSNumber*>*)     formattingContextsByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{ @"Unknown":            @(NSFormattingContextUnknown),
               @"Dynamic":            @(NSFormattingContextDynamic),
               @"Standalone":         @(NSFormattingContextStandalone),
               @"ListItem":           @(NSFormattingContextListItem),
               @"BeginningOfSentence": @(NSFormattingContextBeginningOfSentence),
               @"MiddleOfSentence":   @(NSFormattingContextMiddleOfSentence), };
    });

    return result;
}

#pragma mark - NSDateFormatter Enumerations

+ (NSNumber*)dateFormatterStyleForObject:(id)nameOrEnumeratedValue
{
    NSNumber* result = nil;

    if ([nameOrEnumeratedValue isKindOfClass:[NSString class]])
    {
        result = [AKANSEnumerations enumeratedValueForName:nameOrEnumeratedValue
                                              inDictionary:[self dateFormatterStylesByName]];
    }
    else if ([nameOrEnumeratedValue isKindOfClass:[NSNumber class]])
    {
        result = nameOrEnumeratedValue;
    }

    return result;
}

+ (NSDictionary<NSString*, NSNumber*>*)    dateFormatterStylesByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
            @{ @"NoStyle":            @(NSDateFormatterNoStyle),
               @"ShortStyle":         @(NSDateFormatterShortStyle),
               @"MediumStyle":        @(NSDateFormatterMediumStyle),
               @"LongStyle":          @(NSDateFormatterLongStyle),
               @"FullStyle":          @(NSDateFormatterFullStyle) };
    });

    return result;
}

+ (NSCalendar*)calendarForObject:(id)calendarOrIdentifier
{
    NSCalendar* result = nil;

    if ([calendarOrIdentifier isKindOfClass:[NSString class]])
    {
        result = [NSCalendar calendarWithIdentifier:calendarOrIdentifier];
    }
    else if ([calendarOrIdentifier isKindOfClass:[NSCalendar class]])
    {
        result = calendarOrIdentifier;
    }

    return result;
}

+ (NSTimeZone*)timeZoneForObject:(id)timeZoneOrNameOrAbbrev
{
    NSTimeZone* result = nil;

    if ([timeZoneOrNameOrAbbrev isKindOfClass:[NSString class]])
    {
        result = [NSTimeZone timeZoneWithName:timeZoneOrNameOrAbbrev];

        if (result == nil)
        {
            result = [NSTimeZone timeZoneWithAbbreviation:timeZoneOrNameOrAbbrev];
        }
    }
    else if ([timeZoneOrNameOrAbbrev isKindOfClass:[NSTimeZone class]])
    {
        result = timeZoneOrNameOrAbbrev;
    }

    return result;
}

@end
