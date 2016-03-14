//
//  TextFieldBindingViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 23.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKABeacon;
#import "TextFieldBindingViewController.h"


@implementation TextFieldBindingViewController

- (id)valueForUndefinedKey:(NSString *)key
{
    return [super valueForUndefinedKey:key];
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.stringValue = @"Initial value";
    self.numberValue = @(-4999.995);
    self.dateValue = [NSDate new];

    [self aka_enableBindingSupport];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    NSString* message = [NSString stringWithFormat:@"stringValue: \"%@\"\nnumberValue: %@\ndateValue: %@\n",
                         self.stringValue, self.numberValue, self.dateValue];
    UIAlertController* alertController =
        [UIAlertController alertControllerWithTitle:@"Editing results"
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self.navigationController popViewControllerAnimated:YES];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
