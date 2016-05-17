//
//  UISegmentedControl+IBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 20.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "NSObject+AKAAssociatedValues.h"

#import "UISegmentedControl+IBBindingProperties.h"
#import "AKABinding_UISegmentedControl_valueBinding.h"
#import "AKAViewBinding+IBPropertySupport.h"
#import "AKAControlConfiguration.h"
#import "AKAScalarControl.h"

@implementation UISegmentedControl (IBBindingProperties)

- (NSString*)              valueBinding_aka
{
    return [AKABinding_UISegmentedControl_valueBinding bindingExpressionTextForSelector:@selector(valueBinding_aka)
                                                                           inView:self];
}

- (void)                setValueBinding_aka:(opt_NSString)pickerBinding
{
    [AKABinding_UISegmentedControl_valueBinding setBindingExpressionText:pickerBinding
                                                       forSelector:@selector(valueBinding_aka)
                                                            inView:self];
}

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

- (void)aka_setControlConfigurationValue:(id)value forKey:(NSString*)key
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
