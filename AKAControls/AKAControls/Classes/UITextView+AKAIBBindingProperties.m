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

- (NSString *)textBinding_aka
{
    AKABindingProvider_UITextView_textBinding* provider =
    [AKABindingProvider_UITextView_textBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(textBinding_aka)
                                               inView:self];
}

- (void)                 setTextBinding_aka:(opt_NSString)textBinding_aka
{
    AKABindingProvider_UITextView_textBinding* provider =
    [AKABindingProvider_UITextView_textBinding sharedInstance];

    [provider setBindingExpressionText:textBinding_aka
                           forSelector:@selector(textBinding_aka)
                                inView:self];
}

@end
