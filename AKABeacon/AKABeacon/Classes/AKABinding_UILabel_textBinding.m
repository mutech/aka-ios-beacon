//
//  AKABinding_UILabel_textBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 15.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKABinding_Protected.h"
#import "AKABinding_UILabel_textBinding.h"
#import "AKAFormatterPropertyBinding.h"
#import "AKANumberFormatterPropertyBinding.h"
#import "AKADateFormatterPropertyBinding.h"
#import "AKAAttributedFormatterPropertyBinding.h"
#import "AKATransitionAnimationParametersPropertyBinding.h"
#import "AKANSEnumerations.h"


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
                @"textAttributeFormatter": @{
                    @"expressionType":  @(AKABindingExpressionTypeNone | AKABindingExpressionTypeAnyKeyPath),
                    @"bindingType":     [AKAAttributedFormatterPropertyBinding class],
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
                },
                @"transitionAnimation": @{
                    @"bindingType":     [AKATransitionAnimationParametersPropertyBinding class],
                    @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                },
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

                [binding transitionAnimation:^{
                     binding.label.text = text;

                     if (binding.textAttributeFormatter)
                     {
                         [binding applyTextAttributesToLabelText];
                     }
                 }];
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

- (void)transitionAnimation:(void (^)())animations
{
    if (self.transitionAnimation.duration > 0.0)
    {
        [UIView transitionWithView:self.label
                          duration:self.transitionAnimation.duration
                           options:self.transitionAnimation.options
                        animations:^{
             self->_isTransitionAnimationActive = YES;

             if (animations != NULL)
             {
                 animations();
             }
         }
                        completion:^(BOOL finished) {
             // We ignore finished, since we can't know when the animation
             // is really finished if it is not yet when the handler is
             // called. (What's this completion for if it's not for the
             // completion of the animation??)
             (void)finished;
             self->_isTransitionAnimationActive = NO;
         }];
    }
    else
    {
        if (animations != NULL)
        {
            animations();
        }
    }
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
             }
                                    waitForCompletion:NO];
        }
    }

    id<AKABindingDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:didUpdateTargetValue:to:)])
    {
        [delegate binding:binding didUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
}

@end
