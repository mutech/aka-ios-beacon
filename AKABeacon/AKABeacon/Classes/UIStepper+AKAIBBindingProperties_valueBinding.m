//
//  UIStepper+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 09.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "NSObject+AKAAssociatedValues.h"

#import "UIStepper+AKAIBBindingProperties_valueBinding.h"

#import "AKABinding_UIStepper_valueBinding.h"
#import "AKABinding+IBPropertySupport.h"
#import "AKAControlViewProtocol.h"
#import "AKAScalarControl.h"

@interface UIStepper()
@end

@implementation UIStepper (AKAIBBindingProperties)

#pragma mark - Interface Builder Properties

- (NSString*)                              valueBinding_aka
{
    return [AKABinding_UIStepper_valueBinding bindingExpressionTextForSelector:@selector(valueBinding_aka)
                                                                        inView:self];
}

- (void)                                setValueBinding_aka:(opt_NSString)valueBinding
{
    [AKABinding_UIStepper_valueBinding setBindingExpressionText:valueBinding
                                                    forSelector:@selector(valueBinding_aka)
                                                         inView:self];
}

#pragma mark - Control Configuration

/**
 @see [AKAControlViewProtocol aka_controlConfiguration]

 @return the control configuration
 */
- (AKAMutableControlConfiguration*)aka_controlConfiguration
{
    NSString* key = NSStringFromSelector(@selector(aka_controlConfiguration));
    AKAMutableControlConfiguration* result = [self aka_associatedValueForKey:key];

    if (result == nil)
    {
        result = [AKAMutableControlConfiguration new];
        result[kAKAControlTypeKey] = [AKAScalarControl class];
        result[kAKAControlViewBinding] = NSStringFromSelector(@selector(valueBinding_aka));
        [self aka_setAssociatedValue:result forKey:key];
    }

    return result;
}

/**
 @see [AKAControlViewConfiguration aka_setControlConfigurationValue:forKey:]

 @param value the configuration item's new value
 @param key   the configuration item key
 */
- (void)                   aka_setControlConfigurationValue:(id)value forKey:(NSString*)key
{
    AKAMutableControlConfiguration* mutableConfiguration = (AKAMutableControlConfiguration*)self.aka_controlConfiguration;

    if (value == nil)
    {
        [mutableConfiguration removeObjectForKey:key];
    }
    else
    {
        mutableConfiguration[key] = value;
    }
}

@end
