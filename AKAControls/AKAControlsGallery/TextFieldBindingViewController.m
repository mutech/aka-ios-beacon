//
//  TextFieldBindingViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 23.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKABeacon;

#import "TextFieldBindingViewController.h"

@interface TextFieldBindingViewController ()

@property(nonatomic) NSString* stringValue;
@property(nonatomic) NSNumber* numberValue;
@property(nonatomic) NSDate* dateValue;

@property (weak, nonatomic) IBOutlet UITextField *textField1;

@end

@implementation TextFieldBindingViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.stringValue = @"Initial value";
    self.numberValue = @(-12345.6789);
    self.dateValue = [NSDate new];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.formControl stopObservingChanges];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
