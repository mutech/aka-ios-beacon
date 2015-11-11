//
//  AKABindingProvider_UILabel_textBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAAssociatedValues;

#import "AKABindingProvider_UILabel_textBinding.h"

#import "AKABinding_AKABinding_numberFormatter.h"
#import "AKABinding_AKABinding_dateFormatter.h"

#pragma mark - AKABindingProvider_UILabel_textBinding - Implementation
#pragma mark -

@implementation AKABindingProvider_UILabel_textBinding

#pragma mark - Initialization

+ (instancetype)    sharedInstance
{
    static AKABindingProvider_UILabel_textBinding* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AKABindingProvider_UILabel_textBinding new];
    });
    return instance;
}

#pragma mark - Binding Expression Validation

- (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":          [AKABinding_UILabel_textBinding class],
           @"bindingProviderType":  [AKABindingProvider_UILabel_textBinding class],
           @"targetType":           [UILabel class],
           @"expressionType":       @(AKABindingExpressionTypeAny & ~AKABindingExpressionTypeArray),
           @"attributes":
               @{ @"numberFormatter":
                      @{ @"bindingProviderType": [AKABindingProvider_AKABinding_numberFormatter class],
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"numberFormatter"
                         },
                  @"dateFormatter":
                      @{ @"bindingProviderType": [AKABindingProvider_AKABinding_dateFormatter class],
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"dateFormatter"
                         },
                  @"formatter":
                      @{ @"bindingProviderType": [AKABindingProvider_AKABinding_formatter class],
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"formatter"
                         },
                  @"textForUndefinedValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"textForUndefinedValue"
                         },
                  @"textForYes":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"textForYes"
                         },
                  @"textForNo":
                      @{ @"expressionType":  @(AKABindingExpressionTypeString),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"textForNo"
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

@end


#pragma mark - AKABinding_UILabel_textBinding - Private Interface
#pragma mark -

@interface AKABinding_UILabel_textBinding() <UITextFieldDelegate>

#pragma mark - Saved UILabel State

@property(nonatomic, nullable) NSString*       originalText;
@property(nonatomic) UIView*     originalInputAccessoryView;

#pragma mark - Convenience

@property(nonatomic, readonly) UILabel*               label;

@end


#pragma mark - AKABinding_UILabel_textBinding - Implementation
#pragma mark -

@implementation AKABinding_UILabel_textBinding

#pragma mark - Initialization

- (void)validateTargetView:(req_UIView)targetView
{
    NSParameterAssert([targetView isKindOfClass:[UILabel class]]);
}

- (AKAProperty*)createBindingTargetPropertyForView:(req_UIView)view
{
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UILabel_textBinding* binding = target;
                return binding.label.text;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UILabel_textBinding* binding = target;
                NSString* text;
                if ([value isKindOfClass:[NSString class]])
                {
                    text = value;
                }
                else if (value != nil && value != [NSNull null])
                {
                    if ([value respondsToSelector:@selector(description)])
                    {
                        value = [value description];
                    }
                    // Here, we should have been relatively safe to get a string, but of course,
                    // no. So be extra careful and use stringWithFormat hoping that that will
                    // cover most remaining oddities
                    text = [NSString stringWithFormat:@"%@", value];
                }
                else if (binding.textForUndefinedValue.length > 0)
                {
                    text = binding.textForUndefinedValue;
                }
                else
                {
                    // TODO: CHECK: prevent label from collapsing if value is empty but not undefined
                    text = @" ";
                }

                binding.label.text = text;
            }
                          observationStarter:
            ^BOOL (id target)
            {
                (void)target;
                return YES; // nothing to observe (readonly)
            }
                          observationStopper:
            ^BOOL (id target)
            {
                (void)target; // nothing to observer (readonly).
                return YES;
            }];
}

- (UILabel *)label
{
    UIView* result = self.view;

    NSAssert(result == nil || [result isKindOfClass:[UILabel class]], @"View for %@ is required to be an instance of UILabel", self.class);

    return (UILabel*)result;
}

#pragma mark - Conversion

- (BOOL)convertSourceValue:(opt_id)sourceValue
             toTargetValue:(out_id)targetValueStore
                     error:(out_NSError)error
{
    BOOL result = NO;
    NSParameterAssert(targetValueStore != nil);
    if ([sourceValue isKindOfClass:[NSNumber class]])
    {
        if (self.numberFormatter)
        {
            *targetValueStore = [self.numberFormatter stringFromNumber:(req_NSNumber)sourceValue];
        }
        else if (self.textForYes && self.textForNo) // only if both are defined
        {
            *targetValueStore = ((req_NSNumber)sourceValue).boolValue ? self.textForYes : self.textForNo;
        }
        else if (self.formatter)
        {
            *targetValueStore = [self.formatter stringForObjectValue:(req_id)sourceValue]; // sourceValue is defined
        }
        else
        {
            *targetValueStore = ((req_NSNumber)sourceValue).stringValue;
        }
        result = YES;
    }
    else if ([sourceValue isKindOfClass:[NSDate class]])
    {
        if (self.dateFormatter)
        {
            *targetValueStore = [self.dateFormatter stringFromDate:(req_NSDate)sourceValue];
        }
        else if (self.formatter)
        {
            *targetValueStore = [self.formatter stringForObjectValue:(req_id)sourceValue]; // sourceValue is defined
        }
        else
        {
            *targetValueStore = ((req_NSDate)sourceValue).description;
        }
        result = YES;
    }
    else if (self.formatter && sourceValue != nil)
    {
        *targetValueStore = [self.formatter stringForObjectValue:(req_id)sourceValue];
        result = YES;
    }
    else
    {
        result = [super convertSourceValue:sourceValue toTargetValue:targetValueStore error:error];
    }
    return result;
}

@end
