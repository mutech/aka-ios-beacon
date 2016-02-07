//
//  AKAFormatterPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;
@import AKACommons.AKALog;

#include <objc/runtime.h>

#import "AKAFormatterPropertyBinding.h"
#import "AKABindingSpecification.h"
#import "AKABindingErrors.h"
#import "AKANSEnumerations.h"
#import "AKABinding_Protected.h"

@interface AKAFormatterPropertyBinding()

@property(nonatomic)           id                                  formatterSource;
@property(nonatomic, readonly) AKABindingExpression*               bindingExpression;

@end

@implementation AKAFormatterPropertyBinding

+ (AKABindingSpecification*)                         specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    // Make sure that enumeration types are initialized before the specification is used the
    // first time:
    [self registerEnumerationAndOptionTypes];

    dispatch_once(&onceToken, ^{

        NSDictionary* spec =
        @{ @"bindingType":                  self,
           @"targetType":                   [AKAProperty class],
           @"expressionType":               @( (AKABindingExpressionTypeAnyKeyPath   |
                                                AKABindingExpressionTypeClass        |
                                                AKABindingExpressionTypeNone
                                                )),
           @"attributes":                   @{
                   @"formattingContext":        @{
                           @"required":         @NO,
                           @"use":              @(AKABindingAttributeUseManually),
                           @"expressionType":   @(AKABindingExpressionTypeEnumConstant),
                           @"enumerationType":  @"NSFormattingContext"
                           }
                   },
           @"allowUnspecifiedAttributes":   @YES
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    
    return result;
}

+ (AKABindingAttributeSpecification*)                         defaultAttributeSpecification
{
    static AKABindingAttributeSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        NSDictionary* spec = @{ @"use": @(AKABindingAttributeUseBindToTargetProperty) };
        result = [[AKABindingAttributeSpecification alloc] initWithDictionary:spec basedOn:[AKAPropertyBinding specification]];
    });

    return result;
}

+ (void)registerEnumerationAndOptionTypes
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AKABindingExpressionSpecification registerEnumerationType:@"NSFormattingContext"
                                                  withValuesByName:[AKANSEnumerations
                                                                    formattingContextsByName]];
    });
}

#pragma mark - Initialization

- (AKAProperty *)      defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                 context:(req_AKABindingContext)bindingContext
                                          changeObserver:(AKAPropertyChangeObserver)changeObserver
                                                   error:(out_NSError)error
{
    (void)bindingExpression;
    (void)bindingContext;
    (void)error;

    if (self.syntheticTargetValue == nil)
    {
        self.syntheticTargetValue = [self defaultFormatter];
    }

    AKAProperty* result = [AKAProperty propertyOfWeakKeyValueTarget:self
                                                            keyPath:@"syntheticTargetValue"
                                                     changeObserver:changeObserver];
    return result;
}

- (BOOL)initializeUnspecifiedAttribute:(NSString *)attributeName
                   attributeExpression:(req_AKABindingExpression)attributeExpression
                        bindingContext:(req_AKABindingContext)bindingContext
                                 error:(out_NSError)error
{
    return [self initializeTargetPropertyBindingAttribute:attributeName withSpecification:[self.class defaultAttributeSpecification] attributeExpression:attributeExpression bindingContext:bindingContext error:error];
}

#pragma mark - Conversion

- (BOOL)                              convertSourceValue:(id)sourceValue
                                           toTargetValue:(id  _Nullable __autoreleasing *)targetValueStore
                                                   error:(NSError *__autoreleasing  _Nullable *)error
{
    // TODO: this implementation caches source value and conversion result. This is ugly. Don't have an idea how to solve this properly yet.
    BOOL result = NO;
    NSError* localError = nil;
    id targetValue = nil;

    if (sourceValue == self.formatterSource)
    {
        targetValue = self.syntheticTargetValue;
        result = targetValue != nil;
    }

    if (!result)
    {
        result = YES;

        if ([sourceValue isKindOfClass:[NSFormatter class]])
        {
            targetValue = sourceValue;
            if (targetValue != nil && self.bindingExpression.attributes.count > 0)
            {
                // If using an existing formatter and attributes are defined, we copy the formatter
                // for not to produce potentially unwanted side effects when customizing it.
                targetValue = [targetValue copy];
            }
        }
        else if (sourceValue != nil)
        {
            if (class_isMetaClass(object_getClass(sourceValue)))
            {
                Class type = sourceValue;

                if ([type isSubclassOfClass:[NSFormatter class]])
                {
                    targetValue = [[type alloc] init];
                }
                else
                {
                    localError = [AKABindingErrors invalidBinding:self
                                                      sourceValue:sourceValue
                                               expectedSubclassOf:[NSFormatter class]];
                    result = NO;
                }
            }
            else
            {
                AKATypePattern* typePattern =
                    [[AKATypePattern alloc]initWithArrayOfClasses:@[ objc_getClass("Class"), [NSFormatter class]]];
                localError = [AKABindingErrors invalidBinding:self
                                                  sourceValue:sourceValue
                                       expectedInstanceOfType:typePattern];
                result = NO;
            }
        }

        // Cache conversion result
        if (targetValue != self.syntheticTargetValue)
        {
            self.syntheticTargetValue = targetValue;
        }
    }

    if (result)
    {
        *targetValueStore = targetValue;
    }
    else
    {
        if (error)
        {
            *error = localError;
        }
    }
    
    return result;
}

#pragma mark - Change Propagation

- (BOOL)           shouldUpdateSourceValueForTargetValue:(opt_id)oldTargetValue
                                                changeTo:(opt_id)newTargetValue
                                             validatedTo:(opt_id)targetValue
{
    (void)oldTargetValue;
    (void)newTargetValue;
    (void)targetValue;

    // We never want to override a possibly shared number formatter with whatever we have
    return NO;
}

#pragma mark - Abstract Methods

- (NSFormatter*)defaultFormatter
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSFormatter*)createMutableFormatter
{
    AKAErrorAbstractMethodImplementationMissing();
}

@end
