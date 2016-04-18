//
//  AKANSEnumerations.m
//  AKABeacon
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKANSEnumerations.h"

// TODO: implement error handling for invalid types of key objects in enumeration queries

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

#pragma mark - NSFormatter Enumerations

+ (NSDictionary<NSString*, NSNumber*>*)   formattingUnitStylesByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
        @{ @"Short":              @(NSFormattingUnitStyleShort),
           @"Medium":             @(NSFormattingUnitStyleMedium),
           @"Long":               @(NSFormattingUnitStyleLong) };
    });

    return result;
}

+ (NSNumber*)formattingUnitStyleForObject:(id)nameOrEnumeratedValue
{
    NSNumber* result = nil;

    if ([nameOrEnumeratedValue isKindOfClass:[NSString class]])
    {
        result = [AKANSEnumerations enumeratedValueForName:nameOrEnumeratedValue
                                              inDictionary:[self formattingUnitStylesByName]];
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
           @"BeginningOfSentence":@(NSFormattingContextBeginningOfSentence),
           @"MiddleOfSentence":   @(NSFormattingContextMiddleOfSentence), };
    });

    return result;
}

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
            @{ @"CurrencyStyle":            @(NSNumberFormatterCurrencyStyle),
               @"DecimalStyle":             @(NSNumberFormatterDecimalStyle),
               @"PercentStyle":             @(NSNumberFormatterPercentStyle),
               @"ScientificStyle":          @(NSNumberFormatterScientificStyle),
               @"SpellOutStyle":            @(NSNumberFormatterSpellOutStyle) };
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
            @{ @"RoundCeiling":             @(NSNumberFormatterRoundCeiling),
               @"RoundFloor":               @(NSNumberFormatterRoundFloor),
               @"RoundDown":                @(NSNumberFormatterRoundDown),
               @"RoundUp":                  @(NSNumberFormatterRoundUp),
               @"RoundHalfEven":            @(NSNumberFormatterRoundHalfEven),
               @"RoundHalfDown":            @(NSNumberFormatterRoundHalfDown),
               @"RoundHalfUp":              @(NSNumberFormatterRoundHalfUp), };
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

#pragma mark - UIFont Enumerations

+ (NSDictionary<NSString*, NSString*>*)       uifontTextStylesByName
{
    static NSDictionary<NSString*, NSString*>* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
        @{ @"Headline":         UIFontTextStyleHeadline,
           @"Subheadline":      UIFontTextStyleSubheadline,
           @"Body":             UIFontTextStyleBody,
           @"Footnote":         UIFontTextStyleFootnote,
           @"Caption1":         UIFontTextStyleCaption1,
           @"Caption1":         UIFontTextStyleCaption2,
           @"Callout":          UIFontTextStyleCallout,
           @"Title1":           UIFontTextStyleTitle1,
           @"Title2":           UIFontTextStyleTitle2,
           @"Title3":           UIFontTextStyleTitle3,
           };
    });

    return result;
}

+ (NSString*)                                       textStyleForName:(opt_NSString)name
{
    NSString* result = name ? [self uifontTextStylesByName][(req_NSString)name] : nil;
    if (result == nil)
    {
        result = name;
    }
    return result;
}

+ (NSDictionary<NSString*, NSNumber*>*) uifontDescriptorTraitsByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
        @{ @"TraitItalic":              @(UIFontDescriptorTraitItalic),
           @"TraitBold":                @(UIFontDescriptorTraitBold),
           @"TraitExpanded":            @(UIFontDescriptorTraitExpanded),
           @"TraitCondensed":           @(UIFontDescriptorTraitCondensed),
           @"TraitMonoSpace":           @(UIFontDescriptorTraitMonoSpace),
           @"TraitVertical":            @(UIFontDescriptorTraitVertical),
           @"TraitUIOptimized":         @(UIFontDescriptorTraitUIOptimized),
           @"TraitTightLeading":        @(UIFontDescriptorTraitTightLeading),
           @"TraitLooseLeading":        @(UIFontDescriptorTraitLooseLeading),

           @"ClassUnknown":             @(UIFontDescriptorClassUnknown),
           @"ClassOldStyleSerifs":      @(UIFontDescriptorClassOldStyleSerifs),
           @"ClassTransitionalSerifs":  @(UIFontDescriptorClassTransitionalSerifs),
           @"ClassModernSerifs":        @(UIFontDescriptorClassModernSerifs),
           @"ClassClarendonSerifs":     @(UIFontDescriptorClassClarendonSerifs),
           @"ClassSlabSerifs":          @(UIFontDescriptorClassSlabSerifs),
           @"ClassFreeformSerifs":      @(UIFontDescriptorClassFreeformSerifs),
           @"ClassSansSerif":           @(UIFontDescriptorClassSansSerif),
           @"ClassOrnamentals":         @(UIFontDescriptorClassOrnamentals),
           @"ClassScripts":             @(UIFontDescriptorClassScripts),
           @"ClassSymbolic":            @(UIFontDescriptorClassSymbolic) };
    });

    return result;
}

+ (NSNumber*)                         uifontDescriptorTraitForObject:(id)nameOrTrait
{
    NSNumber* result = nil;
    if ([nameOrTrait isKindOfClass:[NSString class]])
    {
        result = [self uifontDescriptorTraitsByName][nameOrTrait];
    }
    else if ([nameOrTrait isKindOfClass:[NSNumber class]])
    {
        result = nameOrTrait;
    }
    return result;
}

+ (NSDictionary<NSString*, NSNumber*>*)          uifontWeightsByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
        @{ @"UltraLight":           @(UIFontWeightUltraLight),
           @"Thin":                 @(UIFontWeightThin),
           @"Light":                @(UIFontWeightLight),
           @"Regular":              @(UIFontWeightRegular),
           @"Medium":               @(UIFontWeightMedium),
           @"Semibold":             @(UIFontWeightSemibold),
           @"Bold":                 @(UIFontWeightBold),
           @"Heavy":                @(UIFontWeightHeavy),
           @"Black":                @(UIFontWeightBlack) };
    });

    return result;
}

+ (NSNumber*)                                  uifontWeightForObject:(id)nameOrFontWeight
{
    NSNumber* result = nil;
    if ([nameOrFontWeight isKindOfClass:[NSString class]])
    {
        result = [self uifontWeightsByName][nameOrFontWeight];
    }
    else if ([nameOrFontWeight isKindOfClass:[NSNumber class]])
    {
        result = nameOrFontWeight;
    }
    return result;
}

+ (NSDictionary<NSString*, NSString*>*)       uifontAttributesByName
{
    static NSDictionary<NSString*, NSString*>* result = nil;
    static dispatch_once_t onceToken;

    // These are camel- and not pascal case, because they are used as binding expression
    // attribute names, not as enumeration constants:
    dispatch_once(&onceToken, ^{
        result =
        @{ @"family":           UIFontDescriptorFamilyAttribute,
           @"name":             UIFontDescriptorNameAttribute,
           @"face":             UIFontDescriptorFaceAttribute,
           @"size":             UIFontDescriptorSizeAttribute,
           @"visibleName":      UIFontDescriptorVisibleNameAttribute,
           @"matrix":           UIFontDescriptorMatrixAttribute,
           @"characterSet":     UIFontDescriptorCharacterSetAttribute,
           @"cascadeList":      UIFontDescriptorCascadeListAttribute,
           @"traits":           UIFontDescriptorTraitsAttribute,
           @"fixedAdvance":     UIFontDescriptorFixedAdvanceAttribute,
           @"featureSettings":  UIFontDescriptorFeatureSettingsAttribute,
           @"textStyle":        UIFontDescriptorTextStyleAttribute };
    });

    return result;
}

#pragma mark - String Compare Options

+ (NSDictionary<NSString*, NSNumber*>*)       stringCompareOptions
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
        @{ @"CaseInsensitiveSearch":        @(NSCaseInsensitiveSearch),
           @"LiteralSearch":                @(NSLiteralSearch),
           @"BackwardsSearch":              @(NSBackwardsSearch),
           @"AnchoredSearch":               @(NSAnchoredSearch),
           @"NumericSearch":                @(NSNumericSearch),
           @"DiacriticInsensitiveSearch":   @(NSDiacriticInsensitiveSearch),
           @"WidthInsensitiveSearch":       @(NSWidthInsensitiveSearch),
           @"ForcedOrderingSearch":         @(NSForcedOrderingSearch),
           @"RegularExpressionSearch":      @(NSRegularExpressionSearch) };
    });

    return result;
}

#pragma mark - Animations

+ (NSDictionary<NSString*, NSNumber*>*)       uitableViewRowAnimationsByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result =
        @{  @"None":            @(UITableViewRowAnimationNone),
            @"Automatic":       @(UITableViewRowAnimationAutomatic),
            @"Top":             @(UITableViewRowAnimationTop),
            @"Left":            @(UITableViewRowAnimationLeft),
            @"Bottom":          @(UITableViewRowAnimationBottom),
            @"Right":           @(UITableViewRowAnimationRight),
            @"Fade":            @(UITableViewRowAnimationFade),
            @"Middle":          @(UITableViewRowAnimationMiddle),
            };
    });
    return result;
}

+ (NSDictionary<NSString *,NSNumber *> *)uiviewAnimationOptions
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result =
        @{  @"Repeat":                      @(UIViewAnimationOptionRepeat),
            @"Autoreverse":                 @(UIViewAnimationOptionAutoreverse),
            @"CurveEaseIn":                 @(UIViewAnimationOptionCurveEaseIn),
            @"CurveLinear":                 @(UIViewAnimationOptionCurveLinear),
            @"CurveEaseOut":                @(UIViewAnimationOptionCurveEaseOut),
            @"CurveEaseInOut":              @(UIViewAnimationOptionCurveEaseInOut),
            @"LayoutSubviews":              @(UIViewAnimationOptionLayoutSubviews),
            @"TransitionNone":              @(UIViewAnimationOptionTransitionNone),
            @"TransitionCurlUp":            @(UIViewAnimationOptionTransitionCurlUp),
            @"TransitionCurlDown":          @(UIViewAnimationOptionTransitionCurlDown),
            @"TransitionFlipFromTop":       @(UIViewAnimationOptionTransitionFlipFromTop),
            @"TransitionFlipFromLeft":      @(UIViewAnimationOptionTransitionFlipFromLeft),
            @"TransitionFlipFromRight":     @(UIViewAnimationOptionTransitionFlipFromRight),
            @"TransitionFlipFromBottom":    @(UIViewAnimationOptionTransitionFlipFromBottom),
            @"TransitionCrossDissolve":     @(UIViewAnimationOptionTransitionCrossDissolve),
            @"ShowHideTransitionViews":     @(UIViewAnimationOptionShowHideTransitionViews),
            @"AllowAnimatedContent":        @(UIViewAnimationOptionAllowAnimatedContent),
            @"AllowUserInteraction":        @(UIViewAnimationOptionAllowUserInteraction),
            @"BeginFromCurrentState":       @(UIViewAnimationOptionBeginFromCurrentState),
            @"OverrideInheritedCurve":      @(UIViewAnimationOptionOverrideInheritedCurve),
            @"OverrideInheritedOptions":    @(UIViewAnimationOptionOverrideInheritedOptions),
            @"OverrideInheritedDuration":   @(UIViewAnimationOptionOverrideInheritedDuration),
            };
    });
    return result;
}

@end
