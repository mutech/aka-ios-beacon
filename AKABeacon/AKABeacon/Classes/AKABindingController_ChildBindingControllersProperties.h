//
//  AKABindingController_ChildBindingControllersProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"

@interface AKABindingController()

@property(nonatomic) NSHashTable<AKABindingController*>*    childBindingControllers;

/**
 This is used during beginUpdatingChildBindingControllers and endUpdatingChildBindingControllers to
 ensure that the order of createOrReuse and remove calls is not relevant (needed for table views and
 probably other UIKit complex views.
 */
@property(nonatomic) NSHashTable<AKABindingController*>*    updatedChildBindingControllers;

@property(nonatomic) NSHashTable<AKABindingController*>*    recycledChildBindingControllers;


@end

