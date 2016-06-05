//
//  AKABindingController+BindingDelegatePropagation.h
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController.h"


#pragma mark - AKABindingController(BindingDelegatePropagation) - Interface
#pragma mark -

/*
 This category implements all AKABindingDelegate (and known subdelegate-) methods and propagates
 them to corresponding AKABindingControllerDelegate messages.
 
 These are send to the controller's delegate as well as to all parent controller delegates in ascending order.
 */

@interface AKABindingController(BindingDelegatePropagation)<AKABindingDelegate>

@end

