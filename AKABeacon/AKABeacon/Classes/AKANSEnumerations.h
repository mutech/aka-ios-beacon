//
//  AKANSEnumerations.h
//  AKABeacon
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;

@interface AKANSEnumerations : NSObject

+ (opt_NSNumber)                                   enumeratedValueForName:(opt_NSString)name
                                                             inDictionary:(req_NSDictionary)dictionary;

+ (opt_NSString)                                   nameForEnumeratedValue:(opt_NSNumber)value
                                                             inDictionary:(req_NSDictionary)dictionary;

#pragma mark - NSNumberFormatter Enumerations

+ (opt_NSNumber)                            numberFormatterStyleForObject:(opt_id)nameOrEnumeratedValue;
+ (opt_NSNumber)                              numberFormatterPadForObject:(opt_id)nameOrEnumeratedValue;
+ (opt_NSNumber)                     numberFormatterRoundingModeForObject:(opt_id)nameOrEnumeratedValue;


+ (NSDictionary<NSString*, NSNumber*>*_Nonnull)        numberStylesByName;
+ (NSDictionary<NSString*, NSNumber*>*_Nonnull)        padPositionsByName;
+ (NSDictionary<NSString*, NSNumber*>*_Nonnull)       roundingModesByName;

#pragma mark - NSFormatter Enumerations

+ (opt_NSNumber)                               formattingContextForObject:(opt_id)nameOrEnumeratedValue;
+ (opt_NSNumber)                             formattingUnitStyleForObject:(opt_id)nameOrEnumeratedValue;

+ (NSDictionary<NSString*, NSNumber*>*_Nonnull)formattingUnitStylesByName;
+ (NSDictionary<NSString*, NSNumber*>*_Nonnull)  formattingContextsByName;

#pragma mark - NSDateFormatter Enumerations


+ (opt_NSNumber)                              dateFormatterStyleForObject:(opt_id)nameOrEnumeratedValue;

+ (NSDictionary<NSString*, NSNumber*>*_Nonnull) dateFormatterStylesByName;

+ (opt_NSTimeZone)                                      timeZoneForObject:(opt_id)timeZoneOrNameOrAbbrev;

#pragma mark - UIFont Descriptor Enumerations

+ (NSDictionary<NSString*, NSString*>*_Nonnull)    uifontTextStylesByName;
+ (opt_NSString)                                         textStyleForName:(opt_NSString)name;

+ (NSDictionary<NSString*, NSNumber*>*_Nonnull)uifontDescriptorTraitsByName;
+ (opt_NSNumber)                           uifontDescriptorTraitForObject:(opt_id)nameOrTrait;

+ (NSDictionary<NSString*, NSNumber*>*_Nonnull)       uifontWeightsByName;
+ (opt_NSNumber)                                    uifontWeightForObject:(opt_id)nameOrFontWeight;

#pragma mark - String Compare Options

+ (NSDictionary<NSString*, NSNumber*>*_Nonnull)      stringCompareOptions;

#pragma mark - Animations

+ (NSDictionary<NSString*, NSNumber*>*_Nonnull)uitableViewRowAnimationsByName;

+ (NSDictionary<NSString*, NSNumber*>*_Nonnull)uiviewAnimationOptions;

@end
