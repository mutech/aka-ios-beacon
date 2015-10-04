//
//  PickerKeyboardViewController.m
//  AKAControlsGallery
//
//  Created by Michael Utech on 03.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "PickerKeyboardViewController.h"

@import AKAControls;

@interface PickerKeyboardViewController() <AKACustomKeyboardResponderDelegate>

@property(nonatomic) AKAFormControl* formControl;

@property(nonatomic) NSString* stringValue;
@property(nonatomic) NSArray*  stringArrayValue;

@property(nonatomic) id        objectValue;
@property(nonatomic) NSArray*  objectArrayValue;

@end


@implementation PickerKeyboardViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.stringPickerTriggerView.delegate = self;
    self.objectPickerTriggerView.delegate = self;

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
    self.stringValue = nil;

    self.objectArrayValue = @[ @{ @"title": @"one",   @"value": @( 1) },
                               @{ @"title": @"two",   @"value": @( 2) },
                               @{ @"title": @"three", @"value": @( 3) },
                               @{ @"title": @"four",  @"value": @( 4) },
                               @{ @"title": @"five",  @"value": @( 5) },
                               @{ @"title": @"six",   @"value": @( 6) },
                               @{ @"title": @"seven", @"value": @( 7) },
                               @{ @"title": @"eight", @"value": @( 8) },
                               @{ @"title": @"nine",  @"value": @( 9) },
                               @{ @"title": @"ten",   @"value": @(10) },
                               ];
    self.objectValue = [self.objectArrayValue objectAtIndex:4];

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

#pragma mark - ...

- (void)customKeyboardResponderViewDidBecomeFirstResponder:(AKACustomKeyboardResponderView *)view
{
    // Just a crude example how the delegate can be used to highlight the view when it becomes
    // first responder:
    view.layer.cornerRadius = 2;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [UIColor blueColor].CGColor;
    view.layer.borderWidth = 1.0;
}

- (void)customKeyboardResponderViewDidResignFirstResponder:(AKACustomKeyboardResponderView *)view
{
    view.layer.cornerRadius = 0;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [UIColor clearColor].CGColor;
    view.layer.borderWidth = 0.0;
}

@end
