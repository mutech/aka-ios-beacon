//
//  AKABindingErrors.m
//  AKABeacon
//
//  Created by Michael Utech on 31.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingErrors_Internal.h"
#import "AKABeaconErrors_Internal.h"
#import "AKABeaconNullability.h"

#import "AKABinding.h"

@implementation AKABindingErrors

#pragma mark - Binding Expression Validation

+ (req_NSError)                     invalidBindingExpression:(req_AKABindingExpression)expression
                                                 bindingType:(req_Class)bindingType
                            doesNotMatchSpecifiedBindingType:(req_Class)specifiedBindingType
{
    NSString* reason = @"Binding type mismatch";
    NSString* description = [NSString stringWithFormat:@"Binding type %@ does not match type %@ specified by binding expression %@. This is probably an error in the binding library or an extension thereof, indicating that a binding expression property uses a wrong binding type.",
                                                       bindingType, specifiedBindingType, expression];
    NSError* result = [NSError errorWithDomain:[AKABeaconErrors akaControlsErrorDomain]
                                          code:AKABindingErrorInvalidBindingType
                                      userInfo:@{ NSLocalizedFailureReasonErrorKey: reason,
                                                  NSLocalizedDescriptionKey: description }];
    return result;
}

+ (req_NSError)                     invalidBindingExpression:(AKABindingExpression*)bindingExpression
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


+ (req_NSError)                     invalidBindingExpression:(AKABindingExpression*)bindingExpression
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

+ (req_NSError)                     invalidBindingExpression:(AKABindingExpression*)bindingExpression
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

+ (req_NSError)                     invalidBindingExpression:(AKABindingExpression*)bindingExpression
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

+ (req_NSError)                     invalidBindingExpression:(AKABindingExpression*)bindingExpression
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

+ (req_NSError)                     invalidBindingExpression:(AKABindingExpression*)bindingExpression
     conditionalExpressionNotSupportedForControlViewBindings:(req_Class)controlViewBindingType
{
    NSString* reason = [NSString stringWithFormat:@"Conditional binding expression '%@' is not supported in control view bindings of type %@",
                        bindingExpression,
                        NSStringFromClass(controlViewBindingType)];
    NSString* description = [NSString stringWithFormat:@"Static binding expression validation failed: %@", reason];
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey: description,
                                NSLocalizedFailureReasonErrorKey: reason };

    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidConditionalBindingExpressionNotSupportedForControlViewBindings
                                      userInfo:userInfo];
    return result;
}

+ (req_NSError)bindingErrorUndefinedBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
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

+ (req_NSError)                     invalidBindingExpression:(AKABindingExpression*)bindingExpression
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

+ (req_NSError)                     invalidBindingExpression:(AKABindingExpression *)bindingExpression
                                            unknownAttribute:(NSString*)attributeName
                                             knownAttributes:(NSArray<NSString*>*_Nonnull)knownAttributes
{
    NSString* reason = [NSString stringWithFormat:@"Unknown attribute %@ (known attributes are: %@)", attributeName, [knownAttributes componentsJoinedByString:@", "]];
    NSString* description = [NSString stringWithFormat:@"Invalid binding expression %@: %@", bindingExpression, reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidBindingExpressionUnknownAttribute
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason }];
    return result;
}


+ (req_NSError)                     invalidBindingExpression:(AKABindingExpression *)bindingExpression
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

+ (req_NSError)                     invalidBindingExpression:(AKABindingExpression *)bindingExpression
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

+ (req_NSError)              unknownSymbolicEnumerationValue:(req_NSString)symbolicValue
                                          forEnumerationType:(req_NSString)enumerationType
                                            withValuesByName:(NSDictionary<NSString*,NSNumber*>*)valuesByName
{
    NSString* reason = [NSString stringWithFormat:@"Unknown symbolic enumeration value %@ for type %@, known values are: %@",
                        symbolicValue, enumerationType, [valuesByName.allKeys componentsJoinedByString:@", "]];
    NSString* description = [NSString stringWithFormat:@"Invalid enumeration constant binding expression: %@", reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidBindingExpressionUnknownEnumerationValue
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason }];
    return result;
}

#pragma mark - Binding Source Validation Errors (Runtime validation)

+ (req_NSError)                               invalidBinding:(req_AKABinding)binding
                                                 sourceValue:(opt_id)value
                                                      reason:(req_NSString)reason
{
    NSString* description = [NSString stringWithFormat:@"Invalid binding %@ source value %@: %@",
                             binding, value, reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorInvalidBindingSourceValue
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason }];
    return result;
}

+ (req_NSError)                               invalidBinding:(req_AKABinding)binding
                                                 sourceValue:(opt_id)value
                                      expectedInstanceOfType:(req_AKATypePattern)typePattern
{
    NSString* reason = [NSString stringWithFormat:@"Expected an instance of a type matching %@",
                        typePattern.description];
    return [self invalidBinding:binding sourceValue:value reason:reason];
}

+ (req_NSError)                               invalidBinding:(req_AKABinding)binding
                                                 sourceValue:(opt_id)value
                                          expectedSubclassOf:(req_Class)baseClass
{
    NSString* reason = [NSString stringWithFormat:@"Expected a sub class of %@",
                        baseClass];
    return [self invalidBinding:binding sourceValue:value reason:reason];
}


#pragma mark - Binding Conversion Errors

+ (req_NSError)              bindingErrorConversionOfBinding:(req_AKABinding)binding
                                                 targetValue:(opt_id)targetValue
                                        failedWithRangeError:(NSRange)expectedRange
{
    NSString* reason = [NSString stringWithFormat:@"Value out of range [%@..%@]",
                        @(expectedRange.location), @(expectedRange.location + expectedRange.length)];
    NSString* description = [NSString stringWithFormat:@"Conversion of binding %@ target %@ value %@ failed: %@",
                             binding, binding.targetValueProperty.value, targetValue, reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorConversionOfTargetToSourceFailedTargetOutOfRange
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason,
                                                  @"binding": binding,
                                                  @"value": targetValue,
                                                  @"expectedRange": [NSValue valueWithRange:expectedRange] } ];
    return result;
}


+ (req_NSError)              bindingErrorConversionOfBinding:(req_AKABinding)binding
                                                 targetValue:(opt_id)targetValue
                               failedWithInvalidTypeExpected:(Class)expectedType
{
    NSString* reason = [NSString stringWithFormat:@"Invalid type %@,  expected value to be an instance of: %@",
                        targetValue ? NSStringFromClass((Class)[targetValue class]) : @"nil", NSStringFromClass(expectedType)];
    NSString* description = [NSString stringWithFormat:@"Conversion of binding %@ target %@ value %@ failed: %@",
                             binding, binding.targetValueProperty.value, targetValue, reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorConversionOfTargetToSourceFailedInvalidTargetType
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason,
                                                  @"binding": binding,
                                                  @"value": targetValue,
                                                  @"expectedType": expectedType } ];
    return result;
}

+ (req_NSError)              bindingErrorConversionOfBinding:(req_AKABinding)binding
                                                 sourceValue:(opt_id)sourceValue
                          failedWithInvalidTypeExpectedTypes:(NSArray<Class>*_Nonnull)expectedTypes
{
    NSString* expected = [expectedTypes componentsJoinedByString:@", "];
    NSString* reason = [NSString stringWithFormat:@"Invalid type %@,  expected value to be an instance of: {%@}",
                        sourceValue ? NSStringFromClass((Class)[sourceValue class]) : @"nil",
                        expected];
    NSString* description = [NSString stringWithFormat:@"Conversion of binding %@ source %@ value %@ failed: %@",
                             binding, binding.sourceValueProperty.value, sourceValue, reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorConversionOfSourceToTargetFailedInvalidSourceType
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason,
                                                  @"binding": binding,
                                                  @"value": sourceValue,
                                                  @"expectedTypes": expectedTypes } ];
    return result;
}

+ (req_NSError)              bindingErrorConversionOfBinding:(req_AKABinding)binding
                                                 targetValue:(opt_id)targetValue
                                              usingFormatter:(req_NSFormatter)formatter
                                           failedWithMessage:(opt_NSString)message
{
    NSString* reason = message;
    NSString* description = [NSString stringWithFormat:@"Conversion of binding %@ target %@ value %@ using formatter %@ failed: %@",
                             binding, binding.targetValueProperty.value, targetValue, formatter, message];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorConversionOfTargetToSourceUsingFormatterFailed
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason,
                                                  @"binding": binding,
                                                  @"value": targetValue,
                                                  @"formatter": formatter }];
    return result;
}

+ (req_NSError)              bindingErrorConversionOfBinding:(req_AKABinding)binding
                                                 sourceValue:(opt_id)sourceValue
                                              usingFormatter:(req_NSFormatter)formatter
                                           failedWithMessage:(opt_NSString)message
{
    NSString* reason = message;
    NSString* description = [NSString stringWithFormat:@"Conversion of binding %@ source value %@ using formatter %@ failed: %@",
                             binding,
                             sourceValue,
                             formatter,
                             message];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorConversionOfSourceToTargetUsingFormatterFailed
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason,
                                                  @"binding": binding,
                                                  @"value": sourceValue,
                                                  @"formatter": formatter }];
    return result;
}

+ (req_NSError)              bindingErrorConversionOfBinding:(req_AKABinding)binding
                                  sourceValuePredicateFormat:(opt_id)sourceValue
                                         failedWithException:(NSException*_Nonnull)exception
{
    NSString* reason = exception.description;
    NSString* description = [NSString stringWithFormat:@"Conversion of binding %@ source predicate format `%@' failed with exception: %@",
                             binding,
                             sourceValue,
                             reason];
    NSError* result = [NSError errorWithDomain:self.akaControlsErrorDomain
                                          code:AKABindingErrorConversionOfSourcePredicateFormatToTargetPredicateFailed
                                      userInfo:@{ NSLocalizedDescriptionKey: description,
                                                  NSLocalizedFailureReasonErrorKey: reason,
                                                  @"binding": binding,
                                                  @"value": sourceValue,
                                                  @"exception": exception }];
    return result;
}

@end
