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
    id value;

    if (attributes)
    {
        value = attributes[@"value"];
    }

    if ([constant isKindOfClass:[NSString class]])
    {
        NSArray* components = [((NSString*)constant) componentsSeparatedByString:@"."];

        if (components.count == 1)
        {
            // If only one component is given, it is interpreted either as type or value
            if (attributes[@"value"] != nil)
            {
                // If there are attributes, the only reasonable interpretation is that the
                // constant is meant to be the enumeration type.
                enumerationType = components.firstObject;
            }
            else
            {
                // If there are no attributes, the constant is interpreted as symbolic value
                symbolicValue = components.firstObject;
            }
        }
        else if (components.count == 2)
        {
            enumerationType = components[0];
            symbolicValue = components[1];
        }
        else
        {
            NSString* reason = @"Too many dot-separated components, use $enum, $enum.TYPE, $enum.VALUE, $enum.TYPE.VALUE or use $enum or $enum.TYPE { value: <constant expression> } to specify a non-symbolic value; note that an unspecified value is interpreted as nil or zero in numeric contexts";
            NSString* name = [NSString stringWithFormat:@"Invalid enumeration primary expression: %@: %@", constant, reason];

            [NSException exceptionWithName:name reason:reason userInfo:nil];
        }
    }
    else if (constant != nil)
    {
        NSString* reason = @"Invalid primary expression type, expected nil or an instance of NSString or NSNumber";
        NSString* name = [NSString stringWithFormat:@"Invalid enumeration primary expression: %@: %@", constant, reason];

        [NSException exceptionWithName:name reason:reason userInfo:nil];
    }

    if (value == nil && symbolicValue.length > 0 && enumerationType.length > 0)
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

- (BOOL)validate:(out_NSError)error
{
    AKABindingExpressionSpecification* specification = self.specification.bindingSourceSpecification;
    BOOL result = [super validate:error];
    NSError* localError = nil;

    if (specification)
    {
        NSString* enumerationType = specification.enumerationType;

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

    if (self.constant)
    {
        if (self.attributes.count > 0)
        {
            NSString* enumerationType = self.enumerationType;

            if (enumerationType == nil)
            {
                enumerationType = @"";
            }
            NSString* symbolicValue = self.symbolicValue;

            if (symbolicValue == nil)
            {
                symbolicValue = @"";
            }
            result = [NSString stringWithFormat:@"$%@%@%@%@%@",
                      [self keyword],
                      (enumerationType.length > 0 ? @"." : @""),
                      enumerationType,
                      (symbolicValue.length > 0 ? @"." : @""),
                      symbolicValue];
        }
    }
    
    return result;
}

@end

