//
//  AKABinding_UIBarButtonBinding_titleBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 15.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_UIBarButtonBinding_titleBinding.h"
#import "AKANumberFormatterPropertyBinding.h"
#import "AKADateFormatterPropertyBinding.h"
#import "AKAAttributedFormatterPropertyBinding.h"
#import "AKATransitionAnimationParametersPropertyBinding.h"


#pragma mark - AKABinding_UIBarButtonBinding_textBinding - Private Interface
#pragma mark -

@interface AKABinding_UIBarButtonBinding_titleBinding () <AKABindingDelegate>

#pragma mark - Saved UILabel State

@property(nonatomic) BOOL isObserving;

#pragma mark - Convenience

@property(nonatomic, readonly) UIBarButtonItem*               barButtonItem;

@end


#pragma mark - AKABinding_UIBarButtonBinding_textBinding - Implementation
#pragma mark -

@implementation AKABinding_UIBarButtonBinding_titleBinding

+ (AKABindingSpecification*)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{
          @"bindingType":          [AKABinding_UIBarButtonBinding_titleBinding class],
          @"targetType":           [UIBarButtonItem class],
          @"expressionType":       @(AKABindingExpressionTypeAny & ~AKABindingExpressionTypeArray),
          @"attributes": @{
                  @"numberFormatter": @{
                          @"bindingType":    [AKANumberFormatterPropertyBinding class],
                          @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                          },
                  @"dateFormatter": @{
                          @"bindingType":    [AKADateFormatterPropertyBinding class],
                          @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                          },
                  @"formatter": @{
                          @"bindingType":    [AKAFormatterPropertyBinding class],
                          @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                          },
                  @"textForUndefinedValue": @{
                          @"expressionType":  @(AKABindingExpressionTypeString),
                          @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                          },
                  @"textForYes": @{
                          @"expressionType":  @(AKABindingExpressionTypeString),
                          @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                          },
                  @"textForNo": @{
                          @"expressionType":  @(AKABindingExpressionTypeString),
                          @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                          }
                  }
          };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

#pragma mark - Initialization

- (req_AKAProperty)createTargetValuePropertyForTarget:(req_id)view error:(out_NSError __unused)error
{
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UIBarButtonBinding_titleBinding* binding = target;

                return binding.barButtonItem.title;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UIBarButtonBinding_titleBinding* binding = target;
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

                binding.barButtonItem.title = text;
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UIBarButtonBinding_titleBinding* binding = target;

                if (!binding.isObserving)
                {
                    binding.isObserving = YES;
                }

                return binding.isObserving;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UIBarButtonBinding_titleBinding* binding = target;

                if (binding.isObserving)
                {
                    binding.isObserving = NO;
                }

                return !binding.isObserving;
            }];
}

- (UIBarButtonItem*)barButtonItem
{
    id result = self.target;

    NSAssert(result == nil || [result isKindOfClass:[UIBarButtonItem class]], @"Object for %@ is required to be an instance of UILabel", self.class);

    return (UIBarButtonItem*)result;
}

- (void)setFormatter:(NSFormatter*)formatter
{
    NSAssert(formatter == nil || [formatter isKindOfClass:NSFormatter.class], @"bam!");
    _formatter = formatter;
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

#pragma mark - Binding Delegate implementation

- (BOOL)shouldReceiveDelegateMessagesForSubBindings
{
    return YES;
}

- (BOOL)shouldReceiveDelegateMessagesForTransitiveSubBindings
{
    return YES;
}

@end
