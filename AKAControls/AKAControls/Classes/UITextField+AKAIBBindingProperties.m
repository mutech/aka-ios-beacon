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

- (NSString *)textBinding_aka
{
    AKABindingProvider_UITextField_textBinding* provider =
        [AKABindingProvider_UITextField_textBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(textBinding_aka)
                                               inView:self];
}

- (void)                 setTextBinding_aka:(opt_NSString)textBinding_aka
{
    AKABindingProvider_UITextField_textBinding* provider =
        [AKABindingProvider_UITextField_textBinding sharedInstance];

    [provider setBindingExpressionText:textBinding_aka
                           forSelector:@selector(textBinding_aka)
                                inView:self];
}

@end

