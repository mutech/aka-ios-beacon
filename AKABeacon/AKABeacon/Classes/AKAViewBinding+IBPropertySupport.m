//
//  AKAViewBinding+IBPropertySupport.m
//  AKABeacon
//
//  Created by Michael Utech on 24.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAViewBinding+IBPropertySupport.h"


@implementation AKAViewBinding (IBPropertySupport)

#pragma mark - Interface Builder Property Support

+ (NSString*)       bindingExpressionTextForSelector:(SEL)selector
                                              inView:(UIView*)view
{
    AKABindingExpression* expression = [view aka_bindingExpressionForProperty:selector];

    Class bindingType = expression.bindingType;

    NSAssert(bindingType == self.class,
             @"Binding expression %@.%@ was created by a different provider %@",
             view, NSStringFromSelector(selector), bindingType);
    (void)bindingType;

    return expression.text;
}

+ (void)                     setBindingExpressionText:(opt_NSString)bindingExpressionText
                                          forSelector:(req_SEL)selector
                                               inView:(req_UIView)view
{
    NSParameterAssert(selector != nil);
    NSParameterAssert(view != nil);

    NSString* text = [bindingExpressionText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (text.length > 0)
    {
        NSError* error = nil;
        AKABindingExpression* bindingExpression;

        bindingExpression = [AKABindingExpression bindingExpressionWithString:(req_NSString) text
                                                                  bindingType:self.class
                                                                        error:&error];

        if (bindingExpression == nil)
        {
            NSString* message = [NSString stringWithFormat:@"Attempt to set invalid binding expression for property %@ in view %@", NSStringFromSelector(selector), view];

#if TARGET_INTEFACE_BUILDER
            AKALogError(@"%@: %@", message, error.localizedDescription);
#else
            @throw([NSException exceptionWithName:message reason:error.localizedDescription userInfo:nil]);
#endif
        }

        [view aka_setBindingExpression:bindingExpression forProperty:selector];
    }
}

@end
