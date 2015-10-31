//
//  AKABinding_UISlider_valueBinding.m
//  AKAControls
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding_UISlider_valueBinding.h"

@interface AKABinding_UISlider_valueBinding()

@property(nonatomic) float originalValue;
@property(nonatomic) float originalMinimumValue;
@property(nonatomic) float originalMaximumValue;

@property(nonatomic) float previousValue;

@end

@implementation AKABinding_UISlider_valueBinding

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

    UISlider* slider = (UISlider*)view;
    self.originalValue = self.previousValue = slider.value;
    self.originalMinimumValue = slider.minimumValue;
    self.originalMaximumValue = slider.maximumValue;

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
                    binding.uiSlider.value = self.originalValue;
                    binding.uiSlider.minimumValue = self.originalMinimumValue;
                    binding.uiSlider.maximumValue = self.originalMaximumValue;
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
