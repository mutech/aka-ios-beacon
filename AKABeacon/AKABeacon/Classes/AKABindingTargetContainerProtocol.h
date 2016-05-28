//
//  AKABindingTargetContainerProtocol.h
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABeaconNullability.h"

/**
 Implementing classes provide AKABindingController's the means to traverse object graphs (most importantly view hierarchies) to find potential binding targets and create bindings for defined binding expressions.
 
 Beacon implements this protocol in supported UIView classes as categories. Please note that you cannot savely override them in categories. For standard view types, please either sub class them to override their behavior or, if the addition is of general interest, please contribute them to the beacon project.
 */
@protocol AKABindingTargetContainerProtocol

/**
 Enumerates potential binding targets owned or otherwise (directly) referenced from this object. This is used by binding controllers to traverse object graphs and locate binding expressions in order to create appropriate bindings for them.

 An implementation should call the specified block for all potential binding targets. If a potential binding target conforms to AKABindingTargetContainerProtocol, it will recursively be traversed by the binding controller (so the enumeration is not supposed to do a deep traversal).

 @param block bindingTarget is the potential binding target, stop can be assigned YES to instruct the enumeration to stop.
 */
- (void)aka_enumeratePotentialBindingTargetsUsingBlock:(void(^_Nullable)(req_id  bindingTarget,
                                                                         outreq_BOOL stop))block;

@end
