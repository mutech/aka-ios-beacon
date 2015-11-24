//
//  AKABinding_UISlider_valueBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding_UISlider_valueBinding.h"

@interface AKABinding_UISlider_valueBinding()


#if RESTORE_BOUND_VIEW_STATE
@property(nonatomic) float originalValue;
@property(nonatomic) float originalMinimumValue;
@property(nonatomic) float originalMaximumValue;
#endif

@property(nonatomic) float previousValue;

@end

@implementation AKABinding_UISlider_valueBinding

+ (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              self,
           @"targetType":               [UISlider class],
           @"expressionType":           @(AKABindingExpressionTypeNumber),
           @"attributes":
               @{ @"minimumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"minimumValue"
                         },
                  @"maximumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"maximumValue"
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization

- (void)validateTargetView:(req_UIView)targetView
{
    (void)targetView;
    NSParameterAssert([targetView isKindOfClass:[UISlider class]]);
}

#pragma mark - Binding Target

- (req_AKAProperty)createBindingTargetPropertyForView:(req_UIView)view
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
#if RESTORE_BOUND_VIEW_STATE
                    self.originalValue = self.previousValue = binding.uiSlider.value;
                    self.originalMinimumValue = binding.uiSlider.minimumValue;
                    self.originalMaximumValue = binding.uiSlider.maximumValue;
#endif
                    
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

#if RESTORE_BOUND_VIEW_STATE
                    binding.uiSlider.value = binding.originalValue;
                    binding.uiSlider.minimumValue = binding.originalMinimumValue;
                    binding.uiSlider.maximumValue = binding.originalMaximumValue;
#endif
                }
                return result;
            }];
}

#pragma mark - Properties

- (UISlider *)uiSlider
{
    UIView* result = self.view;
    NSParameterAssert(result == nil || [result isKindOfClass:[UISlider class]]);

    return (UISlider*)result;
}

#pragma mark - Change Observation

- (void)                        targetValueDidChangeSender:(id)sender
{
    (void)sender; // Not used

    NSNumber* newValue = @(self.uiSlider.value);
    NSNumber* oldValue = @(self.previousValue);
    self.previousValue = newValue.floatValue;

    // Process change
    [self targetValueDidChangeFromOldValue:oldValue
                                toNewValue:newValue];

    // Trigger change notifications for bindingTarget property (for the case that someone
    // created a depedendant property based on the binding target).
    newValue = @(self.uiSlider.value);
    if (newValue != oldValue)
    {
        [self.bindingTarget notifyPropertyValueDidChangeFrom:oldValue to:newValue];
    }
}

@end
