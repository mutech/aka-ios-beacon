//
//  SegmentedControlViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 26.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "SegmentedControlViewController.h"

@implementation SegmentedControlViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.numberOfSegments = 2;
    self.stringValue = nil;
}

@synthesize numberOfSegments = _numberOfSegments;
- (NSInteger)numberOfSegments
{
    return _numberOfSegments;
}

- (void)setNumberOfSegments:(NSInteger)numberOfSegments
{
    NSArray* oneToTen = @[ @"one", @"two", @"three", @"four", @"five", @"six", @"seven", @"eight", @"nine", @"ten" ];

    if (numberOfSegments >= 2 &&
        numberOfSegments <= oneToTen.count &&
        numberOfSegments != _numberOfSegments)
    {
        _numberOfSegments = numberOfSegments;
        self.stringValues = [oneToTen subarrayWithRange:NSMakeRange(0, numberOfSegments)];
    }
}

@end
