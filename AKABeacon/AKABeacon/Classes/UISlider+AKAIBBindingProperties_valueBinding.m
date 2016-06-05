//
//  UISlider+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "NSObject+AKAAssociatedValues.h"

#import "UISlider+AKAIBBindingProperties_valueBinding.h"

#import "AKABinding_UISlider_valueBinding.h"
#import "AKABinding+IBPropertySupport.h"
#import "AKAControlConfiguration.h"
#import "AKAScalarControl.h"

@implementation UISlider (AKAIBBindingProperties_valueBinding)

- (NSString*)              valueBinding_aka
{
    return [AKABinding_UISlider_valueBinding bindingExpressionTextForSelector:@selector(valueBinding_aka)
                                                                       inView:self];
}

- (void)                 setValueBinding_aka:(opt_NSString)valueBinding
{
    [AKABinding_UISlider_valueBinding setBindingExpressionText:valueBinding
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
