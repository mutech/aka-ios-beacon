//
//  UIToolbar+AKABindingTargetContainer.m
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIToolbar+AKABindingTargetContainer.h"

@implementation UIToolbar(AKABindingTargetContainer)

- (void)aka_enumeratePotentialBindingTargetsUsingBlock:(void(^)(req_id  bindingTarget,
                                                                outreq_BOOL stop))block
{
    [self.items enumerateObjectsUsingBlock:
     ^(UIBarButtonItem * _Nonnull barButtonItem, NSUInteger idx __unused, BOOL * _Nonnull stop)
     {
         BOOL localStop = NO;

         block(barButtonItem, &localStop);
         if (!localStop && barButtonItem.customView)
         {
             block(barButtonItem.customView, &localStop);
         }
         if (localStop)
         {
             *stop = YES;
         }
     }];
}

@end
