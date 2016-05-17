//
//  UISwitch+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "NSObject+AKAAssociatedValues.h"

#import "UISwitch+AKAIBBindingProperties.h"

#import "AKABinding_UISwitch_stateBinding.h"
#import "AKAViewBinding+IBPropertySupport.h"
#import "AKAScalarControl.h"


@implementation UISwitch (AKAIBBindingProperties)

- (NSString*)              stateBinding_aka
{
    return [AKABinding_UISwitch_stateBinding bindingExpressionTextForSelector:@selector(stateBinding_aka)
                                                                       inView:self];
}

- (void)                 setStateBinding_aka:(opt_NSString)stateBinding
{
    [AKABinding_UISwitch_stateBinding setBindingExpressionText:stateBinding
                                                   forSelector:@selector(stateBinding_aka)
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
        result[kAKAControlViewBinding] = NSStringFromSelector(@selector(stateBinding_aka));
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
