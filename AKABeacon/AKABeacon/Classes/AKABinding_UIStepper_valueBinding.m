//
//  AKABinding_UIStepper_valueBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 09.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKAProperty;
@import AKACommons.NSObject_AKAAssociatedValues;

#import "AKABinding_UIStepper_valueBinding.h"
#import "AKABindingExpression.h"

@interface AKABinding_UIStepper_valueBinding()

@property(nonatomic) NSNumber*                          previousValue;

@end

@implementation AKABinding_UIStepper_valueBinding

+  (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UIStepper_valueBinding class],
           @"targetType":               [UIStepper class],
           @"expressionType":           @(AKABindingExpressionTypeNumber),
           @"attributes":
               @{ @"minimumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                         },
                  @"maximumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                         },
                  @"stepValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty)
                         },
                  @"autorepeat":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         },
                  @"continuous":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         },
                  @"wraps":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization

- (void)                             validateTargetView:(req_UIView)targetView
{
    (void)targetView;
    NSParameterAssert([targetView isKindOfClass:[UIStepper class]]);
}

#pragma mark - Binding Target

- (req_AKAProperty)  createBindingTargetPropertyForView:(req_UIView)view
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UIStepper class]]);

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UIStepper_valueBinding* binding = target;
                return @(binding.uiStepper.value);
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UIStepper_valueBinding* binding = target;
                if ([value isKindOfClass:[NSNumber class]])
                {
                    float floatValue = ((NSNumber*)value).floatValue;
                    binding.uiStepper.value = floatValue;
                    NSAssert(binding.uiStepper.value == floatValue, @"Failed to set stepper %@ value to %g", binding.uiStepper, floatValue);
                }
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UIStepper_valueBinding* binding = target;
                BOOL result = binding.uiStepper != nil;
                if (result)
                {
                    [binding.uiStepper addTarget:binding
                                         action:@selector(targetValueDidChangeSender:)
                               forControlEvents:UIControlEventValueChanged];
                }
                return result;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UIStepper_valueBinding* binding = target;
                BOOL result = binding.uiStepper != nil;
                if (result)
                {
                    [binding.uiStepper removeTarget:binding
                                            action:@selector(targetValueDidChangeSender:)
                                  forControlEvents:UIControlEventValueChanged];
                }
                return result;
            }];
}


#pragma mark - Properties

- (double)minimumValue { return self.uiStepper.minimumValue; }
- (double)maximumValue { return self.uiStepper.maximumValue; }
- (double)stepValue { return self.uiStepper.stepValue; }
- (BOOL)autorepeat { return self.uiStepper.autorepeat; }
- (BOOL)continuous { return self.uiStepper.continuous; }
- (BOOL)wraps { return self.uiStepper.wraps; }

- (void)setMinimumValue:(double)minimumValue { self.uiStepper.minimumValue = minimumValue; }
- (void)setMaximumValue:(double)maximumValue { self.uiStepper.maximumValue = maximumValue; }
- (void)setStepValue:(double)stepValue { self.uiStepper.stepValue = stepValue; }
- (void)setAutorepeat:(BOOL)autorepeat { self.uiStepper.autorepeat = autorepeat; }
- (void)setContinuous:(BOOL)continuous { self.uiStepper.continuous = continuous; }
- (void)setWraps:(BOOL)wraps { self.uiStepper.wraps = wraps; }

- (UIStepper *)                               uiStepper
{
    UIView* result = self.view;
    NSParameterAssert(result == nil || [result isKindOfClass:[UIStepper class]]);

    return (UIStepper*)result;
}

#pragma mark - Change Observation

- (void)                     targetValueDidChangeSender:(id)sender
{
    (void)sender; // Not used

    NSNumber* newValue = @(self.uiStepper.value);
    NSNumber* oldValue = self.previousValue;
    self.previousValue = newValue;

    [self targetValueDidChangeFromOldValue:oldValue
                                toNewValue:newValue];

    // Trigger change notifications for bindingTarget property (for the case that someone
    // created a depedendant property based on the binding target). Stepper value may have
    // been changed above, so we query it again here:
    newValue = @(self.uiStepper.value);
    if (newValue != oldValue)
    {
        [self.bindingTarget notifyPropertyValueDidChangeFrom:oldValue to:newValue];
    }
}

@end
