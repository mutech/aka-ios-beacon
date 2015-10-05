//
//  AKABinding_AKABinding_numberFormatter.m
//  AKAControls
//
//  Created by Michael Utech on 04.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

#import "AKABinding_AKABinding_numberFormatter.h"


@implementation AKABindingProvider_AKABinding_numberFormatter

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_AKABinding_numberFormatter* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_AKABinding_numberFormatter new];
    });
    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":                  [AKABinding_AKABinding_numberFormatter class],
           @"bindingProviderType":          [AKABindingProvider_AKABinding_numberFormatter class],
           @"targetType":                   [AKAProperty class],
           @"expressionType":               @(AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeNone),
           @"allowUnspecifiedAttributes":   @YES
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });
    return result;
}

@end


@interface AKABinding_AKABinding_numberFormatter()

@property(nonatomic, nonnull) NSNumberFormatter* numberFormatter;

@property(nonatomic, readonly) NSDictionary<NSString*, void(^)(AKABinding_AKABinding_numberFormatter*, id)>* customSettersByPropertyName;

@end


@implementation AKABinding_AKABinding_numberFormatter

- (instancetype)initWithTarget:(id)target
                    expression:(req_AKABindingExpression)bindingExpression
                       context:(req_AKABindingContext)bindingContext
                      delegate:(opt_AKABindingDelegate)delegate
{
    NSParameterAssert([target isKindOfClass:[AKAProperty class]]);
    return [self initWithProperty:target
                       expression:bindingExpression
                          context:bindingContext
                         delegate:delegate];
}

- (instancetype)initWithProperty:(req_AKAProperty)bindingTarget
                      expression:(req_AKABindingExpression)bindingExpression
                         context:(req_AKABindingContext)bindingContext
                        delegate:(opt_AKABindingDelegate)delegate
{
    self = [super initWithTarget:bindingTarget
                      expression:bindingExpression
                         context:bindingContext
                        delegate:delegate];
    if (self)
    {
        _numberFormatter = self.bindingSource.value;
        if (_numberFormatter != nil && bindingExpression.attributes.count > 0)
        {
            _numberFormatter = [_numberFormatter copy];
        }
        if (_numberFormatter == nil && bindingExpression.attributes.count > 0)
        {
            _numberFormatter = [[NSNumberFormatter alloc] init];
        }
        [bindingExpression.attributes enumerateKeysAndObjectsUsingBlock:
         ^(NSString * _Nonnull key, AKABindingExpression * _Nonnull obj, BOOL * _Nonnull stop)
         {
             // TODO: make this more robust and add error handling/reporting
             id value = [obj bindingSourceValueInContext:bindingContext];

             void(^customSetter)(AKABinding_AKABinding_numberFormatter*, id);
             customSetter = self.customSettersByPropertyName[key];
             if (customSetter)
             {
                 customSetter(self, value);
             }
             else
             {
                 [_numberFormatter setValue:value forKey:key];
             }
         }];
        // TODO: should probably not do that here, review this:
        self.bindingTarget.value = self.numberFormatter;
    }
    return self;
}

#pragma mark - Properties

@dynamic bindingTarget;

#pragma mark - ...

- (NSDictionary<NSString*, void(^)(AKABinding_AKABinding_numberFormatter*, id)>*)customSettersByPropertyName
{
    static NSDictionary<NSString*, void(^)(AKABinding_AKABinding_numberFormatter*, id)>* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result =
        @{ @"numberStyle":          ^void(AKABinding_AKABinding_numberFormatter* binding,
                                          id value) { binding.numberStyle = value; },
           @"locale":               ^void(AKABinding_AKABinding_numberFormatter* binding,
                                          id value) { binding.locale = value; },
           @"roundingMode":         ^void(AKABinding_AKABinding_numberFormatter* binding,
                                          id value) { binding.roundingMode = value; },
           @"formattingContext":    ^void(AKABinding_AKABinding_numberFormatter* binding,
                                          id value) { binding.formattingContext = value; },
           @"paddingPosition":      ^void(AKABinding_AKABinding_numberFormatter* binding,
                                          id value) { binding.paddingPosition = value; },
           @"format":               ^void(AKABinding_AKABinding_numberFormatter* binding,
                                          id value) { binding.format = value; },
           };

    });
    return result;
}

- (BOOL)shouldUpdateSourceValueForTargetValue:(opt_id)oldTargetValue
                                     changeTo:(opt_id)newTargetValue
                                  validatedTo:(opt_id)targetValue
{
    // We never want to override a possibly shared number formatter with whatever we have
    return NO;
}

- (BOOL)shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                     changeTo:(opt_id)newSourceValue
                                  validatedTo:(opt_id)sourceValue
{
    // TODO: allow updating the target number formatter, later though
    return NO;
}

#pragma mark - Number Formatter Configuration

#pragma mark - Configuring Formatter Behavior and Style

- (NSNumber *)numberStyle
{
    return @(self.numberFormatter.numberStyle);
}

- (void)setNumberStyle:(id)numberStyle
{
    NSNumber* style = nil;
    if ([numberStyle isKindOfClass:[NSString class]])
    {
        style = [self numberStylesByName][numberStyle];
    }
    else if ([numberStyle isKindOfClass:[NSNumber class]])
    {
        style = numberStyle;
    }
    if (style != nil)
    {
        self.numberFormatter.numberStyle = style.integerValue;
    }
}

#pragma mark - Managing Localization of Numbers

- (NSLocale *)locale
{
    return self.numberFormatter.locale;
}

- (void)setLocale:(id)localeOrIdentifier
{
    NSLocale* locale = nil;
    if ([localeOrIdentifier isKindOfClass:[NSString class]])
    {
        locale = [NSLocale localeWithLocaleIdentifier:localeOrIdentifier];
    }
    else if ([localeOrIdentifier isKindOfClass:[NSLocale class]])
    {
        locale = localeOrIdentifier;
    }
    if (locale != nil)
    {
        self.numberFormatter.locale = locale;
    }
}

#pragma mark - Configuring Rounding Behavior

- (NSNumber *)roundingMode
{
    return @(self.numberFormatter.roundingMode);
}

- (void)setRoundingMode:(id)roundingModeOrName
{
    NSNumber* roundingMode = nil;
    if ([roundingModeOrName isKindOfClass:[NSString class]])
    {
        roundingMode = [self enumeratedValueForName:roundingModeOrName
                                       inDictionary:[self roundingModesByName]
                               propertyForReporting:@selector(roundingMode)];
    }
    else if ([roundingModeOrName isKindOfClass:[NSNumber class]])
    {
        roundingMode = roundingModeOrName;
    }
    if (roundingMode != nil)
    {
        self.numberFormatter.roundingMode = roundingMode.integerValue;
    }
}

#pragma mark - Configuring Numeric Formats

- (NSNumber *)formattingContext
{
    return @(self.numberFormatter.formattingContext);
}

- (void)setFormattingContext:(id)formattingContextOrName
{
    NSNumber* formattingContext = nil;
    if ([formattingContextOrName isKindOfClass:[NSString class]])
    {
        formattingContext = [self enumeratedValueForName:formattingContextOrName
                                            inDictionary:[self formattingContextsByName]
                                    propertyForReporting:@selector(formattingContext)];
    }
    else if ([formattingContextOrName isKindOfClass:[NSNumber class]])
    {
        formattingContext = formattingContextOrName;
    }
    if (formattingContext != nil)
    {
        self.numberFormatter.formattingContext = formattingContext.integerValue;
    }
}

- (NSString *)format
{
    NSString* result = nil;
    NSString* positive = self.numberFormatter.positiveFormat;
    NSString* negative = self.numberFormatter.negativeFormat;

    if (positive.length > 0)
    {
        if (negative.length == 0)
        {
            negative = [NSString stringWithFormat:@"-%@", positive];
        }
        result = [NSString stringWithFormat:@"%@;%@", positive, negative];
    }
    return result;
}

- (void)setFormat:(NSString *)format
{
    if (format.length > 0)
    {
        NSArray* subPatterns = [format componentsSeparatedByString:@";"];
        switch (subPatterns.count)
        {
            case 1:
                self.numberFormatter.positiveFormat = subPatterns[0];
                self.numberFormatter.negativeFormat = [NSString stringWithFormat:@"-%@", subPatterns[0]];
                break;
            case 2:
                self.numberFormatter.positiveFormat = subPatterns[0];
                self.numberFormatter.negativeFormat = subPatterns[1];
                break;
            default:
                // TODO: review specs, multiple formats ok for input parsing
                NSAssert(NO, @"Invalid number format %@", format);
                break;
        }
    }
}

#pragma mark - Managing Padding of Numbers

- (NSNumber *)paddingPosition
{
    return @(self.numberFormatter.paddingPosition);
}

- (void)setPaddingPosition:(id)paddingPositionOrName
{
    NSNumber* paddingPosition = nil;
    if ([paddingPositionOrName isKindOfClass:[NSString class]])
    {
        paddingPosition = [self enumeratedValueForName:paddingPositionOrName
                                          inDictionary:[self padPositionsByName]
                                  propertyForReporting:@selector(paddingPosition)];
    }
    else if ([paddingPosition isKindOfClass:[NSNumber class]])
    {
        paddingPosition = paddingPositionOrName;
    }
    self.numberFormatter.paddingPosition = paddingPosition.integerValue;
}

#pragma mark - Implementation

- (opt_NSNumber)enumeratedValueForName:(opt_NSString)name
                          inDictionary:(req_NSDictionary)dictionary
                  propertyForReporting:(req_SEL)property
{
    NSNumber* result = dictionary[name];
    NSAssert(result != nil, @"%@ is not a valid enumeration value code for property %@", name, NSStringFromSelector(property));
    return result;
}

- (opt_NSString)nameForEnumeratedValue:(opt_NSNumber)value
                          inDictionary:(NSDictionary*)dictionary
{
    __block NSString* result = nil;

    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([((NSNumber*)obj) isEqualToNumber:value])
        {
            result = key;
        }
    }];

    return result;
}

- (NSDictionary<NSString*, NSNumber*>*)numberStylesByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = @{ @"Currency":            @(NSNumberFormatterCurrencyStyle),
                    @"Decimal":             @(NSNumberFormatterDecimalStyle),
                    @"Percent":             @(NSNumberFormatterPercentStyle),
                    @"Scientific":          @(NSNumberFormatterScientificStyle),
                    @"SpellOut":            @(NSNumberFormatterSpellOutStyle),
                    };
    });
    return result;
}

- (NSDictionary<NSString*, NSNumber*>*)padPositionsByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = @{ @"BeforePrefix":       @(NSNumberFormatterPadBeforePrefix),
                    @"AfterPrefix":        @(NSNumberFormatterPadAfterPrefix),
                    @"BeforeSuffix":       @(NSNumberFormatterPadBeforeSuffix),
                    @"AfterSuffix":        @(NSNumberFormatterPadAfterSuffix),
                    };
    });
    return result;
}

- (NSDictionary<NSString*, NSNumber*>*)roundingModesByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = @{ @"Ceiling":             @(NSNumberFormatterRoundCeiling),
                    @"Floor":               @(NSNumberFormatterRoundFloor),
                    @"Down":                @(NSNumberFormatterRoundDown),
                    @"Up":                  @(NSNumberFormatterRoundUp),
                    @"HalfEven":            @(NSNumberFormatterRoundHalfEven),
                    @"HalfDown":            @(NSNumberFormatterRoundHalfDown),
                    @"HalfUp":              @(NSNumberFormatterRoundHalfUp),
                    };
    });

    return result;
}

- (NSDictionary<NSString*, NSNumber*>*)formattingContextsByName
{
    static NSDictionary<NSString*, NSNumber*>* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = @{ @"Unknown":            @(NSFormattingContextUnknown),
                    @"Dynamic":            @(NSFormattingContextDynamic),
                    @"Standalone":         @(NSFormattingContextStandalone),
                    @"ListItem":           @(NSFormattingContextListItem),
                    @"BeginningOfSentence":@(NSFormattingContextBeginningOfSentence),
                    @"MiddleOfSentence":   @(NSFormattingContextMiddleOfSentence),
                    };
    });
    return result;
}

@end
