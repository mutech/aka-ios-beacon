//
//  PickerKeyboardViewController.m
//  AKAControlsGallery
//
//  Created by Michael Utech on 03.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "PickerKeyboardViewController.h"

@import AKAControls;

@interface PickerKeyboardViewController()

@property(nonatomic) AKAFormControl* formControl;
@property(nonatomic) NSString* stringValue;
@property(nonatomic) NSArray* stringArrayValue;

@end


@implementation PickerKeyboardViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.stringArrayValue = @[ @"one",
                               @"two",
                               @"three",
                               @"four",
                               @"five",
                               @"six",
                               @"seven",
                               @"eight",
                               @"nine",
                               @"ten"
                               ];
    self.stringValue = [self.stringArrayValue objectAtIndex:4];

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
