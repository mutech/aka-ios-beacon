//
//  AKABinding_UISwitch_stateBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding_UISwitch_stateBinding.h"


#pragma mark - AKABinding_UISwitch_stateBinding - Private Interface
#pragma mark -

@interface AKABinding_UISwitch_stateBinding() <UITextFieldDelegate>

#pragma mark - Convenience

@property(nonatomic, readonly) UISwitch*          uiSwitch;

@end


#pragma mark - AKABinding_UISwitch_stateBinding - Implementation
#pragma mark -

@implementation AKABinding_UISwitch_stateBinding

+ (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UISwitch_stateBinding class],
           @"targetType":               [UISwitch class],
           @"expressionType":           @(AKABindingExpressionTypeAny & ~AKABindingExpressionTypeArray)
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization

- (void)validateTarget:(req_id)target
{
    (void)target;
    NSParameterAssert([target isKindOfClass:[UISwitch class]]);
}

#pragma mark - Binding Target

- (req_AKAProperty)createBindingTargetPropertyForTarget:(req_id)view
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UISwitch class]]);
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UISwitch_stateBinding* binding = target;
                return [binding canonicalBool:binding.uiSwitch.on];
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UISwitch_stateBinding* binding = target;
                if ([value isKindOfClass:[NSNumber class]])
                {
                    binding.uiSwitch.on = ((NSNumber*)value).boolValue;
                }
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UISwitch_stateBinding* binding = target;
                BOOL result = binding.uiSwitch != nil;
                if (result)
                {
                    [binding.uiSwitch addTarget:binding
                                         action:@selector(targetValueDidChangeSender:)
                               forControlEvents:UIControlEventValueChanged];
                }
                return result;
            }
                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UISwitch_stateBinding* binding = target;
                BOOL result = binding.uiSwitch != nil;
                if (result)
                {
                    [binding.uiSwitch removeTarget:binding
                                         action:@selector(targetValueDidChangeSender:)
                               forControlEvents:UIControlEventValueChanged];
                }
                return result;
            }];
}

#pragma mark - Properties

- (UISwitch *)uiSwitch
{
    UIView* result = self.target;
    NSParameterAssert(result == nil || [result isKindOfClass:[UISwitch class]]);

    return (UISwitch*)result;
}

#pragma mark - Change Observation

- (NSNumber*)                                canonicalBool:(BOOL)value
{
    NSNumber* kYes = (__bridge NSNumber*)kCFBooleanTrue;
    NSNumber* kNo  = (__bridge NSNumber*)kCFBooleanFalse;

    return value ? kYes : kNo;
}

- (NSNumber*)                             canonicalBoolean:(NSNumber*)value
{
    if (value == nil || value == (id)[NSNull null])
    {
        return nil;
    }
    else
    {
        return [self canonicalBool:value.boolValue];
    }
}

- (void)                        targetValueDidChangeSender:(id)sender
{
    (void)sender; // Not used

    NSNumber* newValue = [self canonicalBool:self.uiSwitch.on];
    NSNumber* oldValue = [self canonicalBool:!newValue];

    // Process change
    [self targetValueDidChangeFromOldValue:oldValue
                                toNewValue:newValue];

    // Trigger change notifications for targetValueProperty (for the case that someone
    // created a depedendant property based on the binding target).
    newValue = [self canonicalBool:self.uiSwitch.on]; // the delegate may change the value
    if (newValue.boolValue != oldValue.boolValue)
    {
        [self.targetValueProperty notifyPropertyValueDidChangeFrom:oldValue to:newValue];
    }
}

@end
