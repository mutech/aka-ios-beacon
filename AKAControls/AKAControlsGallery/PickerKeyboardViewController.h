//
//  PickerKeyboardViewController.h
//  AKAControlsGallery
//
//  Created by Michael Utech on 03.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AKAControls.AKAPickerKeyboardTriggerView;

@interface PickerKeyboardViewController : UIViewController

@property (weak, nonatomic) IBOutlet AKAPickerKeyboardTriggerView *stringPickerTriggerView;
@property (weak, nonatomic) IBOutlet AKAPickerKeyboardTriggerView *objectPickerTriggerView;

@end
