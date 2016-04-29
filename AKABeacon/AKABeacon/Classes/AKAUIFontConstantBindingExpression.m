//
//  AKAUIFontConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAUIFontConstantBindingExpression.h"
#import "AKANumberConstantBindingExpression.h"
#import "AKAStringConstantBindingExpression.h"
#import "AKAEnumConstantBindingExpression.h"
#import "AKAOptionsConstantBindingExpression.h"

#import "AKANSEnumerations.h"
#import "AKABindingErrors.h"
#import "AKABindingExpressionParser.h"


#pragma mark - AKAUIFontConstantBindingExpression
#pragma mark -

@implementation AKAUIFontConstantBindingExpression

#pragma mark - Initialization

+ (UIFont*)fontForDescriptor:(UIFontDescriptor*)descriptor
{
    UIFont* result = nil;
    NSString* fontName = nil;
    CGFloat fontSize = descriptor.pointSize;
    NSString* textStyle = nil;

    fontName = descriptor.fontAttributes[UIFontDescriptorNameAttribute];
    fontSize = ((NSNumber*)descriptor.fontAttributes[UIFontDescriptorSizeAttribute]).floatValue;

    if (textStyle != nil)
    {
        result = [UIFont preferredFontForTextStyle:textStyle];
    }
    else if (fontName && fontSize > 0)
    {
        result = [UIFont fontWithName:fontName size:fontSize];
    }
    else
    {
        NSArray<UIFontDescriptor*>* matchingDescriptors =
        [descriptor matchingFontDescriptorsWithMandatoryKeys:[NSSet setWithArray:descriptor.fontAttributes.allKeys]];
        if (matchingDescriptors.count > 1)
        {
            UIFontDescriptor* firstDescriptor = matchingDescriptors[1];
            if (fontSize <= 0.0)
            {
                fontSize = 15.0;
            }
            result = [UIFont fontWithDescriptor:firstDescriptor size:fontSize];
        }
#if 0
        NSAssert(NO, @"Insufficient font specification in descriptor %@", descriptor);
#endif
    }

    return result;
}

+ (NSString*)stringForAttribute:(NSString*)attributeName
              bindingExpression:(AKABindingExpression*)bindingExpression
                          error:(out_NSError)error
{
    NSString* result = nil;

    if ([bindingExpression isKindOfClass:[AKAStringConstantBindingExpression class]])
    {
        result = ((AKAStringConstantBindingExpression*)bindingExpression).constant;
    }
    else if (error)
    {
        *error = [AKABindingErrors invalidBindingExpression:bindingExpression
                                          forAttributeNamed:attributeName
                                        invalidTypeExpected:@[ [AKAStringConstantBindingExpression class] ]];
    }

    return result;
}

+ (NSNumber*)numberForAttribute:(NSString*)attributeName
              bindingExpression:(AKABindingExpression*)bindingExpression
                          error:(out_NSError)error
{
    NSNumber* result = nil;

    if ([bindingExpression isKindOfClass:[AKANumberConstantBindingExpression class]])
    {
        result = ((AKANumberConstantBindingExpression*)bindingExpression).constant;
    }
    else if (error)
    {
        *error = [AKABindingErrors invalidBindingExpression:bindingExpression
                                          forAttributeNamed:attributeName
                                        invalidTypeExpected:@[ [AKANumberConstantBindingExpression class] ]];
    }

    return result;
}

+ (NSNumber*)doubleNumberInRangeMin:(double)min
                                max:(double)max
                       forAttribute:(NSString*)attributeName
                  bindingExpression:(AKABindingExpression*)bindingExpression
                              error:(out_NSError)error
{
    NSNumber* result = nil;

    if ([bindingExpression isKindOfClass:[AKANumberConstantBindingExpression class]])
    {
        result = ((AKANumberConstantBindingExpression*)bindingExpression).constant;

        if (result)
        {
            double value = result.doubleValue;

            if (value < min || value > max)
            {
                // TODO: out of range error
            }
        }
    }
    else if (error)
    {
        *error = [AKABindingErrors invalidBindingExpression:bindingExpression
                                          forAttributeNamed:attributeName
                                        invalidTypeExpected:@[ [AKANumberConstantBindingExpression class] ]];
    }

    return result;
}

+ (id)enumeratedValueOfType:(req_NSString)enumerationType
               forAttribute:(NSString*)attributeName
          bindingExpression:(AKABindingExpression*)bindingExpression
                      error:(out_NSError)error
{
    NSNumber* result = nil;

    NSError* localError = nil;

    if ([bindingExpression isKindOfClass:[AKAEnumConstantBindingExpression class]])
    {
        AKAEnumConstantBindingExpression* enumExpression = (id)bindingExpression;

        if (enumExpression.enumerationType.length == 0 ||
            [enumerationType isEqualToString:(req_NSString)enumExpression.enumerationType])
        {
            result = enumExpression.constant;

            if (result == nil && enumExpression.symbolicValue.length > 0)
            {
                result = [AKABindingExpressionSpecification resolveEnumeratedValue:enumExpression.symbolicValue
                                                                          forType:enumerationType
                                                                            error:&localError];
            }
        }
    }
    else if ([bindingExpression isKindOfClass:[AKAConstantBindingExpression class]])
    {
        result = ((AKAConstantBindingExpression*)bindingExpression).constant;
    }
    else
    {
        localError =
        [AKABindingErrors invalidBindingExpression:bindingExpression
                                 forAttributeNamed:attributeName
                               invalidTypeExpected:@[ [AKAEnumConstantBindingExpression class],
                                                      [AKAConstantBindingExpression class] ]];
    }

    if (!result && localError != nil)
    {
        if (error)
        {
            *error = localError;
        }
        else
        {
            @throw [NSException exceptionWithName:localError.localizedDescription
                                           reason:localError.localizedFailureReason
                                         userInfo:nil];
        }
    }

    return result;
}

+ (NSNumber*)optionsValueOfType:(req_NSString)optionsType
                   forAttribute:(NSString*)attributeName
              bindingExpression:(AKABindingExpression*)bindingExpression
                          error:(out_NSError)error
{
    NSNumber* result = nil;

    NSError* localError = nil;

    if ([bindingExpression isKindOfClass:[AKAOptionsConstantBindingExpression class]])
    {
        AKAOptionsConstantBindingExpression* enumExpression = (id)bindingExpression;

        if (enumExpression.optionsType.length == 0 ||
            [optionsType isEqualToString:(req_NSString)enumExpression.optionsType])
        {
            result = enumExpression.constant;

            if (result == nil && enumExpression.attributes.count > 0)
            {
                result = [AKABindingExpressionSpecification resolveOptionsValue:enumExpression.attributes
                                                                          forType:optionsType
                                                                            error:&localError];
            }
        }
    }
    else if ([bindingExpression isKindOfClass:[AKANumberConstantBindingExpression class]])
    {
        result = ((AKANumberConstantBindingExpression*)bindingExpression).constant;
    }
    else if (bindingExpression.class == [AKABindingExpression class])
    {
        result = [AKABindingExpressionSpecification resolveOptionsValue:bindingExpression.attributes
                                                                  forType:optionsType
                                                                    error:&localError];
    }
    else
    {
        localError =
        [AKABindingErrors invalidBindingExpression:bindingExpression
                                 forAttributeNamed:attributeName
                               invalidTypeExpected:@[ [AKAOptionsConstantBindingExpression class],
                                                      [AKANumberConstantBindingExpression class],
                                                      [AKABindingExpression class] ]];
    }

    if (!result && localError != nil)
    {
        if (error)
        {
            *error = localError;
        }
        else
        {
            @throw [NSException exceptionWithName:localError.localizedDescription
                                           reason:localError.localizedFailureReason
                                         userInfo:nil];
        }
    }

    return result;
}

+ (NSNumber*)uifontSymbolicTraitForAttribute:(NSString*)attributeName
                           bindingExpression:(AKABindingExpression*)bindingExpression
                                       error:(out_NSError)error
{
    NSString* optionsType = @"UIFontDescriptorSymbolicTraits";
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        [AKABindingExpressionSpecification registerOptionsType:optionsType
                                              withValuesByName:[AKANSEnumerations uifontDescriptorTraitsByName]];
    });

    return [self optionsValueOfType:optionsType
                       forAttribute:attributeName
                  bindingExpression:bindingExpression
                              error:error];
}

+ (NSNumber*)uifontWeightTraitForAttribute:(NSString*)attributeName
                         bindingExpression:(AKABindingExpression*)bindingExpression
                                     error:(out_NSError)error
{
    NSString* enumerationType = @"AKAUIFontDescriptorWeightTraits";
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        [AKABindingExpressionSpecification registerEnumerationType:enumerationType
                                                  withValuesByName:[AKANSEnumerations uifontWeightsByName]];
    });

    return [self enumeratedValueOfType:enumerationType
                          forAttribute:attributeName
                     bindingExpression:bindingExpression
                                 error:error];
}

+ (NSNumber*)uifontWidthTraitForAttribute:(NSString*)attributeName
                        bindingExpression:(AKABindingExpression*)bindingExpression
                                    error:(out_NSError)error
{
    return [self doubleNumberInRangeMin:-1.0
                                    max:1.0
                           forAttribute:attributeName
                      bindingExpression:bindingExpression
                                  error:error];
}

+ (NSNumber*)uifontSlantTraitForAttribute:(NSString*)attributeName
                        bindingExpression:(AKABindingExpression*)bindingExpression
                                    error:(out_NSError)error
{
    return [self doubleNumberInRangeMin:-1.0
                                    max:1.0
                           forAttribute:attributeName
                      bindingExpression:bindingExpression
                                  error:error];
}

+ (NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>*)fontAttributesParsersByAttributeName
{
    static NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
        @{ @"family":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error)
           {
               NSString* string = [AKAUIFontConstantBindingExpression stringForAttribute:@"family"
                                                                       bindingExpression:bindingExpression
                                                                                   error:error];
               fa[UIFontDescriptorFamilyAttribute] = string;
               return string != nil;
           },

           @"name":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error)
           {
               NSString* string = [AKAUIFontConstantBindingExpression stringForAttribute:@"name"
                                                                       bindingExpression:bindingExpression
                                                                                   error:error];
               fa[UIFontDescriptorNameAttribute] = string;
               return string != nil;
           },

           @"face":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error)
           {
               NSString* string = [AKAUIFontConstantBindingExpression stringForAttribute:@"face"
                                                                       bindingExpression:bindingExpression
                                                                                   error:error];
               fa[UIFontDescriptorFaceAttribute] = string;
               return string != nil;
           },

           @"size":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error)
           {
               NSNumber* number = [AKAUIFontConstantBindingExpression numberForAttribute:@"size"
                                                                       bindingExpression:bindingExpression
                                                                                   error:error];
               fa[UIFontDescriptorSizeAttribute] = number;
               return number != nil;
           },

           @"visibleName":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error)
           {
               NSString* string = [AKAUIFontConstantBindingExpression stringForAttribute:@"visibleName"
                                                                       bindingExpression:bindingExpression
                                                                                   error:error];
               fa[UIFontDescriptorVisibleNameAttribute] = string;
               return string != nil;
           },

           @"traits":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
                   NSError* localError = nil;
                   NSDictionary* dictionary = [AKAUIFontConstantBindingExpression uifontTraitsForBindingExpression:bindingExpression
                                                                                                             error:&localError];
                   fa[UIFontDescriptorTraitsAttribute] = dictionary;

                   if (!dictionary && localError != nil && error != nil)
                   {
                       *error = [AKABindingErrors invalidBindingExpression:bindingExpression
                                                         forAttributeNamed:@"traits"
                                                         uifontTraitsError:localError];
                   }

                   return dictionary != nil;
               },

           @"fixedAdvance":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
                   NSNumber* number = [AKAUIFontConstantBindingExpression numberForAttribute:@"fixedAdvance"
                                                                           bindingExpression:bindingExpression
                                                                                       error:error];
                   fa[UIFontDescriptorFixedAdvanceAttribute] = number;
                   return number != nil;
               },

           @"textStyle":
               ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
                   NSString* textStyle =
                   [AKAUIFontConstantBindingExpression stringForAttribute:@"textStyle"
                                                        bindingExpression:bindingExpression
                                                                    error:error];
                   fa[UIFontDescriptorTextStyleAttribute] =
                   [AKANSEnumerations textStyleForName:textStyle];

                   return textStyle != nil;
               },

           /*
            // TODO: decide whether we have to implement these:
            @"matrix":
            ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
            AKAErrorMethodNotImplemented();
            },
            @"characterSet":
            ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
            AKAErrorMethodNotImplemented();
            },
            @"cascadeList":
            ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
            AKAErrorMethodNotImplemented();
            },
            @"featureSettings":
            ^BOOL (NSMutableDictionary* fa, AKABindingExpression* bindingExpression, out_NSError error) {
            AKAErrorMethodNotImplemented();
            },
            */
           };
    });

    return result;
}

+ (NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>*)fontTraitsParsersByAttributeName
{
    static NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result =
        @{ @"symbolic": ^BOOL (NSMutableDictionary* traits, AKABindingExpression* bindingExpression, out_NSError error)
           {
               NSNumber* number = [AKAUIFontConstantBindingExpression uifontSymbolicTraitForAttribute:@"symbolic"
                                                                                    bindingExpression:bindingExpression
                                                                                                error:error];
               traits[UIFontSymbolicTrait] = number;
               return number != nil;
           },

           @"weight": ^BOOL (NSMutableDictionary* traits, AKABindingExpression* bindingExpression, out_NSError error)
           {
               NSNumber* number = [AKAUIFontConstantBindingExpression uifontWeightTraitForAttribute:@"weight"
                                                                                  bindingExpression:bindingExpression
                                                                                              error:error];
               traits[UIFontWeightTrait] = number;
               return number != nil;
           },

           @"width": ^BOOL (NSMutableDictionary* traits, AKABindingExpression* bindingExpression, out_NSError error)
           {
               NSNumber* number = [AKAUIFontConstantBindingExpression uifontWidthTraitForAttribute:@"width"
                                                                                 bindingExpression:bindingExpression
                                                                                             error:error];
               traits[UIFontWidthTrait] = number;
               return number != nil;
           },

           @"slant": ^BOOL (NSMutableDictionary* traits, AKABindingExpression* bindingExpression, out_NSError error)
           {
               NSNumber* number = [AKAUIFontConstantBindingExpression uifontSlantTraitForAttribute:@"slant"
                                                                                 bindingExpression:bindingExpression
                                                                                             error:error];
               traits[UIFontSlantTrait] = number;
               return number != nil;
           }
           };
    });

    return result;
}

+ (NSDictionary*)uifontTraitsForBindingExpression:(AKABindingExpression*)bindingExpression
                                            error:(out_NSError)error
{
    __block NSMutableDictionary* result = [NSMutableDictionary new];

    if (bindingExpression.class != [AKABindingExpression class])
    {
        // TODO: add error parameter instead of throwing exception
        NSString* message = @"Invalid specification of traits for UIFont, traits cannot be specified using a binding expression's primary expression.";
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
    }
    else if (bindingExpression.attributes.count > 0)
    {
        NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>* spec =
        [AKAUIFontConstantBindingExpression fontTraitsParsersByAttributeName];

        [bindingExpression.attributes
         enumerateKeysAndObjectsUsingBlock:
         ^(req_NSString traitAttributeName,
           req_AKABindingExpression traitBindingExpression,
           outreq_BOOL stop)
         {
             BOOL (^processAttribute)(NSMutableDictionary*, AKABindingExpression*, out_NSError error) =
             spec[traitAttributeName];

             if (processAttribute)
             {
                 if (!processAttribute(result, traitBindingExpression, error))
                 {
                     *stop = YES;
                     result = nil;
                 }
             }
             else
             {
                 *stop = YES;
                 result = nil;

                 if (error)
                 {
                     *error = [AKABindingErrors invalidBindingExpression:traitBindingExpression
                                                        unknownAttribute:traitAttributeName
                                                         knownAttributes:spec.allKeys];
                 }
             }
         }];
    }

    return result;
}

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                   specification:(opt_AKABindingSpecification)specification
{
    UIFont* font = nil;

    if ([constant isKindOfClass:[UIFont class]])
    {
        font = constant;
    }
    else if ([constant isKindOfClass:[UIFontDescriptor class]])
    {
        font = [AKAUIFontConstantBindingExpression fontForDescriptor:constant];
    }

    if ((font && attributes.count > 0) || (!font && attributes.count == 0))
    {
        // TODO: add error parameter instead of throwing exception
        NSString* message = @"Invalid specification of attributes for UIFont. Attributes are required when no font or font descriptor is defined as primary expression and forbidden otherwise";
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        self = nil;
    }
    else if (!font)
    {
        NSDictionary<NSString*, BOOL (^)(NSMutableDictionary*, AKABindingExpression*, out_NSError)>* spec =
        [AKAUIFontConstantBindingExpression fontAttributesParsersByAttributeName];

        NSMutableDictionary* fontAttributes = [NSMutableDictionary new];

        [attributes enumerateKeysAndObjectsUsingBlock:
         ^(req_NSString attributeName,
           req_AKABindingExpression bindingExpression,
           outreq_BOOL stop)
         {
             BOOL (^processAttribute)(NSMutableDictionary*, AKABindingExpression*, out_NSError error) =
             spec[attributeName];

             if (processAttribute)
             {
                 NSError* error;

                 if (!processAttribute(fontAttributes, bindingExpression, &error))
                 {
                     *stop = YES;
                     // TODO: add error parameter instead of throwing exception
                     @throw [NSException exceptionWithName:error.localizedDescription
                                                    reason:error.localizedFailureReason
                                                  userInfo:nil];
                 }
             }
             else
             {
                 // TODO: add error parameter instead of throwing exception
                 @throw [NSException exceptionWithName:@"Invalid (unknown) font descriptor specification attribute"
                                                reason:nil
                                              userInfo:nil];
             }
         }];

        UIFontDescriptor* descriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:fontAttributes];
        font = [AKAUIFontConstantBindingExpression fontForDescriptor:descriptor];
    }

    self = [super initWithConstant:font attributes:nil specification:specification];

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeUIFontConstant;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [AKABindingExpressionParser keywordUIFont];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        UIFont* font = ((UIFont*)self.constant);
        result = [NSString stringWithFormat:@"$%@ { name: \"%@\", size: %lg", [self keyword], font.fontName, font.pointSize];
    }

    return result;
}

@end

