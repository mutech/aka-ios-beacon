//
//  TextFieldBindingViewController.m
//  AKAControlsGallery
//
//  Created by Michael Utech on 23.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKAControls;

#import "TextFieldBindingViewController.h"

@interface TextFieldBindingViewController ()

@property(nonatomic) AKAFormControl* formControl;
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

    self.formControl = [[AKAFormControl alloc] initWithDataContext:self configuration:nil];
    [self.formControl addControlsForControlViewsInViewHierarchy:self.view];
    [self.formControl startObservingChanges];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.formControl stopObservingChanges];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
