//
//  UITextField+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKANullability.h"
#import "NSObject+AKAAssociatedValues.h"

#import "UITextField+AKAIBBindingProperties_textBinding.h"

#import "AKABinding_UITextField_textBinding.h"

#import "AKAViewBinding+IBPropertySupport.h"
#import "AKAKeyboardControl.h"


@implementation UITextField(AKAIBBindingProperties_textBinding)

- (NSString *)              textBinding_aka
{
    return [AKABinding_UITextField_textBinding bindingExpressionTextForSelector:@selector(textBinding_aka)
                                                                         inView:self];
}

- (void)                 setTextBinding_aka:(opt_NSString)textBinding_aka
{
    [AKABinding_UITextField_textBinding setBindingExpressionText:textBinding_aka
                                                     forSelector:@selector(textBinding_aka)
                                                          inView:self];
}

#pragma mark - Obsolete

- (AKAMutableControlConfiguration*)aka_controlConfiguration
{

    NSString* key = NSStringFromSelector(@selector(aka_controlConfiguration));
    AKAMutableControlConfiguration* result = [self aka_associatedValueForKey:key];
    if (result == nil)
    {
        result = [AKAMutableControlConfiguration new];
        result[kAKAControlTypeKey] = [AKAKeyboardControl class];
        result[kAKAControlViewBinding] = NSStringFromSelector(@selector(textBinding_aka));
        [self aka_setAssociatedValue:result forKey:key];
    }
    return result;
}

- (void)aka_setControlConfigurationValue:(id)value forKey:(NSString *)key
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

