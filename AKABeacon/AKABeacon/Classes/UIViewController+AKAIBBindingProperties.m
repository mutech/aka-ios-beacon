//
//  UIViewController+AKAIBBindingProperties.m
//  AKABeacon
//
//  Created by Michael Utech on 13.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIViewController+AKAIBBindingProperties.h"

@implementation UIViewController (AKAIBBindingProperties)

#pragma mark - Interface Builder Properties

- (BOOL)aka_bindingsEnabled
{
    return self.aka_bindingBehaviour != nil;
}

- (void)aka_setBindingsEnabled:(BOOL)bindingsEnabled_aka
{
    if (bindingsEnabled_aka)
    {
        if (self.aka_bindingBehaviour == nil)
        {
            self.aka_bindingBehaviour = [AKABindingBehaviourViewController new];
        }
    }
    else
    {
        self.aka_bindingBehaviour = nil;
    }
}

#pragma mark - Binding Support

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
    AKABindingBehaviourViewController* current = self.aka_bindingBehaviour;

    if (current && current != bindingBehaviour)
    {
        [current removeFromViewController:self];
    }

    [bindingBehaviour addToViewController:self];
}

@end
