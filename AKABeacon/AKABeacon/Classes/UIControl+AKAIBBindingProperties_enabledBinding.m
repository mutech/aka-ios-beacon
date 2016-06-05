//
//  UIControl+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 21.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIControl+AKAIBBindingProperties_enabledBinding.h"
#import "AKABinding_UIControl_enabledBinding.h"
#import "AKABinding+IBPropertySupport.h"


@implementation UIControl (AKAIBBindingProperties_enabledBinding)

#pragma mark - Interface Builder Properties

- (NSString*)                              enabledBinding_aka
{
    return [AKABinding_UIControl_enabledBinding bindingExpressionTextForSelector:@selector(enabledBinding_aka)
                                                                          inView:self];
}

- (void)                                setEnabledBinding_aka:(opt_NSString)enabledBinding
{
    [AKABinding_UIControl_enabledBinding setBindingExpressionText:enabledBinding
                                                      forSelector:@selector(enabledBinding_aka)
                                                           inView:self];
}

@end