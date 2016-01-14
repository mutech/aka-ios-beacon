//
//  AKABinding_UILabel_textBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 15.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKABinding_UILabel_textBinding.h"
#import "AKABinding_AKABinding_formatter.h"
#import "AKABinding_AKABinding_numberFormatter.h"
#import "AKABinding_AKABinding_dateFormatter.h"
#import "AKABinding_AKABinding_attributedFormatter.h"

#pragma mark - AKABinding_UILabel_textBinding - Private Interface
#pragma mark -

@interface AKABinding_UILabel_textBinding () <UITextFieldDelegate, AKABindingDelegate>

#pragma mark - Saved UILabel State

@property(nonatomic) BOOL isObserving;

#pragma mark - Convenience

@property(nonatomic, readonly) UILabel*               label;

@end


#pragma mark - AKABinding_UILabel_textBinding - Implementation
#pragma mark -

@implementation AKABinding_UILabel_textBinding

+ (AKABindingSpecification*)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec = @{
            @"bindingType":          [AKABinding_UILabel_textBinding class],
            @"targetType":           [UILabel class],
            @"expressionType":       @(AKABindingExpressionTypeAny & ~AKABindingExpressionTypeArray),
            @"attributes": @{
                @"numberFormatter": @{
                    @"bindingType":    [AKABinding_AKABinding_numberFormatter class],
                    @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty": @"numberFormatter"
                },
                @"dateFormatter": @{
                    @"bindingType":    [AKABinding_AKABinding_dateFormatter class],
                    @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty": @"dateFormatter"
                },
                @"formatter": @{
                    @"bindingType":    [AKABinding_AKABinding_formatter class],
                    @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty": @"formatter"
                },
                @"textAttributeFormatter": @{
                    @"expressionType":  @(AKABindingExpressionTypeNone | AKABindingExpressionTypeAnyKeyPath),
                    @"bindingType":     [AKABinding_AKABinding_attributedFormatter class],
                    @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                    @"bindingProperty": @"textAttributeFormatter"
                },
                @"textForUndefinedValue": @{
                    @"expressionType":  @(AKABindingExpressionTypeString),
                    @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                    @"bindingProperty": @"textForUndefinedValue"
                },
                @"textForYes": @{
                    @"expressionType":  @(AKABindingExpressionTypeString),
                    @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                    @"bindingProperty": @"textForYes"
                },
                @"textForNo": @{
                    @"expressionType":  @(AKABindingExpressionTypeString),
                    @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                    @"bindingProperty": @"textForNo"
                }
            }
        };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

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
                if (binding.textAttributeFormatter)
                {
                    [binding applyTextAttributesToLabelText];
                }
            }
            observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UILabel_textBinding* binding = target;

                if (!binding.isObserving)
                {
                    binding.isObserving = YES;
                }

                return binding.isObserving;
            }
            observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UILabel_textBinding* binding = target;

                if (binding.isObserving)
                {
                    binding.isObserving = NO;
                }

                return !binding.isObserving;
            }];
}

- (void)applyTextAttributesToLabelText
{
    if (self.label.text)
    {
        self.label.attributedText =
            [self.textAttributeFormatter attributedStringForObjectValue:(req_NSString)self.label.text
                                                  withDefaultAttributes:nil];
    }
}

- (UILabel*)label
{
    UIView* result = self.view;

    NSAssert(result == nil || [result isKindOfClass:[UILabel class]], @"View for %@ is required to be an instance of UILabel", self.class);

    return (UILabel*)result;
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

- (void)binding:(req_AKABinding)binding didUpdateTargetValue:(id)oldTargetValue to:(id)newTargetValue
{
    // TODO: this is a bit crude, check if there is a more elegant way to do this:
    // Update target value if the attribute formatter or its pattern changes (f.e. a search pattern)
    if (self.textAttributeFormatter)
    {
        if (binding.bindingTarget.value == self.textAttributeFormatter ||
            binding.bindingTarget.value == self.textAttributeFormatter.pattern)
        {
            [self aka_performBlockInMainThreadOrQueue:^{
                [self applyTextAttributesToLabelText];
            } waitForCompletion:NO];
        }
    }

    id<AKABindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:didUpdateTargetValue:to:)])
    {
        [delegate binding:binding didUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
}

@end
