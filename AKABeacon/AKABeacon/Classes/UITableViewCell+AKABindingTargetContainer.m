//
//  UITableViewCell+AKABindingTargetContainer.m
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UITableViewCell+AKABindingTargetContainer.h"


@implementation UITableViewCell(AKABindingTargetContainer)

- (void)aka_enumeratePotentialBindingTargetsUsingBlock:(void(^)(req_id  bindingTarget,
                                                                outreq_BOOL stop))block
{
    BOOL stop = NO;
    block(self.contentView, &stop);
}

@end
