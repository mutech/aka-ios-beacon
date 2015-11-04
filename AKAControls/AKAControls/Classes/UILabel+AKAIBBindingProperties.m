//
//  UILabel+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "UILabel+AKAIBBindingProperties.h"
#import "AKABindingProvider_UILabel_textBinding.h"

#if TARGET_INTERFACE_BUILDER
#  import "UIView+AKABindingSupport.h"
#endif

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

#if TARGET_INTERFACE_BUILDER
    // In Interface Builder, set the label's text to the best approximization we can get from
    // the binding expression without a binding context. This is only relevant for live rendering
    // in IB and will regrettably not work for UILabels directly (since categories defining IBInspectable
    // properties are apperantly not supported by live rendering), but it will let composite controls
    // creating labels display this text. Better than nothing after all...
    AKABindingExpression* expression = [self aka_bindingExpressionForProperty:@selector(textBinding_aka)];
    if (expression)
    {
        self.text = expression.constantStringValueOrDescription;
    }
#endif
}

@end
