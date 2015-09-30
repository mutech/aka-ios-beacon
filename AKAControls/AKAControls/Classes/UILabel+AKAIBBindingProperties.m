//
//  UILabel+AKAIBBindingProperties.m
//  AKAControls
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "UILabel+AKAIBBindingProperties.h"
#import "AKABindingProvider_UILabel_textBinding.h"

@implementation UILabel (AKAIBBindingProperties)

- (NSString *)              textBinding
{
    AKABindingProvider_UILabel_textBinding* provider =
        [AKABindingProvider_UILabel_textBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(textBinding)
                                               inView:self];
}

- (void)                 setTextBinding:(opt_NSString)textBinding
{
    AKABindingProvider_UILabel_textBinding* provider =
        [AKABindingProvider_UILabel_textBinding sharedInstance];

    [provider setBindingExpressionText:textBinding
                           forSelector:@selector(textBinding)
                                inView:self];
}

@end
