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

#pragma mark - AKABindingProvider_AKABinding_formatter - Private Interface
#pragma mark -

@implementation AKABindingProvider_AKABinding_formatter

#pragma mark - Initialization

+ (instancetype)                            sharedInstance
{
    static AKABindingProvider_AKABinding_formatter* instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_AKABinding_formatter new];
    });

    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self registerEnumerationAndOptionTypes];
    }
    return self;
}

#pragma mark - Binding Expression Validation

- (void)registerEnumerationAndOptionTypes
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AKABindingExpressionSpecification registerEnumerationType:@"NSFormattingContext"
                                                  withValuesByName:[AKANSEnumerations
                                                                    formattingContextsByName]];
    });
}

- (AKABindingSpecification*)                 specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        Class bindingType = [AKABinding_AKABinding_formatter class];
        Class providerType = self.class;
        
        NSDictionary* spec =
            @{ @"bindingType":                  bindingType,
               @"bindingProviderType":          providerType,
               @"targetType":                   [AKAProperty class],
               @"expressionType":               @(AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeClass),
               @"attributes":
                   @{ @"formattingContext":
                          @{ @"required":        @NO,
                             @"use":             @(AKABindingAttributeUseIgnore),
                             @"expressionType":  @(AKABindingExpressionTypeEnumConstant),
                             @"enumerationType": @"NSFormattingContext" },

// NSFormatter does not itself provide a locale property:
//                      @"locale":
//                          @{ @"required":        @NO,
//                             @"use":             @(AKABindingAttributeUseIgnore),
//                             @"expressionType":  @(AKABindingExpressionTypeString) }
                      },
               @"allowUnspecifiedAttributes":   @YES
               };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

@end


#pragma mark - Initialization

@implementation AKABinding_AKABinding_formatter

- (instancetype)                          initWithTarget:(req_id)target
                                                property:(opt_SEL)property
                                              expression:(req_AKABindingExpression)bindingExpression
                                                 context:(req_AKABindingContext)bindingContext
                                                delegate:(opt_AKABindingDelegate)delegate
                                                   error:(out_NSError)error
{
    NSParameterAssert([target isKindOfClass:[AKAProperty class]]);

    NSError* localError = nil;

    self = [super initWithTarget:target
                        property:property
                      expression:bindingExpression
                         context:bindingContext
                        delegate:delegate
                           error:error];

    if (self)
    {
        id sourceValue = self.bindingSource.value;

        if ([sourceValue isKindOfClass:[NSFormatter class]])
        {
            _formatter = sourceValue;

            if (_formatter != nil && bindingExpression.attributes.count > 0)
            {
                // Do not modify an existing formatter, copy it instead
                _formatter = [_formatter copy];
            }
        }
        else if (sourceValue != nil)
        {
            if (class_isMetaClass(object_getClass(sourceValue)))
            {
                Class type = sourceValue;

                if ([type isSubclassOfClass:[NSFormatter class]])
                {
                    _formatter = [[type alloc] init];
                }
                else
                {
                    localError = [AKABindingErrors invalidBinding:self
                                                      sourceValue:sourceValue
                                               expectedSubclassOf:[NSFormatter class]];
                    self = nil;
                }
            }
            else
            {
                AKATypePattern* typePattern =
                    [[AKATypePattern alloc]initWithArrayOfClasses:@[ objc_getClass("Class"), [NSFormatter class]]];
                localError = [AKABindingErrors invalidBinding:self
                                                  sourceValue:sourceValue
                                       expectedInstanceOfType:typePattern];
                self = nil;
            }
        }
        else
        {
            // Fallback to createMutableFormatter/defaultFormatter if no formatter was provided by binding source:
            if (bindingExpression.attributes.count > 0)
            {
                _formatter = [self createMutableFormatter];
            }
            else
            {
                _formatter = [self defaultFormatter];
            }
        }

        if (_formatter != nil)
        {
            [bindingExpression.attributes
             enumerateKeysAndObjectsUsingBlock:
             ^(NSString* _Nonnull key, AKABindingExpression* _Nonnull obj, BOOL* _Nonnull stop)
             {
                 (void)stop;

                 // TODO: make this more robust and add error handling/reporting
                 id value = [obj bindingSourceValueInContext:bindingContext];

                 id (^converter)(id) = self.configurationValueConvertersByPropertyName[key];

                 if (converter)
                 {
                     value = converter(value);
                 }

                 if (value != nil)
                 {
                     [self->_formatter setValue:value forKey:key];
                 }
                 else
                 {
                     AKALogError(@"Attempt to set undefined value for key %@ in formatter %@", key, self->_formatter);
                 }
             }];
        }

        // This implementation initializes the formatter once and does not observe changes in
        // neither direction.
        self.bindingTarget.value = self.formatter;
    }

    if (self == nil && localError)
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
    return self;
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
