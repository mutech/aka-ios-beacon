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

@interface AKAKeyboardControl : AKAScalarControl

@property(nonatomic, readonly, strong, nullable) AKAKeyboardControlViewBinding* controlViewBinding;

@end


