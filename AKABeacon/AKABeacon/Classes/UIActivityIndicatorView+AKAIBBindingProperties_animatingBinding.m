//
//  UIActivityIndicatorView+AKAIBBindingProperties_animatingBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 14/10/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIActivityIndicatorView+AKAIBBindingProperties_animatingBinding.h"
#import "AKABinding_UIActivityIndicatorView_animatingBinding.h"
#import "AKABinding+IBPropertySupport.h"


@implementation UIActivityIndicatorView (AKAIBBindingProperties_animatingBinding)

#pragma mark - Interface Builder Properties

- (NSString*)                             animatingBinding_aka
{
    return [AKABinding_UIActivityIndicatorView_animatingBinding bindingExpressionTextForSelector:@selector(animatingBinding_aka)
                                                                          inView:self];
}

- (void)                               setAnimatingBinding_aka:(opt_NSString)enabledBinding
{
    [AKABinding_UIActivityIndicatorView_animatingBinding setBindingExpressionText:enabledBinding
                                                      forSelector:@selector(animatingBinding_aka)
                                                           inView:self];
}

@end
