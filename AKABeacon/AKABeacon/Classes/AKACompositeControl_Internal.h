//
//  AKACompositeControl_Internal.h
//  AKABeacon
//
//  Created by Michael Utech on 19.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAControl.h"
#import "AKACompositeControl.h"

@interface AKACompositeControl (Internal)

/**
 * Called by createControlForView:withConfiguration: after a composite control has been
 * created. This can be overwritten by subclasses to prevent a composite control from
 * traversing its view hierarchy to add controls.
 *
 * @return the number of controls added.
 */
- (NSUInteger)autoAddControlsForBoundView;

@end
