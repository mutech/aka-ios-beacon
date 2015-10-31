//
//  UISlider+AKAIBBindingProperties.m
//  AKAControls
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAAssociatedValues;

#import "UISlider+AKAIBBindingProperties.h"
#import "AKABindingProvider_UISlider_valueBinding.h"
#import "AKAControlConfiguration.h"
#import "AKAScalarControl.h"

@implementation UISlider (AKAIBBindingProperties)

- (NSString*)              valueBinding_aka
{
    AKABindingProvider_UISlider_valueBinding* provider =
        [AKABindingProvider_UISlider_valueBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(valueBinding_aka)
                                               inView:self];
}

- (void)                 setValueBinding_aka:(opt_NSString)valueBinding
{
    AKABindingProvider_UISlider_valueBinding* provider =
        [AKABindingProvider_UISlider_valueBinding sharedInstance];

    [provider setBindingExpressionText:valueBinding
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
