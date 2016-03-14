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

- (void)aka_enableBindingSupport;
{
    if (self.aka_bindingBehaviour == nil)
    {
        self.aka_bindingBehaviour = [AKABindingBehaviourViewController new];
    }
}

- (void)aka_disableBindingSupport;
{
    [self.aka_bindingBehaviour removeFromViewController:self];
}

- (AKABindingBehaviourViewController *)aka_bindingBehaviour
{
    AKABindingBehaviourViewController* result = nil;

    for (UIViewController* child in self.childViewControllers)
    {
        if ([child isKindOfClass:[AKABindingBehaviourViewController class]])
        {
            result = (id)child;
            break;
        }
    }

    return result;
}


- (void)aka_setBindingBehaviour:(AKABindingBehaviourViewController *)bindingBehaviour
{
    __block AKABindingBehaviourViewController* newBindingBehavior = bindingBehaviour;
    AKABindingBehaviourViewController* current = self.aka_bindingBehaviour;

    if (current && current != bindingBehaviour)
    {
        [current removeFromViewController:self];
    }

    [newBindingBehavior addToViewController:self];
}

@end
