//
//  AKAChoiceDemoTableViewController.h
//  AKAControlsDemo
//
//  Created by Michael Utech on 14.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AKAControls/AKAFormTableViewController.h>
#import <AKAControls/AKASingleChoiceEditorControlView.h>

@interface AKAChoiceDemoTableViewController : AKAFormTableViewController

@property (weak, nonatomic) IBOutlet UITableViewCell *manualPickerCell;
@property (weak, nonatomic) IBOutlet UILabel*selectedValueLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *manualPickerHeightConstraint;

@property (weak, nonatomic) IBOutlet UITableViewCell *keyboardPickerCell;

@property (weak, nonatomic) IBOutlet UITextField *keyboardPickerTextField;
@end
