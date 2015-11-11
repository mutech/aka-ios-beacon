//
//  SliderViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "SliderViewController.h"

@interface SliderViewController()
@end

@implementation SliderViewController

- (void)viewDidLoad
{
    self.minimumValue = 0;
    self.maximumValue = 1.0;
    self.stepValue = .01;
    
    [super viewDidLoad];
}

@end
