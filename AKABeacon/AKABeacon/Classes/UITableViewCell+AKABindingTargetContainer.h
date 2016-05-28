//
//  UITableViewCell+AKABindingTargetContainer.h
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIView+AKABindingTargetContainer.h"


@interface UITableViewCell(AKABindingTargetContainer)

/**
 Enumerates potential binding targets owned or otherwise referenced from this object. This is used by binding controllers to traverse object graphs and locate binding expressions in order to create appropriate bindings for them.

 The default implementation enumerates the table view cell's contentView.

 @param block bindingTarget is the potential binding target, stop can be assigned YES to instruct the enumeration to stop.
 */
- (void)aka_enumeratePotentialBindingTargetsUsingBlock:(void(^_Nonnull)(req_id  bindingTarget,
                                                                        outreq_BOOL stop))block;

@end


