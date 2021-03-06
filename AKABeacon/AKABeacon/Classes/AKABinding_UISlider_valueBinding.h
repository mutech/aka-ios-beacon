//
//  AKABinding_UISlider_valueBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlViewBinding.h"

@interface AKABinding_UISlider_valueBinding : AKAControlViewBinding

@property(nonatomic) NSNumber* minimumValue;
@property(nonatomic) NSNumber* maximumValue;

@property(nonatomic, readonly) UISlider* uiSlider;

@end
