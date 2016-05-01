//
//  AKAEnumConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAEnumConstantBindingExpression.h"

#import "AKABindingErrors.h"
#import "AKABindingExpressionParser.h"


#pragma mark - AKAEnumConstantBindingExpression
#pragma mark -

@implementation AKAEnumConstantBindingExpression

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                   specification:(opt_AKABindingSpecification)specification
{
    NSString* enumerationType;
    NSString* symbolicValue;

    if ([constant isKindOfClass:[NSString class]])
    {
        NSArray<NSString*>* components = [((NSString*)constant) componentsSeparatedByString:@"."];
        NSUInteger index = 0;

        if (components.count > 0 && components[0].length == 0)
        {
            ++index;
        }
        else if (components.count > 1 && [AKABindingExpressionSpecification isEnumerationTypeDefined:components[0]])
        {
            enumerationType = components[0];
            ++index;
        }

        if (index < components.count)
        {
            symbolicValue = [[components subarrayWithRange:NSMakeRange(index, components.count - index)] componentsJoinedByString:@"."];
            if (symbolicValue.length == 0)
            {
                symbolicValue = nil;
            }
        }
    }
    else if (constant != nil)
    {
        NSString* reason = @"Invalid primary expression type, expected nil or an instance of NSString or NSNumber";
        NSString* name = [NSString stringWithFormat:@"Invalid enumeration primary expression: %@: %@", constant, reason];

        [NSException exceptionWithName:name reason:reason userInfo:nil];
    }

    id value = nil;

    if (symbolicValue.length > 0 && enumerationType.length > 0)
    {
        NSError* error;
        value = [AKABindingExpressionSpecification resolveEnumeratedValue:symbolicValue
                                                                  forType:enumerationType
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
        self.enumerationType = enumerationType;
        self.symbolicValue = symbolicValue;
    }

    return self;
}

#pragma mark - Validation

- (BOOL)validatePrimaryExpressionType:(AKABindingExpressionType)expressionType
                                error:(NSError *__autoreleasing  _Nullable *)error
{
    // Enumeration expressions can be used in place of all types but Array and None to enable
    // the use of user defined enumeration types for shared objects.

    // TODO: this is too lax, instead it should be possible to specifiy the expression types that
    // a specific enumeration type can replace when registering an enumeration.

    AKABindingExpressionType nonCoercibleTypes = AKABindingExpressionTypeArray | AKABindingExpressionTypeNone;
    AKABindingExpressionType coercibleTypes = ~nonCoercibleTypes;

    BOOL result = (expressionType & coercibleTypes) != 0;

    if (!result)
    {
        result = [super validatePrimaryExpressionType:expressionType error:error];
    }

    return result;
}

- (BOOL)validate:(out_NSError)error
{
    AKABindingExpressionSpecification* specification = self.specification.bindingSourceSpecification;
    BOOL result = [super validate:error];
    NSError* localError = nil;

    if (specification)
    {
        NSString* enumerationType = specification.enumerationType;

        // Fallback to options type if the specified type is an options type.
        if (specification.enumerationType == nil &&
            specification.optionsType != nil &&
            specification.expressionType == AKABindingExpressionTypeOptionsConstant)
        {
            enumerationType = specification.optionsType;
        }


        if (self.enumerationType == nil)
        {
            if (enumerationType.length > 0)
            {
                self.enumerationType = enumerationType;
            }
            else if (self.symbolicValue.length > 0)
            {
                // Only an error if a value is given, otherwise the expression will validly evaluate
                // to nil.
                result = NO;
                localError = [AKABindingErrors invalidBindingExpression:self
                                       noEnumerationTypeInSpecification:(req_AKABindingExpressionSpecification)specification];
            }
        }
        else if (enumerationType.length > 0 && ![enumerationType isEqualToString:(req_NSString)self.enumerationType])
        {
            result = NO;
            localError = [AKABindingErrors invalidBindingExpression:self
                                            enumerationTypeMismatch:(req_AKABindingExpressionSpecification)specification];
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

- (void)setEnumerationType:(NSString*)enumerationType
{
    NSParameterAssert(enumerationType == _enumerationType || _enumerationType == nil);
    _enumerationType = enumerationType;
}

- (id)constant
{
    if (super.constant == nil && self.enumerationType.length > 0 && self.symbolicValue.length > 0)
    {
        NSError* error = nil;
        self.constant = [AKABindingExpressionSpecification resolveEnumeratedValue:self.symbolicValue
                                                                         forType:self.enumerationType
                                                                           error:&error];

        if (super.constant == nil && error != nil)
        {
            NSAssert(NO, @"%@", error.localizedDescription);
        }
    }

    return super.constant;
}

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeEnumConstant;
}

- (NSString*)keyword
{
    return [AKABindingExpressionParser keywordEnum];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.enumerationType.length > 0)
    {
        if (self.symbolicValue.length > 0)
        {
            result = [NSString stringWithFormat:@"$%@.%@", self.enumerationType, self.symbolicValue];
        }
    }
    else if (self.symbolicValue.length > 0)
    {
        result = [NSString stringWithFormat:@".%@", self.symbolicValue];
    }

    if (!result)
    {
        result = @"$enum";
    }

    return result;
}

@end

