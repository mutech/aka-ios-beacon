//
//  AKANSEnumerations.h
//  AKAControls
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;

@interface AKANSEnumerations : NSObject

+ (opt_NSNumber)                              enumeratedValueForName:(opt_NSString)name
                                                        inDictionary:(req_NSDictionary)dictionary;

+ (opt_NSString)                              nameForEnumeratedValue:(opt_NSNumber)value
                                                        inDictionary:(NSDictionary*)dictionary;


#pragma mark - Locales

+ (NSLocale*)localeForObject:(id)localeOrName;

#pragma mark - NSNumberFormatter Enumerations

+ (NSNumber*)numberFormatterStyleForObject:(id)nameOrEnumeratedValue;
+ (NSNumber*)numberFormatterPadForObject:(id)nameOrEnumeratedValue;
+ (NSNumber*)numberFormatterRoundingModeForObject:(id)nameOrEnumeratedValue;


+ (NSDictionary<NSString*, NSNumber*>*)           numberStylesByName;
+ (NSDictionary<NSString*, NSNumber*>*)           padPositionsByName;
+ (NSDictionary<NSString*, NSNumber*>*)          roundingModesByName;

#pragma mark - NSFormatter Enumerations

+ (NSNumber*)formattingContextForObject:(id)nameOrEnumeratedValue;

+ (NSDictionary<NSString*, NSNumber*>*)     formattingContextsByName;

#pragma mark - NSDateFormatter Enumerations


+ (NSNumber*)dateFormatterStyleForObject:(id)nameOrEnumeratedValue;

+ (NSDictionary<NSString*, NSNumber*>*)    dateFormatterStylesByName;

+ (NSCalendar*)calendarForObject:(id)calendarOrIdentifier;
+ (NSTimeZone*)timeZoneForObject:(id)timeZoneOrNameOrAbbrev;

@end
