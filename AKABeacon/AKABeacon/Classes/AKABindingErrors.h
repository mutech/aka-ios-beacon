//
//  AKABindingErrors.h
//  AKABeacon
//
//  Created by Michael Utech on 31.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABeaconErrors.h"
#import "AKABindingExpression.h"
#import "AKABindingContextProtocol.h"
#import "AKAbinding.h"

typedef NS_ENUM(NSInteger, AKABindingErrorCodes)
{
    AKABindingErrorUndefinedBindingSource = AKABindingErrorCodesMin,

    AKABindingErrorInvalidPrimaryBindingExpressionType,
    AKABindingErrorInvalidPrimaryBindingExpressionNoEnumerationType,
    AKABindingErrorInvalidPrimaryBindingExpressionMismatchingEnumerationType,
    AKABindingErrorInvalidPrimaryBindingExpressionNoOptionsType,
    AKABindingErrorInvalidPrimaryBindingExpressionMismatchingOptionsType,
    AKABindingErrorInvalidAttriuteBindingExpressionType,
    AKABindingErrorInvalidBindingExpressionMissingRequiredAttribute,
    AKABindingErrorInvalidBindingExpressionUnknownAttribute,
    AKABindingErrorInvalidBindingExpressionUnknownEnumerationValue,
    AKABindingErrorInvalidBindingExpressionInvalidUIFontTraitSpecification,

    AKABindingErrorInvalidBindingSourceValueType,
    AKABindingErrorConversionOfTargetToSourceFailedTargetOutOfRange,
    AKABindingErrorConversionOfTargetToSourceFailedInvalidTargetType,
    AKABindingErrorConversionOfSourceToTargetFailedInvalidSourceType,
    AKABindingErrorConversionOfTargetToSourceUsingFormatterFailed,
    AKABindingErrorConversionOfSourceToTargetUsingFormatterFailed,
};


@interface AKABindingErrors: AKABeaconErrors

+ (req_NSError)bindingErrorUndefinedBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                       context:(req_AKABindingContext)bindingContext;

#pragma mark - Binding Expression Validation

+ (req_NSError)                       invalidBindingExpression:(req_AKABindingExpression)bindingExpression
                                  invalidPrimaryExpressionType:(AKABindingExpressionType)expressionType
                                                      expected:(AKABindingExpressionType)expressionTypePattern;

+ (req_NSError)                       invalidBindingExpression:(req_AKABindingExpression)bindingExpression
                              noEnumerationTypeInSpecification:(req_AKABindingExpressionSpecification)specification;

+ (req_NSError)                       invalidBindingExpression:(req_AKABindingExpression)bindingExpression
                                       enumerationTypeMismatch:(req_AKABindingExpressionSpecification)specification;

+ (req_NSError)                       invalidBindingExpression:(req_AKABindingExpression)bindingExpression
                                  noOptionsTypeInSpecification:(req_AKABindingExpressionSpecification)specification;

+ (req_NSError)                       invalidBindingExpression:(req_AKABindingExpression)bindingExpression
                                           optionsTypeMismatch:(req_AKABindingExpressionSpecification)specification;

#pragma mark - Binding Expression Attribute Validation

+ (req_NSError)                       invalidBindingExpression:(req_AKABindingExpression)bindingExpression
                                             forAttributeNamed:(req_NSString)attributeName
                                           invalidTypeExpected:(NSArray<Class>*_Nonnull)expectedType;

+ (req_NSError)                       invalidBindingExpression:(req_AKABindingExpression)bindingExpression
                                              unknownAttribute:(req_NSString)attributeName
                                               knownAttributes:(NSArray<NSString*>*_Nonnull)knownAttributes;

+ (req_NSError)                       invalidBindingExpression:(req_AKABindingExpression)bindingExpression
                                      missingRequiredAttribute:(req_NSString)attributeName;

+ (req_NSError)                       invalidBindingExpression:(req_AKABindingExpression)bindingExpression
                                             forAttributeNamed:(req_NSString)attributeName
                                             uifontTraitsError:(req_NSError)error;

+ (req_NSError)                unknownSymbolicEnumerationValue:(req_NSString)symbolicValue
                                            forEnumerationType:(req_NSString)enumerationType
                                              withValuesByName:(NSDictionary<NSString*, NSNumber*>*_Nonnull)valuesByName;

#pragma mark - Binding Source Validation Errors (Runtime validation)

+ (req_NSError)                                 invalidBinding:(req_AKABinding)binding
                                                   sourceValue:(opt_id)value
                                        expectedInstanceOfType:(req_AKATypePattern)typePattern;

+ (req_NSError)                                 invalidBinding:(req_AKABinding)binding
                                                   sourceValue:(opt_id)value
                                            expectedSubclassOf:(req_Class)baseClass;

#pragma mark - Binding Conversion Errors

+ (req_NSError)                bindingErrorConversionOfBinding:(req_AKABinding)binding
                                                   targetValue:(opt_id)targetValue
                                          failedWithRangeError:(NSRange)expectedRange;

+ (req_NSError)                bindingErrorConversionOfBinding:(req_AKABinding)binding
                                                   targetValue:(opt_id)targetValue
                                 failedWithInvalidTypeExpected:(req_Class)expectedType;

+ (req_NSError)                bindingErrorConversionOfBinding:(req_AKABinding)binding
                                                   sourceValue:(opt_id)sourceValue
                                 failedWithInvalidTypeExpected:(req_Class)expectedType;

+ (req_NSError)                bindingErrorConversionOfBinding:(req_AKABinding)binding
                                                   targetValue:(opt_id)targetValue
                                                usingFormatter:(req_NSFormatter)formatter
                                             failedWithMessage:(opt_NSString)message;

+ (req_NSError)                bindingErrorConversionOfBinding:(req_AKABinding)binding
                                                   sourceValue:(opt_id)targetValue
                                                usingFormatter:(req_NSFormatter)formatter
                                             failedWithMessage:(opt_NSString)message;

@end
