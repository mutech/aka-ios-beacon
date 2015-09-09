//
//  AKAFormTableViewControllerDemo.m
//  AKAControlsDemo
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAFormTableViewControllerDemo.h"
#import <AKAControls/AKAControlDelegate.h>
#import <AKAControls/AKATextLabel.h>
#import <AKAControls/UIView+AKABinding.h>

@interface AKAFormTableViewControllerDemo () <AKAControlDelegate>

@property(nonatomic) BOOL showPersonalInformation;
@property(nonatomic) BOOL showPersonalInformation2;

@property (weak, nonatomic) IBOutlet AKATextLabel *modelValueLabel;

@end

@implementation AKAFormTableViewControllerDemo

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _showPersonalInformation = YES;
    self.model = [NSMutableDictionary dictionaryWithDictionary:
                  @{ @"name": @"AKA Sarl",
                     @"phone": @"+1-234-5678",
                     @"email": @"info@demo.org",
                     @"number": @(123.45)
                     }];
    self.formControl.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0f;
}

#pragma mark - ViewModel

- (void)setShowPersonalInformation:(BOOL)showPersonalInformation
{
    if (self.showPersonalInformation != showPersonalInformation)
    {
        _showPersonalInformation = showPersonalInformation;
        NSArray* personalInfoCells = [self rowControlsTaggedWith:@"personalInfo"];

        UITableViewRowAnimation rowAnimation = UITableViewRowAnimationTop;
        if (self.showPersonalInformation)
        {
            [self unhideRowControls:personalInfoCells
                   withRowAnimation:rowAnimation];
        }
        else
        {
            [self hideRowControls:personalInfoCells
                 withRowAnimation:rowAnimation];
        }
    }
}

- (void)setShowPersonalInformation2:(BOOL)showPersonalInformation
{
    if (self.showPersonalInformation2 != showPersonalInformation)
    {
        _showPersonalInformation2 = showPersonalInformation;
        NSArray* personalInfoCells = [self rowControlsTaggedWith:@"personalInfoB"];

        UITableViewRowAnimation rowAnimation = UITableViewRowAnimationTop;
        if (self.showPersonalInformation2)
        {
            [self unhideRowControls:personalInfoCells
                   withRowAnimation:rowAnimation];
        }
        else
        {
            [self hideRowControls:personalInfoCells
                 withRowAnimation:rowAnimation];
        }
    }
}

- (void)control:(AKAControl *)control modelValueChangedFrom:(id)oldValue to:(id)newValue
{
    // model.description does not receive change notifications. We fake that here to show
    // that you can still react to changes on a global level using delegate methods.
    self.modelValueLabel.text = [[self.model description] stringByAppendingString:@""];

    // Instruct the tableview to refresh row heights. This is needed if rows may actually
    // change their height as a result of a changed value.
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end
