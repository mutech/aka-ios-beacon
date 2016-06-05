//
//  AKABindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 18.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingExpression_Internal.h"
#import "AKABindingExpressionParser.h"
#import "AKABindingErrors.h"
#import "NSMutableString+AKATools.h"

#import "NSObject+AKAConcurrencyTools.h"
#import "NSMutableString+AKATools.h"

#pragma mark - AKABindingExpression
#pragma mark -

@implementation AKABindingExpression

#pragma mark - Initialization

+ (instancetype)                     bindingExpressionWithString:(req_NSString)expressionText
                                                     bindingType:(req_Class)bindingType
                                                           error:(out_NSError)error
{
    AKABindingExpressionParser* parser = [AKABindingExpressionParser parserWithString:expressionText];
    AKABindingExpression* result = nil;

    if ([parser parseBindingExpression:&result
                     withSpecification:[bindingType specification]
                                 error:error])
    {
        if (!parser.scanner.isAtEnd)
        {
            result = nil;
            [parser registerParseError:error
                              withCode:AKAParseErrorInvalidPrimaryExpressionExpectedAttributesOrEnd
                            atPosition:parser.scanner.scanLocation
                                reason:@"Invalid character, expected attributes (starting with '{') or end of binding expression"];
        }

        if (result)
        {
            NSError* localError = nil;

            if (![result validateWithSpecification:[bindingType specification].bindingSourceSpecification
                    overrideAllowUnknownAttributes:NO
                                             error:&localError])
            {
                if (error)
                {
                    *error = localError;
                }
                else
                {
                    @throw [NSException exceptionWithName:@"BindingExpressionValidationFailed"
                                                   reason:localError.localizedDescription
                                                 userInfo:@{ @"error": localError }];
                }
                result = nil;
            }
        }
    }

    return result;
}

- (instancetype)                              initWithAttributes:(opt_AKABindingExpressionAttributes)attributes
                                                   specification:(opt_AKABindingSpecification)specification
{
    if (self = [super init])
    {
        _attributes = attributes;
        _specification = specification;
    }

    return self;
}

- (instancetype _Nullable)             initWithPrimaryExpression:(opt_id)primaryExpression
                                                      attributes:(opt_AKABindingExpressionAttributes)attributes
                                                   specification:(opt_AKABindingSpecification)specification
{
    if (primaryExpression == nil)
    {
        self = [self initWithAttributes:attributes specification:specification];
    }
    else
    {
        @throw [NSException exceptionWithName:@"Attempt to use AKABindingExpression with a primary binding expression. This is invalid. Use a binding type that can handle the specific type of primary expression." reason:nil userInfo:@{ }];
    }

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeNone;
}

#pragma mark - Validation

- (BOOL)                                               validate:(out_NSError)error
{
    return [self validateWithSpecification:self.specification.bindingSourceSpecification
            overrideAllowUnknownAttributes:NO
                                     error:error];
}

- (BOOL)                              validateWithSpecification:(AKABindingExpressionSpecification*)specification
                                 overrideAllowUnknownAttributes:(BOOL)allowUnknownAttributes
                                                          error:(out_NSError)error
{
    BOOL result;

    if (specification)
    {
        result = [self validatePrimaryExpressionWithSpecification:specification
                                                            error:error];
    }
    else
    {
        // No validation (assuming success) is ok if no specification is provided:
        // Good for lazy binding authors, not so good for users. We relax validation here for users
        // writing binding extensions.
        result = YES;
    }

    if (result)
    {
        result = [self validateAttributesWithSpecification:specification overrideAllowUnknownAttributes:allowUnknownAttributes
                                                     error:error];
    }

    return result;
}

- (BOOL)             validatePrimaryExpressionWithSpecification:(opt_AKABindingExpressionSpecification)specification
                                                          error:(out_NSError)error
{
    BOOL result = YES;

    if (specification)
    {
        AKABindingExpressionType expressionType = specification.expressionType;
        if (expressionType == AKABindingExpressionTypeForwardToPrimaryAttribute)
        {
            expressionType = AKABindingExpressionTypeNone;
        }

        result = (self.expressionType & expressionType) != 0;

        if (!result && error)
        {
            *error = [AKABindingErrors invalidBindingExpression:self
                                   invalidPrimaryExpressionType:self.expressionType
                                                       expected:expressionType];
        }
    }

    return result;
}

- (BOOL)                    validateAttributesWithSpecification:(AKABindingExpressionSpecification*)specification
                                 overrideAllowUnknownAttributes:(BOOL)allowUnknownAttributes
                                                          error:(out_NSError)error
{
    __block BOOL result = YES;
    __block NSError* localError = nil;

    BOOL allowUnspecified = allowUnknownAttributes || specification.allowUnspecifiedAttributes;

    // Validation of option values specified as attributes:
    BOOL isOptionsConstant = ((specification.expressionType & AKABindingExpressionTypeOptionsConstant) &&
                               specification.optionsType);
    NSSet* options = nil;
    if (isOptionsConstant)
    {
        NSArray* optionNames = [AKABindingExpressionSpecification registeredOptionNamesForOptionsType:(req_NSString)specification.optionsType];
        if (optionNames.count > 0)
        {
            options = [NSSet setWithArray:optionNames];
        }
    }

    [self.attributes
     enumerateKeysAndObjectsUsingBlock:
     ^(req_NSString attributeName,
       req_AKABindingExpression bindingExpression,
       outreq_BOOL stop)
     {
         if (isOptionsConstant && [options containsObject:attributeName])
         {
             // Attribute is a valid option, no further validation needed
             return;
         }

         // Check for invalidly unknown attributes, note that if specification is nil, validation will fail:
         AKABindingAttributeSpecification* attributeSpecification =
             specification.attributes[attributeName];

         if (result && !allowUnspecified && attributeSpecification == nil)
         {
             NSArray* attributeNames = specification.attributes.allKeys;
             if (isOptionsConstant && options.count > 0)
             {
                 attributeNames = [attributeNames arrayByAddingObjectsFromArray:options.allObjects];
             }
             localError = [AKABindingErrors invalidBindingExpression:self
                                                    unknownAttribute:attributeName
                                                     knownAttributes:attributeNames];
             result = NO;
         }

         // perform attribute validation
         if (result)
         {
             result = [bindingExpression validateWithSpecification:attributeSpecification.bindingSourceSpecification
                                    overrideAllowUnknownAttributes:allowUnknownAttributes
                                                             error:&localError];
         }
         *stop = !result;
     }];

    if (result)
    {
        // Check that all required attributes are present
        [specification.attributes
         enumerateKeysAndObjectsUsingBlock:
         ^(req_NSString attributeName,
           req_AKABindingAttributeSpecification bindingSpecification,
           outreq_BOOL stop)
         {
             if (bindingSpecification.required)
             {
                 if (self.attributes[attributeName] == nil)
                 {
                     localError = [AKABindingErrors invalidBindingExpression:self
                                                    missingRequiredAttribute:attributeName];
                     result = NO;
                 }
             }
             *stop = !result;
         }];
    }

    if (!result)
    {
        if (error)
        {
            *error = localError;
        }
        else
        {
            @throw [NSException exceptionWithName:@"BindingExpressionAttributeValidationFailed"
                                           reason:localError.localizedDescription
                                         userInfo:@{ @"error": localError }];
        }
    }

    return result;
}

#pragma mark - Binding Support

- (opt_AKAUnboundProperty)bindingSourceUnboundPropertyInContext:(req_AKABindingContext)bindingContext
{
    (void)bindingContext;

    // Implemented by subclasses if supported
    return nil;
}

- (opt_AKAProperty)              bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                                  changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    (void)bindingContext;
    (void)changeObserver;
    AKAErrorAbstractMethodImplementationMissing();
}

- (opt_id)                          bindingSourceValueInContext:(req_AKABindingContext)bindingContext
{
    (void)bindingContext;
    // Has to be implemented by subclasses
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - Diagnostics

- (BOOL)                                             isConstant
{
    return NO;
}

- (NSString*)                  constantStringValueOrDescription
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSString*)                                       description
{
    return [self textWithNestingLevel:0
                               indent:@"\t"];
}

#pragma mark - Serialization

- (NSString*)text
{
    return [self textWithNestingLevel:0
                               indent:@""];
}

- (NSString*)          textForPrimaryExpressionWithNestingLevel:(NSUInteger)level
                                                         indent:(NSString*)indent
{
    (void)level;
    (void)indent;

    // Implemented by subclasses if supported
    return nil;
}

- (NSString*)textForPrimaryExpression
{
    return [self textForPrimaryExpressionWithNestingLevel:0 indent:@""];
}

- (NSString*)                              textWithNestingLevel:(NSUInteger)level
                                                         indent:(NSString*)indent
{
    static NSString*const kPrimaryAttributesSeparator = @" ";

    static NSString*const kAttributesOpen = @"{";
    static NSString*const kAttributesClose = @"}";
    static NSString*const kAttributeNameValueSeparator = @": ";
    static NSString*const kAttributeSeparator = @",";

    NSMutableString* result = [NSMutableString new];

    NSString* textForPrimaryExpression = [self textForPrimaryExpressionWithNestingLevel:level
                                                                                 indent:indent];

    if (textForPrimaryExpression.length > 0)
    {
        [result appendString:textForPrimaryExpression];
    }

    if (self.attributes.count > 0)
    {
        if (result.length > 0)
        {
            [result appendString:kPrimaryAttributesSeparator];
        }

        NSString* attributePrefix;

        if (indent.length > 0)
        {
            attributePrefix = @"\n";
        }
        else
        {
            attributePrefix = @" ";
        }

        [result appendString:kAttributesOpen];

        __block NSUInteger i = 0;
        NSUInteger count = self.attributes.count;

        [self.attributes
         enumerateKeysAndObjectsUsingBlock:
         ^(NSString* _Nonnull key, AKABindingExpression* _Nonnull obj, BOOL* _Nonnull stop)
         {
             (void)stop;

             NSString* attributeValueText = [obj textWithNestingLevel:level + 1
                                                               indent:indent];

             [result appendString:attributePrefix];
             [result aka_appendString:indent
                               repeat:level + 1];

             [result appendString:key];

             [result appendString:kAttributeNameValueSeparator];

             [result appendString:attributeValueText];

             if (i < count - 1)
             {
                 [result appendString:kAttributeSeparator];
             }
             ++i;
         }];

        [result appendString:attributePrefix];
        [result aka_appendString:indent repeat:level];
        [result appendString:kAttributesClose];
    }

    return result;
}

@end





