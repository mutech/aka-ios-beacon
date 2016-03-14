//
//  TextFieldBindingViewController.h
//  AKABeaconDemo
//
//  Created by Michael Utech on 23.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKABeacon;

@interface TextFieldBindingViewController : UIViewController

#pragma mark - Outlets

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

#pragma mark - View Model

@property(nonatomic) NSString* stringValue;
@property(nonatomic) NSNumber* numberValue;
@property(nonatomic) NSDate* dateValue;

@end
