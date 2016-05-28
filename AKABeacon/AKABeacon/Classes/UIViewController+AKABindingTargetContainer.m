//
//  UIViewController+AKABindingTargetContainer.m
//  AKABeacon
//
//  Created by Michael Utech on 22.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIViewController+AKABindingTargetContainer.h"

@implementation UIViewController (AKABindingTargetContainer)

- (void)aka_enumeratePotentialBindingTargetsUsingBlock:(void(^)(req_id  bindingTarget,
                                                                outreq_BOOL stop))block
{
    BOOL stop = NO;
    block(self.view, &stop);
}

@end
