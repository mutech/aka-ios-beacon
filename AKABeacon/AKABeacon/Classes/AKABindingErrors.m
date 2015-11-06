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
