//
//  AKABinding_AKABinding_formatter.m
//  AKAControls
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;

#import "AKABinding_AKABinding_formatter.h"
#include <objc/runtime.h>

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

#pragma mark - Binding Expression Validation

- (AKABindingSpecification*)                 specification
{
    Class bindingType = [AKABinding_AKABinding_formatter class];
    Class providerType = self.class;

    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
            @{ @"bindingType":                  bindingType,
               @"bindingProviderType":          providerType,
               @"targetType":                   [AKAProperty class],
               @"expressionType":               @(AKABindingExpressionTypeAnyKeyPath | AKABindingExpressionTypeClass),
               @"allowUnspecifiedAttributes":   @YES };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec];
    });

    return result;
}

@end


#pragma mark - Initialization

@implementation AKABinding_AKABinding_formatter

- (instancetype)                        initWithProperty:(req_AKAProperty)bindingTarget
                                              expression:(req_AKABindingExpression)bindingExpression
                                                 context:(req_AKABindingContext)bindingContext
                                                delegate:(opt_AKABindingDelegate)delegate
                                                   error:(out_NSError)error
{
    self = [super initWithProperty:bindingTarget
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
                _formatter = [_formatter copy];
            }
        }
        else if (sourceValue != nil)
        {
            NSAssert(class_isMetaClass(object_getClass(sourceValue)),
                     @"Expected primary expression of formatter to be a key path refering to an instance of NSFormatter or a subclass of NSFormatter, got %@", sourceValue);

            if (class_isMetaClass(object_getClass(sourceValue)))
            {
                Class type = sourceValue;

                if ([type isSubclassOfClass:[NSFormatter class]])
                {
                    _formatter = [[type alloc] init];
                }
                else
                {
                    NSAssert(class_isMetaClass(sourceValue),
                             @"Class %@ provided for formatter attribute is not a subclass of NSFormatter", sourceValue);
                }
            }
        }
        else if (bindingExpression.attributes.count > 0)
        {
            // Fallback for concrete formatter bindings, this will fail for
            // generic formatters:
            _formatter = [self createMutableFormatter];
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
                 [self->_formatter
                  setValue:value
                    forKey:key];
             }];
        }

        // This implementation initializes the formatter once and does not observe changes in
        // neither direction.
        self.bindingTarget.value = self.formatter;
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

    // TODO: allow updating the target number formatter, later though
    return NO;
}

#pragma mark - Abstract Methods

- (NSFormatter*)createMutableFormatter
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSDictionary<NSString*, id (^)(id)>*)configurationValueConvertersByPropertyName
{
    AKAErrorAbstractMethodImplementationMissing();
}

@end
