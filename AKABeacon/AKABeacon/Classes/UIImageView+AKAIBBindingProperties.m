//
//  UIImage+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKABeaconNullability.h"
#import "UIImageView+AKAIBBindingProperties.h"
#import "AKABinding_UIImageView_imageBinding.h"
#import "AKAViewBinding+IBPropertySupport.h"


@implementation UIImageView (AKAIBBindingProperties)

- (NSString *)imageBinding_aka
{
    return [AKABinding_UIImageView_imageBinding bindingExpressionTextForSelector:@selector(imageBinding_aka)
                                                                          inView:self];
}

- (void)                 setImageBinding_aka:(opt_NSString)imageBinding_aka
{
    [AKABinding_UIImageView_imageBinding setBindingExpressionText:imageBinding_aka
                                                      forSelector:@selector(imageBinding_aka)
                                                           inView:self];
}

@end
