//
//  AKABindingController_Internal.h
//  AKABeacon
//
//  Created by Michael Utech on 24.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController.h"
#import "AKAKeyboardActivationSequence.h"

@interface AKABindingController()

#pragma mark - Initialization

- (opt_instancetype)                initWithParent:(opt_AKABindingController)parent
                             targetObjectHierarchy:(req_id)targetObjectHierarchy
                                       dataContext:(opt_id)dataContext
                                          delegate:(opt_AKABindingControllerDelegate)delegate
                                             error:(out_NSError)error;

@end


