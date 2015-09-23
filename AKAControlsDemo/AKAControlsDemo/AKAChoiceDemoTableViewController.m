//
//  AKAChoiceDemoTableViewController.m
//  AKAControlsDemo
//
//  Created by Michael Utech on 14.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAChoiceDemoTableViewController.h"

@interface AKAChoiceDemoTableViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, readonly) NSArray* pickerValues;
@property(nonatomic) NSString* selectedValue;
@property(nonatomic) BOOL manualPickerIsActive;

@end

@implementation AKAChoiceDemoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.manualPickerIsActive = NO;
    [self updateManualPicker];

    UIPickerView* picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    picker.dataSource = self;
    picker.delegate = self;
    self.keyboardPickerTextField.inputView = picker;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Delegate

- (NSIndexPath *)           tableView:(UITableView *)tableView
             willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* result = indexPath;
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.manualPickerCell)
    {
        if (self.manualPickerIsActive)
        {
            // Do not select if picker is already active:
            //result = nil;
        }
    }
    return result;
}

- (void)                    tableView:(UITableView *)tableView
              didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.manualPickerCell)
    {
        self.manualPickerIsActive = !self.manualPickerIsActive;
        [self updateManualPicker];
    }
}

#pragma mark - Properties

@synthesize pickerValues = _pickerValues;

- (NSArray *)pickerValues
{
    if (_pickerValues == nil)
    {
        _pickerValues = @[ @"Eins",
                                 @"Zwei",
                                 @"Drei",
                                 @"Vier",
                                 @"Fünf",
                                 @"Sechs",
                                 @"Sieben",
                                 @"Acht",
                                 @"Neun",
                                 @"Zehn" ];
    }
    return _pickerValues;
}

#pragma mark - Manual Picker

- (void)updateManualPicker
{
    self.pickerView.userInteractionEnabled = self.manualPickerIsActive;
    self.manualPickerHeightConstraint.constant = self.manualPickerIsActive ? self.pickerView.intrinsicContentSize.height : 0;
    self.pickerView.hidden = !self.manualPickerIsActive;

    [UIView animateWithDuration:.3
                     animations:^{
                         [self.manualPickerCell.contentView layoutIfNeeded];
                     }];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (void)control:(AKAControl*)control modelValueChangedFrom:(id)oldValue to:(id)newValue
{
    if (control.view == self.selectedValueLabel)
    {
        if (self.manualPickerIsActive)
        {
            self.manualPickerIsActive = NO;
            [self updateManualPicker];
        }
    }
}

#pragma mark - Picker Data Source and Delegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerValues.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerValues[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //self.keyboardPickerTextField.text = self.pickerValues[row];
    self.selectedValue = self.pickerValues[row];
    [self.keyboardPickerTextField resignFirstResponder];
}

@end
