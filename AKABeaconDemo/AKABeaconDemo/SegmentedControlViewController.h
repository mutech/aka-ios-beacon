//
//  SegmentedControlViewController.h
//  AKABeaconDemo
//
//  Created by Michael Utech on 26.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKABeacon;

@interface SegmentedControlViewController : AKAFormViewController

@property(nonatomic) NSArray* stringValues;
@property(nonatomic) NSString* stringValue;
@property(nonatomic) NSInteger numberOfSegments;

@end
