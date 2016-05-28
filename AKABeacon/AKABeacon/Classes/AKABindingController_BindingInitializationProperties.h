//
//  AKABindingController_BindingInitializationProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
@class AKABinding;


@interface AKABindingController ()

/**
 The bindings managed (and owned) by this this controller.

 Please note that this does not include bindings managed by child binding controllers.
 */
@property(nonatomic)                 NSMutableSet<AKABinding*>*             bindings;

@end
