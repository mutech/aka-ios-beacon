//
//  UIView+AKABindingTargetContainer.m
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIView+AKABindingTargetContainer.h"


@implementation UIView(AKABindingTargetContainer)

- (void)aka_enumeratePotentialBindingTargetsUsingBlock:(void(^)(req_id  bindingTarget,
                                                                outreq_BOOL stop))block
{
    __block BOOL stop = NO;
    [self.subviews enumerateObjectsUsingBlock:
     ^(__kindof UIView * _Nonnull view, NSUInteger idx __unused, BOOL * _Nonnull stopEnumeratingSubviews)
     {
         block(view, &stop);
         if (stop)
         {
             *stopEnumeratingSubviews = stop;
         }
     }];
}

@end
