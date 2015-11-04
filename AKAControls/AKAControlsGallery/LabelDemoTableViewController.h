//
//  LabelDemoTableViewController.h
//  AKABeaconDemo
//
//  Created by Michael Utech on 03.11.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKABeacon;

@interface LabelDemoTableViewController : AKAFormTableViewController

@property(nonatomic) NSString* textValue;
@property(nonatomic) double floatValue;
@property(nonatomic) NSDate* dateValue;
@property(nonatomic) BOOL boolValue;
@property(nonatomic) NSDictionary* objectValue;

@property(nonatomic) NSFormatter* customFormatter;

@end
