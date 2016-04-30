//
//  AKAOptionsConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKAOptionsConstantBindingExpression.h"
#import "AKABooleanConstantBindingExpression.h"

#import "AKABindingErrors.h"
#import "AKABindingExpressionParser.h"


#pragma mark - AKAOptionsConstantBindingExpression
#pragma mark -

@implementation AKAOptionsConstantBindingExpression

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                   specification:(opt_AKABindingSpecification)specification
{
    NSString* optionsType;
    NSString* symbolicValue;
    NSNumber* value;
    NSDictionary* effectiveAttributes = attributes;

    if ([constant isKindOfClass:[NSString class]])
    {
        NSArray* components = [((NSString*)constant) componentsSeparatedByString:@"."];

        if (components.count == 1)
        {
            // If only one component is given, it is interpreted either as type or value
            if (attributes.count > 0)
            {
                // If there are attributes, the only reasonable interpretation is that the
                // constant is meant to be the enumeration type.
                optionsType = components.firstObject;
            }
            else
            {
                // If there are no attributes, the constant is interpreted as symbolic value
                symbolicValue = components.firstObject;
            }
        }
        else if (components.count == 2)
        {
            optionsType = components[0];
            symbolicValue = components[1];
        }
        else
        {
            NSString* reason = @"Too many dot-separated components, use $TYPE {.Value}, {.Value}, $options {VALUE, ...}, $options.TYPE {VALUE, ...}, $options.VALUE or $options.TYPE.VALUE";
            NSString* name = [NSString stringWithFormat:@"Invalid options primary expression: %@: %@", constant, reason];

            [NSException exceptionWithName:name reason:reason userInfo:nil];
        }
    }
    else if ([constant isKindOfClass:[NSNumber class]])
    {
        value = constant;
    }
    else if (constant != nil)
    {
        NSString* reason = @"Invalid primary expression type, expected nil or an instance of NSString or NSNumber";
        NSString* name = [NSString stringWithFormat:@"Invalid options primary expression: %@: %@", constant, reason];

        [NSException exceptionWithName:name reason:reason userInfo:nil];
    }

    if (value == nil)
    {
        if (symbolicValue.length > 0)
        {
            if (effectiveAttributes.count == 0)
            {
                effectiveAttributes = @{ symbolicValue: [AKABooleanConstantBindingExpression constantTrue] };
            }
            else
            {
                NSMutableDictionary* tmp = [NSMutableDictionary dictionaryWithDictionary:effectiveAttributes];
                tmp[symbolicValue] = [AKABooleanConstantBindingExpression constantTrue];
            }
        }

        NSError* error;
        value = [AKABindingExpressionSpecification resolveOptionsValue:effectiveAttributes
                                                                 forType:optionsType
                                                                   error:&error];

        if (!value && error) // if error is not set, value is validly undefined (f.e. no enumeration type yet)
        {
            @throw [NSException exceptionWithName:error.localizedDescription
                                           reason:error.localizedFailureReason
                                         userInfo:nil];
        }
    }

    if (self = [super initWithConstant:value attributes:attributes specification:specification])
    {
        self.optionsType = optionsType;
    }

    return self;
}

#pragma mark - Validation

- (BOOL)validate:(out_NSError)error
{
    AKABindingExpressionSpecification* specification = self.specification.bindingSourceSpecification;
    BOOL result = [super validate:error];
    NSError* localError = nil;

    if (specification)
    {
        NSString* optionsType = specification.optionsType;

        if (self.optionsType == nil)
        {
            if (optionsType.length > 0)
            {
                self.optionsType = optionsType;
            }
            else if (self.attributes.count > 0)
            {
                // Only an error if a value is given, otherwise the expression will validly evaluate to zero.
                result = NO;
                localError = [AKABindingErrors invalidBindingExpression:self noOptionsTypeInSpecification:specification];;
            }
        }
        else if (optionsType.length > 0 && ![optionsType isEqualToString:(req_NSString)self.optionsType])
        {
            result = NO;
            localError = [AKABindingErrors invalidBindingExpression:self
                                                optionsTypeMismatch:specification];
        }
    }

    if (!result && localError)
    {
        if (error)
        {
            *error = localError;
        }
        else
        {
            @throw [NSException exceptionWithName:@"UnhandledError"
                                           reason:localError.localizedDescription
                                         userInfo:@{ @"error": localError }];
        }
    }

    return result;
}

#pragma mark - Properties

- (void)setOptionsType:(NSString*)optionsType
{
    NSParameterAssert(optionsType == _optionsType || _optionsType == nil);
    _optionsType = optionsType;
}

- (id)constant
{
    if (super.constant == nil && self.optionsType.length > 0 && self.attributes.count > 0)
    {
        NSError* error = nil;
        self.constant = [AKABindingExpressionSpecification resolveOptionsValue:self.attributes
                                                                         forType:self.optionsType
                                                                           error:&error];

        if (super.constant == nil && error != nil)
        {   // TODO: Error handling!
            NSAssert(NO, @"%@", error.localizedDescription);
        }
    }

    return super.constant;
}

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeOptionsConstant;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [AKABindingExpressionParser keywordOptions];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        if (self.attributes.count > 0)
        {
            NSString* optionsType = self.optionsType;

            if (optionsType == nil)
            {
                optionsType = @"";
            }
            result = [NSString stringWithFormat:@"$%@%@%@",
                      [self keyword],
                      (optionsType.length > 0 ? @"." : @""),
                      optionsType];
        }
    }
    
    return result;
}

@end

