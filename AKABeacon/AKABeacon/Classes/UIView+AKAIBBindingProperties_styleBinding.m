//
//  UIView+AKAIBBindingProperties_styleBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIView+AKAIBBindingProperties_styleBinding.h"
#import "AKABinding_UIView_styleBinding.h"

#import "AKAViewBinding+IBPropertySupport.h"

@implementation UIView (AKAIBBindingProperties_styleBinding)

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
