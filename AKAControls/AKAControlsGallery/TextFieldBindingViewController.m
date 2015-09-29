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
@property(nonatomic) NSString* modelValue;

@end

@implementation TextFieldBindingViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.modelValue = @"Initial value";

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
