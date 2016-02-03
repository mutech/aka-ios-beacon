//
//  SliderViewController.h
//  AKABeaconDemo
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKABeacon.AKAFormViewController;


@interface SliderViewController : AKAFormViewController

@property(nonatomic) double numberValue;
@property(nonatomic) double minimumValue;
@property(nonatomic) double maximumValue;
@property(nonatomic) double stepValue;
@property(nonatomic) BOOL autorepeat;
@property(nonatomic) BOOL continuous;
@property(nonatomic) BOOL wraps;

@end
