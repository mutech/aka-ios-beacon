//
//  UIView+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 15.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIView+AKAIBBindingProperties.h"

#import "AKABinding_UIView_styleBinding.h"
#import "AKAViewBinding+IBPropertySupport.h"

@implementation UIView (AKAIBBindingProperties)

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

@end
