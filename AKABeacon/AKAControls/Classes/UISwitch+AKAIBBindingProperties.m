//
//  UISwitch+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAAssociatedValues;

#import "UISwitch+AKAIBBindingProperties.h"

#import "AKABindingProvider_UISwitch_stateBinding.h"
#import "AKAScalarControl.h"


@implementation UISwitch (AKAIBBindingProperties)

- (NSString*)              stateBinding_aka
{
    AKABindingProvider_UISwitch_stateBinding* provider =
        [AKABindingProvider_UISwitch_stateBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(stateBinding_aka)
                                               inView:self];
}

- (void)                 setStateBinding_aka:(opt_NSString)stateBinding
{
    AKABindingProvider_UISwitch_stateBinding* provider =
        [AKABindingProvider_UISwitch_stateBinding sharedInstance];

    [provider setBindingExpressionText:stateBinding
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
