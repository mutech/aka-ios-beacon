//
//  UITableView+AKABindingTargetContainer.m
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UITableView+AKABindingTargetContainer.h"


@implementation UITableView(AKABindingTargetContainer)

- (void)aka_enumeratePotentialBindingTargetsUsingBlock:(void(^)(req_id  bindingTarget,
                                                                outreq_BOOL stop))block
{
    BOOL stop = NO;

    if (self.tableHeaderView)
    {
        block((req_UIView)self.tableHeaderView, &stop);
    }

    // Please note that data driven views cannot statically be scanned for potential binding targets,
    // data source bindings supporting this will use dynamic bindings to control bindings.

    if (!stop && self.tableFooterView)
    {
        block((req_UIView)self.tableFooterView, &stop);
    }
}

@end
