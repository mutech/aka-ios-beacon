//
//  AKAKeyboardControl.h
//  AKABeacon
//
//  Created by Michael Utech on 15.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAScalarControl.h"
#import "AKAKeyboardControlViewBinding.h"

@class AKAKeyboardControl;

/**
 * AKAKeyboardControl is a scalar control managing keyboard control view bindings.
 */
@interface AKAKeyboardControl : AKAScalarControl

@property(nonatomic, readonly, weak, nullable) AKAKeyboardControlViewBinding* controlViewBinding;

@end


