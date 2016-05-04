//
//  DynamicSectionsTableViewBindingViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 03.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//


@import AKABeacon;
#import "DynamicSectionsTableViewBindingViewController.h"

@implementation DynamicSectionsTableViewBindingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [AKABindingBehavior addToViewController:self];

    self.sections =
    @[ @{ @"headerTitle": @"Section One",
          @"rows": @[ @"One-1", @"One-2" ]
          },
       @{ @"headerTitle": @"Section Two",
          @"rows": @[ @(1), @(2) ]
          },
       @{ @"headerTitle": @"Section Three",
          @"rows": @[ @"Three-1", @"Three-2", @"Three-3" ]
          },
       ];
}

@end
