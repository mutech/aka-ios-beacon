//
//  UIViewController+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 13.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

#import "UIViewController+AKAIBBindingProperties.h"

@implementation UIViewController (AKAIBBindingProperties)

#pragma mark - Binding Support

- (AKABindingBehavior *)aka_bindingBehaviour
{
    AKABindingBehavior * result = nil;

    for (UIViewController* child in self.childViewControllers)
    {
        if ([child isKindOfClass:[AKABindingBehavior class]])
        {
            result = (id)child;
            break;
        }
    }

    return result;
}

@end
