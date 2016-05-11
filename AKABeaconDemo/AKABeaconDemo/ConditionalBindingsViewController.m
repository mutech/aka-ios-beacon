//
//  ConditionalBindingsViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 11.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKABeacon;

#import "ConditionalBindingsViewController.h"

@implementation ConditionalBindingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.firstName = @"John";
    self.lastName = @"Doe";

    [AKABindingBehavior addToViewController:self];
}

@end
