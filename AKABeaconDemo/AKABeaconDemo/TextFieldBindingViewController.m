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
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField3;

@end

@implementation TextFieldBindingViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.stringValue = @"Initial value";
    self.numberValue = @(-4999.995);
    self.dateValue = [NSDate new];
}

#pragma mark - Actions

- (IBAction)showTextField1Binding:(id)sender
{
    [self showBindingExpressionText:self.textField1.textBinding_aka];
}

- (IBAction)showTextField2Binding:(id)sender
{
    [self showBindingExpressionText:self.textField2.textBinding_aka];
}

- (IBAction)showTextField3Binding:(id)sender
{
    [self showBindingExpressionText:self.textField3.textBinding_aka];
}

- (void)showBindingExpressionText:(NSString*)text {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Binding Expression"
                                                                   message:text preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
