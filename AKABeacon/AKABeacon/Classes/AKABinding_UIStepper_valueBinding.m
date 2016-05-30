//
//  AKABinding_UIStepper_valueBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 09.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAProperty.h"
#import "NSObject+AKAAssociatedValues.h"

#import "AKABinding_UIStepper_valueBinding.h"
#import "AKABindingExpression.h"


#pragma mark - AKABinding_UIStepper_valueBinding - Private Interface
#pragma mark -

@interface AKABinding_UIStepper_valueBinding()

/**
 Convenience property accessing self.target as UIStepper.
 */
@property(nonatomic, readonly) UIStepper* uiStepper;

/**
 Records the target value prior to changing it to be able to pass the old value in change notifications.
 */
@property(nonatomic) NSNumber*                          previousValue;

@end


#pragma mark - AKABinding_UIStepper_valueBinding - Implementation
#pragma mark -

@implementation AKABinding_UIStepper_valueBinding

+  (AKABindingSpecification *)            specification
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
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"target.minimumValue"
                         },
                  @"maximumValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"target.maximumValue"
                         },
                  @"stepValue":
                      @{ @"expressionType":  @(AKABindingExpressionTypeNumber),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"target.stepValue"
                         },
                  @"autorepeat":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"target.autorepeat"
                         },
                  @"continuous":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"target.continuous"
                         },
                  @"wraps":
                      @{ @"expressionType":  @(AKABindingExpressionTypeBoolean),
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"target.wraps"
                         },
                  },
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization

- (void)validateTarget:(req_id)target
{
    (void)target;
    NSParameterAssert([target isKindOfClass:[UIStepper class]]);
}

#pragma mark - Binding Target

- (req_AKAProperty)createBindingTargetPropertyForTarget:(req_id)view
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

- (UIStepper *)                               uiStepper
{
    UIView* result = self.target;
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

    // Trigger change notifications for targetValueProperty (for the case that someone
    // created a depedendant property based on the binding target). Stepper value may have
    // been changed above, so we query it again here:
    newValue = @(self.uiStepper.value);
    if (newValue != oldValue)
    {
        [self.targetValueProperty notifyPropertyValueDidChangeFrom:oldValue to:newValue];
    }
}

@end
