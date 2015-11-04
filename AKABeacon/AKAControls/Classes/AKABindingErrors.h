//
//  AKABindingErrors.h
//  AKABeacon
//
//  Created by Michael Utech on 31.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlsErrors.h"
#import "AKABindingExpression.h"
#import "AKABindingContextProtocol.h"

typedef NS_ENUM(NSInteger, AKABindingErrorCodes)
{
    AKABindingErrorUndefinedBindingSource = AKABindingErrorCodesMin,

    AKABindingErrorInvalidAttriuteBindingExpressionType,
    AKABindingErrorInvalidBindingExpressionUnknownAttribute,
    AKABindingErrorInvalidBindingExpressionUnknownEnumerationValue,
    AKABindingErrorInvalidBindingExpressionInvalidUIFontTraitSpecification,
};

@interface AKABindingErrors : AKAControlsErrors

+ (NSError*)bindingErrorUndefinedBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext;

#pragma mark - Binding Expression Attribute Validation

+ (NSError*)invalidBindingExpression:(AKABindingExpression*)bindingExpression
                   forAttributeNamed:(NSString*)attributeName
                 invalidTypeExpected:(NSArray<Class>*)expectedType;

+ (NSError*)invalidBindingExpression:(AKABindingExpression *)bindingExpression
                    unknownAttribute:(NSString*)attributeName;

+ (NSError*)invalidBindingExpression:(AKABindingExpression *)bindingExpression
                   forAttributeNamed:(NSString *)attributeName
                   uifontTraitsError:(NSError*)error;

+ (NSError*)unknownSymbolicEnumerationValue:(req_NSString)symbolicValue
                         forEnumerationType:(req_NSString)enumerationType
                           withValuesByName:(NSDictionary<NSString*,NSNumber*>*)valuesByName;

@end
