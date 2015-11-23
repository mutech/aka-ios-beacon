//
//  AKAViewBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;

#import "AKAViewBinding.h"
#import "UIView+AKABindingSupport.h"


@implementation AKAViewBinding

#pragma mark - Initialization

- (instancetype)                initWithTarget:(req_id)target
                                      property:(opt_SEL)property
                                    expression:(req_AKABindingExpression)bindingExpression
                                       context:(req_AKABindingContext)bindingContext
                                      delegate:(opt_AKABindingDelegate)delegate
                                         error:(out_NSError)error
{
    [self validateTargetView:target];

    if (self = [super initWithTarget:[self createBindingTargetPropertyForView:target]
                            property:property
                      expression:bindingExpression
                         context:bindingContext
                        delegate:delegate
                           error:error])
    {
        _view = target;
    }

    return self;
}

- (void)validateTargetView:(req_UIView)targetView
{
    (void)targetView;
    NSParameterAssert([targetView isKindOfClass:[UIView class]]);
}


- (req_AKAProperty)createBindingTargetPropertyForView:(req_UIView)target
{
    (void)target;
    AKAErrorAbstractMethodImplementationMissing();
}

@end


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