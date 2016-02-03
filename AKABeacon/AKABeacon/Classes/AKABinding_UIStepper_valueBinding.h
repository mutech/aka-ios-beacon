//
//  AKABinding_UIStepper_valueBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 09.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAControlViewBinding.h"

@interface AKABinding_UIStepper_valueBinding : AKAControlViewBinding

@property(nonatomic) double                 minimumValue;
@property(nonatomic) double                 maximumValue;
@property(nonatomic) double                 stepValue;
@property(nonatomic) BOOL                   autorepeat;
@property(nonatomic) BOOL                   continuous;
@property(nonatomic) BOOL                   wraps;

@property(nonatomic, readonly) UIStepper*   uiStepper;

@end
