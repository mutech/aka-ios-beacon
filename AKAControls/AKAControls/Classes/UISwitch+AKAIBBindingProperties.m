//
//  UISwitch+AKAIBBindingProperties.m
//  AKAControls
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "UISwitch+AKAIBBindingProperties.h"

#import "AKABindingProvider_UISwitch_stateBinding.h"


@implementation UISwitch (AKAIBBindingProperties)

- (NSString *)              stateBinding
{
    AKABindingProvider_UISwitch_stateBinding* provider =
    [AKABindingProvider_UISwitch_stateBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(stateBinding)
                                               inView:self];
}

- (void)                 setStateBinding:(opt_NSString)stateBinding
{
    AKABindingProvider_UISwitch_stateBinding* provider =
    [AKABindingProvider_UISwitch_stateBinding sharedInstance];

    [provider setBindingExpressionText:stateBinding
                           forSelector:@selector(stateBinding)
                                inView:self];
}

@end
