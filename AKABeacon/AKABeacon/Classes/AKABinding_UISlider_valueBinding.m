//
//  AKABinding_UISlider_valueBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding_UISlider_valueBinding.h"


@interface AKABinding_UISlider_valueBinding()

/**
 uiSlider.value is recorded whenever a change is observed to be able to provide the old value to change notification messages.
 */
@property(nonatomic) float previousValue;

@end


@implementation AKABinding_UISlider_valueBinding

#pragma mark - Specification

+ (AKABindingSpecification *)                specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UISlider_valueBinding class],
           @"targetType":               [UISlider class],
           @"expressionType":           @(AKABindingExpressionTypeNumber),
           @"attributes":
               @{ @"minimumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"uiSlider.minimumValue"
                         },
                  @"maximumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"uiSlider.maximumValue"
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization - Target Value Property

- (req_AKAProperty)     createTargetValuePropertyForTarget:(req_id)view
                                                     error:(out_NSError __unused)error
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UISlider class]]);

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UISlider_valueBinding* binding = target;
                return @(binding.uiSlider.value);
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UISlider_valueBinding* binding = target;
                if ([value isKindOfClass:[NSNumber class]])
                {
                    binding.uiSlider.value = ((NSNumber*)value).floatValue;
                }
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UISlider_valueBinding* binding = target;
                BOOL result = binding.uiSlider != nil;
                if (result)
                {
                    [binding.uiSlider addTarget:binding
                                         action:@selector(targetValueDidChangeSender:)
                               forControlEvents:UIControlEventValueChanged];
                }
                return result;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UISlider_valueBinding* binding = target;
                BOOL result = binding.uiSlider != nil;
                if (result)
                {
                    [binding.uiSlider removeTarget:binding
                                            action:@selector(targetValueDidChangeSender:)
                                  forControlEvents:UIControlEventValueChanged];
                }
                return result;
            }];
}

#pragma mark - Properties

- (UISlider *)                                    uiSlider
{
    UIView* result = self.target;
    NSParameterAssert(result == nil || [result isKindOfClass:[UISlider class]]);

    return (UISlider*)result;
}

#pragma mark - Change Observation

- (void)                        targetValueDidChangeSender:(id __unused)sender
{
    NSNumber* newValue = @(self.uiSlider.value);
    NSNumber* oldValue = @(self.previousValue);
    self.previousValue = newValue.floatValue;

    // Process change
    [self targetValueDidChangeFromOldValue:oldValue
                                toNewValue:newValue];

    // Trigger change notifications for targetValueProperty  (for the case that someone
    // created a depedendant property based on the binding target).
    newValue = @(self.uiSlider.value);
    if (newValue != oldValue)
    {
        [self.targetValueProperty notifyPropertyValueDidChangeFrom:oldValue
                                                                to:newValue];
    }
}

@end
