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

- (NSString *)textBinding_aka
{
    AKABindingProvider_UILabel_textBinding* provider =
        [AKABindingProvider_UILabel_textBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(textBinding_aka)
                                               inView:self];
}

- (void)                 setTextBinding_aka:(opt_NSString)textBinding_aka
{
    AKABindingProvider_UILabel_textBinding* provider =
        [AKABindingProvider_UILabel_textBinding sharedInstance];

    [provider setBindingExpressionText:textBinding_aka
                           forSelector:@selector(textBinding_aka)
                                inView:self];
}

@end
