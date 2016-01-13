//
//  AKABinding_AKABinding_formatter.m
//  AKABeacon
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;
@import AKACommons.AKALog;

#include <objc/runtime.h>

#import "AKABinding_AKABinding_formatter.h"
#import "AKABindingSpecification.h"
#import "AKABindingErrors.h"
#import "AKANSEnumerations.h"

@interface AKABinding_AKABinding_formatter()

@property(nonatomic)           id                                  formatterSource;
@property(nonatomic, readonly) AKABindingExpression*               bindingExpression;

@end

@implementation AKABinding_AKABinding_formatter

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
           @"expressionType":               @(AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeClass | AKABindingExpressionTypeNone),
           @"attributes":
               @{ @"formattingContext":
                      @{ @"required":        @NO,
                         @"use":             @(AKABindingAttributeUseManually),
                         @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                         @"enumerationType": @"NSFormattingContext" },

                  // NSFormatter does not itself provide a locale property:
                  //                      @"locale":
                  //                          @{ @"required":        @NO,
                  //                             @"use":             @(AKABindingAttributeUseManually),
                  //                             @"expressionType":  @(AKABindingExpressionTypeString) }
                  },
           @"allowUnspecifiedAttributes":   @YES
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
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

- (instancetype)                          initWithTarget:(req_id)target
                                                property:(opt_SEL)property
                                              expression:(req_AKABindingExpression)bindingExpression
                                                 context:(req_AKABindingContext)bindingContext
                                                delegate:(opt_AKABindingDelegate)delegate
                                                   error:(out_NSError)error
{
    self = [super initWithTarget:target
                        property:property
                      expression:bindingExpression
                         context:bindingContext
                        delegate:delegate
                           error:error];
    if (self)
    {
        _bindingExpression = bindingExpression;
    }

    return self;
}

- (AKAProperty *)      defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                 context:(req_AKABindingContext)bindingContext
                                          changeObserver:(AKAPropertyChangeObserver)changeObserver
                                                   error:(out_NSError)error
{
    (void)bindingExpression;
    (void)bindingContext;
    (void)error;
    if (_formatter == nil)
    {
        _formatter = [self defaultFormatter];
    }
    AKAProperty* result = [AKAProperty propertyOfWeakKeyValueTarget:_formatter
                                                            keyPath:nil
                                                     changeObserver:changeObserver];
    return result;
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
        targetValue = self.formatter;
        result = targetValue != nil;
    }

    if (!result)
    {
        result = YES;

        // Unwrap sourceValue if it is an AKAProperty
        if ([sourceValue isKindOfClass:[AKAProperty class]])
        {
            sourceValue = [(AKAProperty*)sourceValue value];
        }

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
        else
        {
            // TODO: this should not be reached anymore:
            // Fallback to createMutableFormatter/defaultFormatter if no formatter was provided by binding source:
            if (self.bindingExpression.attributes.count > 0)
            {
                targetValue = [self createMutableFormatter];
            }
            else
            {
                targetValue = [self defaultFormatter];
            }
        }

        // Cache conversion result
        _formatter = targetValue;

        // Apply formatter customizations (TODO: that could/should be done via sub bindings, check later).
        if (targetValue != nil)
        {
            NSDictionary<NSString*, AKABindingAttributeSpecification*>* attributeSpecs =
                self.bindingExpression.specification.bindingSourceSpecification.attributes;

            [self.bindingExpression.attributes
             enumerateKeysAndObjectsUsingBlock:
             ^(NSString* _Nonnull attributeName, AKABindingExpression* _Nonnull bindingExpression, BOOL* _Nonnull stop)
             {
                 (void)stop;

                 AKABindingAttributeSpecification* attributeSpec = attributeSpecs[attributeName];

                 if (attributeSpec == nil || attributeSpec.attributeUse == AKABindingAttributeUseManually)
                 {
                     id<AKABindingContextProtocol> bindingContext = self.bindingContext;
                     id value = nil;
                     if (bindingExpression.class != [AKABindingExpression class])
                     {
                         // Only evaluate expression if it is a base type of AKABindingExpression (otherwise it does not have a defined value).
                         value = [bindingExpression bindingSourceValueInContext:bindingContext];
                     }

                     id (^converter)(id) = self.configurationValueConvertersByPropertyName[attributeName];

                     if (converter)
                     {
                         value = converter(value);
                     }

                     if (value != nil)
                     {
                         [targetValue setValue:value forKey:attributeName];
                     }
                     else
                     {
                         AKALogError(@"Attempt to set undefined value for key %@ in formatter %@", attributeName, self->_formatter);
                     }
                 }
             }];
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

- (BOOL)           shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                changeTo:(opt_id)newSourceValue
                                             validatedTo:(opt_id)sourceValue
{
    (void)oldSourceValue;
    (void)newSourceValue;
    (void)sourceValue;

    // TODO: allow updating the target formatter, later though. We need to ensure that the target
    // views layout is updated if necessary
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

- (NSDictionary<NSString*, id (^)(id)>*)configurationValueConvertersByPropertyName
{
    return nil;
}

@end
