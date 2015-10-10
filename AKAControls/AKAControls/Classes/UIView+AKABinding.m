//
//  UIView+AKABinding.m
//  AKAControls
//
//  Created by Michael Utech on 31.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "UIView+AKABinding.h"
#import "AKAControl.h"
#import "AKAControlViewProtocol.h"
#import "AKAControlsErrors_Internal.h"

#import <objc/runtime.h>

@implementation UIView (AKABinding)

static const char bindingAssociationKey;

- (AKAObsoleteViewBinding *)aka_binding
{
    id result = objc_getAssociatedObject(self, &bindingAssociationKey);
    NSAssert(result == nil || [result isKindOfClass:[AKAObsoleteViewBinding class]],
             @"Value for associated property '%s' in %@ is not an instance of %@",
             sel_getName(@selector(aka_binding)),
             self,
             NSStringFromClass([AKAObsoleteViewBinding class]));

    return result;
}

- (void)setAka_binding:(AKAObsoleteViewBinding *)binding
{
    AKAObsoleteViewBinding * oldBinding = self.aka_binding;
    if (binding != oldBinding)
    {
        if (YES) //oldBinding == nil && binding.view == self)
        {
            objc_setAssociatedObject(self, &bindingAssociationKey, binding, OBJC_ASSOCIATION_RETAIN); // ASSIGN
            if ([self conformsToProtocol:@protocol(AKAControlViewProtocol)])
            {
                if ([self respondsToSelector:@selector(viewBindingChangedFrom:to:)])
                {
                    [self performSelector:@selector(viewBindingChangedFrom:to:)
                               withObject:oldBinding
                               withObject:binding];
                }
            }
        }
        else
        {
            //[AKAControlsErrors invalidAttemptToBindView:self toBinding:binding];
        }
    }
}

@end
