//
//  PickerKeyboardViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 03.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKABeacon.AKABindingBehavior;

#import "PickerKeyboardViewController.h"

@implementation PickerKeyboardViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [AKABindingBehavior addToViewController:self];

    self.stringArrayValue = @[ @"one",
                               @"two",
                               @"three",
                               @"four",
                               @"five",
                               @"six",
                               @"seven",
                               @"eight",
                               @"nine",
                               @"ten"
                               ];
    self.stringValue = nil;

    self.objectArrayValue = @[ @{ @"title": @"one",   @"value": @( 1) },
                               @{ @"title": @"two",   @"value": @( 2) },
                               @{ @"title": @"three", @"value": @( 3) },
                               @{ @"title": @"four",  @"value": @( 4) },
                               @{ @"title": @"five",  @"value": @( 5) },
                               @{ @"title": @"six",   @"value": @( 6) },
                               @{ @"title": @"seven", @"value": @( 7) },
                               @{ @"title": @"eight", @"value": @( 8) },
                               @{ @"title": @"nine",  @"value": @( 9) },
                               @{ @"title": @"ten",   @"value": @(10) },
                               ];
    self.objectValue = self.objectArrayValue[4];

    self.dateValue = [NSDate new];

}

@end
