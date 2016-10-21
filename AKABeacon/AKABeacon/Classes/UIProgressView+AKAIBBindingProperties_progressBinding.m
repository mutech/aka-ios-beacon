//
//  UIProgressView+AKAIBBindingProperties_progressBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 21/10/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIProgressView+AKAIBBindingProperties_progressBinding.h"
#import "AKABinding_UIProgressView_progressBinding.h"
#import "AKABinding+IBPropertySupport.h"

@implementation UIProgressView (AKAIBBindingProperties_progressBinding)

- (NSString *)progressBinding_aka
{
    return [AKABinding_UIProgressView_progressBinding bindingExpressionTextForSelector:@selector(progressBinding_aka) inView:self];
}

- (void)setProgressBinding_aka:(NSString *)progressBinding
{
    [AKABinding_UIProgressView_progressBinding setBindingExpressionText:progressBinding
                                                            forSelector:@selector(progressBinding_aka)
                                                                 inView:self];
}

@end
