//
//  UITextField+AKAIBBindingProperties.m
//  AKAControls
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;
@import AKACommons.AKALog;

#import "UITextField+AKAIBBindingProperties.h"

#import "AKABindingProvider_UITextField_textBinding.h"

@implementation UITextField(AKAIBBindingProperties)

- (NSString *)              textBinding
{
    AKABindingProvider_UITextField_textBinding* provider =
        [AKABindingProvider_UITextField_textBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(textBinding)
                                               inView:self];
}

- (void)                 setTextBinding:(opt_NSString)textBinding
{
    AKABindingProvider_UITextField_textBinding* provider =
        [AKABindingProvider_UITextField_textBinding sharedInstance];

    [provider setBindingExpressionText:textBinding
                           forSelector:@selector(textBinding)
                                inView:self];
}

@end

