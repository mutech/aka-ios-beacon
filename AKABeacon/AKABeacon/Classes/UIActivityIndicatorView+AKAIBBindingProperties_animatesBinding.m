//
//  UIActivityIndicatorView+AKAIBBindingProperties_animatesBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 14/10/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIActivityIndicatorView+AKAIBBindingProperties_animatesBinding.h"
#import "AKABinding_UIActivityIndicatorView_animatesBinding.h"
#import "AKABinding+IBPropertySupport.h"


@implementation UIActivityIndicatorView (AKAIBBindingProperties_animatesBinding)

#pragma mark - Interface Builder Properties

- (NSString*)                             animatesBinding_aka
{
    return [AKABinding_UIActivityIndicatorView_animatesBinding bindingExpressionTextForSelector:@selector(animatesBinding_aka)
                                                                          inView:self];
}

- (void)                               setAnimatesBinding_aka:(opt_NSString)enabledBinding
{
    [AKABinding_UIActivityIndicatorView_animatesBinding setBindingExpressionText:enabledBinding
                                                      forSelector:@selector(animatesBinding_aka)
                                                           inView:self];
}

@end
