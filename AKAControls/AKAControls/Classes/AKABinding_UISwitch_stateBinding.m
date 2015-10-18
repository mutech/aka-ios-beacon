//
//  AKABinding_UISwitch_stateBinding.m
//  AKAControls
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

#pragma mark - Initialization

- (instancetype _Nullable)                  initWithTarget:(id)target
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
{
    NSParameterAssert([target isKindOfClass:[UISwitch class]]);
    return [self initWithView:(UISwitch*)target
                   expression:bindingExpression
                      context:bindingContext
                     delegate:delegate];
}

- (instancetype)                              initWithView:(req_UISwitch)uiSwitch
                                                expression:(req_AKABindingExpression)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                                  delegate:(opt_AKABindingDelegate)delegate
{
    if (self = [super initWithView:uiSwitch
                        expression:bindingExpression
                           context:bindingContext
                          delegate:delegate])
    {
    }
    return self;
}

- (req_AKAProperty)createBindingTargetPropertyForView:(req_UIView)view
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
                    [self.uiSwitch removeTarget:binding
                                         action:@selector(targetValueDidChangeSender:)
                               forControlEvents:UIControlEventValueChanged];
                }
                return result;
            }];
}

#pragma mark - Properties

- (UISwitch *)uiSwitch
{
    UIView* result = self.view;
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

    // Trigger change notifications for bindingTarget property (for the case that someone
    // created a depedendant property based on the binding target).
    newValue = [self canonicalBool:self.uiSwitch.on]; // the delegate may change the value
    if (newValue.boolValue != oldValue.boolValue)
    {
        [self.bindingTarget notifyPropertyValueDidChangeFrom:oldValue to:newValue];
    }
}

@end
