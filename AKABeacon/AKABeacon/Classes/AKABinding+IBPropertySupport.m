//
//  AKAViewBinding+IBPropertySupport.m
//  AKABeacon
//
//  Created by Michael Utech on 24.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding+IBPropertySupport.h"
#import "AKABindingExpression+Accessors.h"
#import "UIViewController+AKAIBBindingProperties.h"

@implementation AKABinding (IBPropertySupport)

#pragma mark - Interface Builder Property Support

+ (NSString*)       bindingExpressionTextForSelector:(SEL)selector
                                              inView:(req_id)view
{
    AKABindingExpression* expression = [AKABindingExpression bindingExpressionForTarget:view
                                                                               property:selector];
    NSAssert(expression == nil || expression.specification.bindingType == self.class,
             @"Binding expression %@.%@ was created for binding type %@ and cannot be used by bindings of type %@",
             view, NSStringFromSelector(selector), expression.specification.bindingType, self.class);

    return expression.text;
}

+ (void)                     setBindingExpressionText:(opt_NSString)bindingExpressionText
                                          forSelector:(req_SEL)selector
                                               inView:(req_id)view
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

        [AKABindingExpression setBindingExpression:bindingExpression forTarget:view property:selector];
    }
}

@end
