//
//  ViewController.h
//  AKACommonsDemoApp
//
//  Created by Michael Utech on 11.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AKACommons/AKATextField.h>
#import <AKACommons/AKALabel.h>
#import <AKACommons/AKASwitch.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet AKATextField *textField;
@property (weak, nonatomic) IBOutlet AKALabel *viewValueLabel;
@property (weak, nonatomic) IBOutlet AKALabel *modelValueLabel;
@property (weak, nonatomic) IBOutlet AKASwitch *switchView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *dismissKeyboardGestureRecognizer;
- (IBAction)dismissKeyboard:(id)sender;

@end

