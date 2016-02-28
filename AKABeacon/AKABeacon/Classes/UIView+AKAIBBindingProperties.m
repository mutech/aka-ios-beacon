//
//  UIView+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 15.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIView+AKAIBBindingProperties.h"

#import "AKABinding_UIView_styleBinding.h"
#import "AKABinding_UIView_gesturesBinding.h"

#import "AKAViewBinding+IBPropertySupport.h"

@implementation UIView (AKAIBBindingProperties)

#pragma mark - Style Binding

- (NSString *)styleBinding_aka
{
    return [self.aka_styleBindingType bindingExpressionTextForSelector:@selector(styleBinding_aka)
                                                                     inView:self];
}

- (void)setStyleBinding_aka:(NSString *)styleBinding_aka
{
    [self.aka_styleBindingType setBindingExpressionText:styleBinding_aka
                                                 forSelector:@selector(styleBinding_aka)
                                                      inView:self];
}

- (Class)aka_styleBindingType
{
    return [AKABinding_UIView_styleBinding class];
}

#pragma mark - Gestures Binding

- (NSString *)gesturesBinding_aka
{
    return [AKABinding_UIView_gesturesBinding bindingExpressionTextForSelector:@selector(gesturesBinding_aka)
                                                                        inView:self];
}

- (void)setGesturesBinding_aka:(NSString *)gesturesBinding_aka
{
    [AKABinding_UIView_gesturesBinding setBindingExpressionText:gesturesBinding_aka
                                                    forSelector:@selector(gesturesBinding_aka)
                                                         inView:self];
}

@end
