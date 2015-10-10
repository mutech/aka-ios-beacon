//
//  UITextView+AKAIBBindingProperties.m
//  AKAControls
//
//  Created by Michael Utech on 09.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "UITextView+AKAIBBindingProperties.h"
#import "AKABindingProvider_UITextView_textBinding.h"

@implementation UITextView (AKAIBBindingProperties)

- (NSString *)              textBinding
{
    AKABindingProvider_UITextView_textBinding* provider =
    [AKABindingProvider_UITextView_textBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(textBinding)
                                               inView:self];
}

- (void)                 setTextBinding:(opt_NSString)textBinding
{
    AKABindingProvider_UITextView_textBinding* provider =
    [AKABindingProvider_UITextView_textBinding sharedInstance];

    [provider setBindingExpressionText:textBinding
                           forSelector:@selector(textBinding)
                                inView:self];
}

@end
