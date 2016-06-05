//
//  UIView+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 15.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIView+AKAIBBindingProperties_gesturesBinding.h"

#import "AKABinding_UIView_gesturesBinding.h"

#import "AKABinding+IBPropertySupport.h"

@implementation UIView (AKAIBBindingProperties_gesturesBinding)

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
