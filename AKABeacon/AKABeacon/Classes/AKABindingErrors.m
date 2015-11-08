//
//  AKABindingErrors.m
//  AKABeacon
//
//  Created by Michael Utech on 31.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingErrors_Internal.h"
#import "AKABeaconErrors_Internal.h"

@implementation AKABindingErrors

#pragma mark - Binding Expression Validation

+ (NSError*)invalidBindingExpression:(AKABindingExpression*)bindingExpression
        invalidPrimaryExpressionType:(AKABindingExpressionType)expressionType
                            expected:(AKABindingExpressionType)expressionTypePattern
{
    id expressionTypeDescription =
        [AKABindingExpressionSpecification expressionTypeDescription:expressionType];
    id expressionTypePatternDescription =
        [AKABindingExpressionSpecification expressionTypeSetDescription:expressionTypePattern];

    NSString* reason = [NSString stringWithFormat:@"Binding expression %@'s primary type %@ does not match required expression type pattern %@",
                        bindingExpression,
                        expressionTypeDescription,
                        expressionTypePatternDescription];
    NSString* description = [NSString stringWithFormat:@"Static binding expression validation failed: %@", reason];
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey: description,
                                NSLocalizedFailureReasonErrorKey: reason };

    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidPrimaryBindingExpressionType
                                      userInfo:userInfo];
    return result;
}


+ (NSError*)invalidBindingExpression:(AKABindingExpression*)bindingExpression
    noEnumerationTypeInSpecification:(AKABindingExpressionSpecification*)specification
{
    NSString* reason = [NSString stringWithFormat:@"Binding expression %@'s primary enumeration expression does not define an enumeration type, neither does its specification %@",
                        bindingExpression,
                        specification];
    NSString* description = [NSString stringWithFormat:@"Static binding expression validation failed: %@", reason];
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey: description,
                                NSLocalizedFailureReasonErrorKey: reason };

    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidPrimaryBindingExpressionNoEnumerationType
                                      userInfo:userInfo];
    return result;
}

+ (NSError*)invalidBindingExpression:(AKABindingExpression*)bindingExpression
             enumerationTypeMismatch:(AKABindingExpressionSpecification*)specification
{
    NSString* reason = [NSString stringWithFormat:@"Binding expression %@'s primary enumeration expression differs from the type %@ defined in its specification %@",
                        bindingExpression,
                        specification.enumerationType,
                        specification];
    NSString* description = [NSString stringWithFormat:@"Static binding expression validation failed: %@", reason];
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey: description,
                                NSLocalizedFailureReasonErrorKey: reason };

    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidPrimaryBindingExpressionMismatchingEnumerationType
                                      userInfo:userInfo];
    return result;
}

+ (NSError*)invalidBindingExpression:(AKABindingExpression*)bindingExpression
        noOptionsTypeInSpecification:(AKABindingExpressionSpecification*)specification
{
    NSString* reason = [NSString stringWithFormat:@"Binding expression %@'s primary options expression does not define an options type, neither does its specification %@",
                        bindingExpression,
                        specification];
    NSString* description = [NSString stringWithFormat:@"Static binding expression validation failed: %@", reason];
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey: description,
                                NSLocalizedFailureReasonErrorKey: reason };

    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidPrimaryBindingExpressionNoOptionsType
                                      userInfo:userInfo];
    return result;
}

+ (NSError*)invalidBindingExpression:(AKABindingExpression*)bindingExpression
                 optionsTypeMismatch:(AKABindingExpressionSpecification*)specification
{
    NSString* reason = [NSString stringWithFormat:@"Binding expression %@'s primary options expression differs from the type %@ defined in its specification %@",
                        bindingExpression,
                        specification.optionsType,
                        specification];
    NSString* description = [NSString stringWithFormat:@"Static binding expression validation failed: %@", reason];
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey: description,
                                NSLocalizedFailureReasonErrorKey: reason };

    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidPrimaryBindingExpressionMismatchingOptionsType
                                      userInfo:userInfo];
    return result;
}

+ (NSError*)bindingErrorUndefinedBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
{
    NSString* reason = [NSString stringWithFormat:@"Binding expression %@ in context %@ evaluates to an undefined value.", bindingExpression, bindingContext];
    NSString* description = [NSString stringWithFormat:@"Failed to create binding source property: %@", reason];
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey: description,
                                NSLocalizedFailureReasonErrorKey: reason };

    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorUndefinedBindingSource
                                      userInfo:userInfo];
    return result;
}

+ (NSError*)invalidBindingExpression:(AKABindingExpression*)bindingExpression
                   forAttributeNamed:(NSString*)attributeName
                 invalidTypeExpected:(NSArray<Class>*)expectedType
{
    NSString* reason = [NSString stringWithFormat:@"Invalid binding expression type %@, expected one of: %@", NSStringFromClass([bindingExpression class]), [expectedType componentsJoinedByString:@", "]];
    NSString* description = [NSString stringWithFormat:@"Invalid binding attribute %@: %@", attributeName, reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidAttriuteBindingExpressionType
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason }];
    return result;
}

+ (NSError*)invalidBindingExpression:(AKABindingExpression *)bindingExpression
                    unknownAttribute:(NSString*)attributeName
{
    NSString* reason = [NSString stringWithFormat:@"Unknown attribute %@", attributeName];
    NSString* description = [NSString stringWithFormat:@"Invalid binding expression %@: %@", bindingExpression, reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidBindingExpressionUnknownAttribute
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason }];
    return result;
}


+ (NSError*)invalidBindingExpression:(AKABindingExpression *)bindingExpression
            missingRequiredAttribute:(NSString*)attributeName
{
    NSString* reason = [NSString stringWithFormat:@"Missing required attribute %@", attributeName];
    NSString* description = [NSString stringWithFormat:@"Invalid binding expression %@: %@", bindingExpression, reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidBindingExpressionMissingRequiredAttribute
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason }];
    return result;
}

+ (NSError*)invalidBindingExpression:(AKABindingExpression *)bindingExpression
                   forAttributeNamed:(NSString *)attributeName
                   uifontTraitsError:(NSError*)error
{
    NSString* reason = error.localizedDescription;
    NSString* description = [NSString stringWithFormat:@"Invalid binding expression: %@: Invalid UIFont trait specification %@: %@", bindingExpression, attributeName, reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidBindingExpressionInvalidUIFontTraitSpecification
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason }];
    return result;
}

+ (NSError*)unknownSymbolicEnumerationValue:(req_NSString)symbolicValue
                         forEnumerationType:(req_NSString)enumerationType
                           withValuesByName:(NSDictionary<NSString*,NSNumber*>*)valuesByName
{
    NSString* reason = [NSString stringWithFormat:@"Unknown symbolic enumeration value %@ for type %@, known values are: %@",
                        symbolicValue, enumerationType, [valuesByName.allKeys componentsJoinedByString:@", "]];
    NSString* description = [NSString stringWithFormat:@"Invalid enumeration constant binding expression: %@", reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidBindingExpressionUnknownAttribute
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason }];
    return result;
}
@end
