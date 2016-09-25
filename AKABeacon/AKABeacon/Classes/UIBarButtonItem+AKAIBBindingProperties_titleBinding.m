//
//  UIBarButtonItem+AKAIBBindingProperties_titleBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 15.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIBarButtonItem+AKAIBBindingProperties_titleBinding.h"

#import "AKABinding+IBPropertySupport.h"

#import "AKABinding_UIBarButtonBinding_titleBinding.h"

#if TARGET_INTERFACE_BUILDER
#  import "AKABindingExpression+Accessors.h"
#endif


@implementation UIBarButtonItem (AKAIBBindingProperties_titleBinding)

- (NSString *)titleBinding_aka
{
    return [AKABinding_UIBarButtonBinding_titleBinding bindingExpressionTextForSelector:@selector(titleBinding_aka)
                                                                     inView:self];
}

- (void)                 setTitleBinding_aka:(opt_NSString)titleBinding_aka
{
    [AKABinding_UIBarButtonBinding_titleBinding setBindingExpressionText:titleBinding_aka
                                                 forSelector:@selector(titleBinding_aka)
                                                      inView:self];
#if TARGET_INTERFACE_BUILDER
    if (self.title.length == 0)
    {
        // In Interface Builder, set the label's text to the best approximization we can get from
        // the binding expression without a binding context. This is only relevant for live rendering
        // in IB and will regrettably not work for UILabels directly (since categories defining IBInspectable
        // properties are apperantly not supported by live rendering), but it will let composite controls
        // creating labels display this text. Better than nothing after all...
        AKABindingExpression* expression = [AKABindingExpression bindingExpressionForTarget:self
                                                                                   property:@selector(titleBinding_aka)];
        if (expression)
        {
            self.title = expression.constantStringValueOrDescription;
        }
    }
#endif
}

@end
