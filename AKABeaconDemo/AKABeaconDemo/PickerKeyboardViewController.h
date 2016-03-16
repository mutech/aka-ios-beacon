//
//  PickerKeyboardViewController.h
//  AKABeaconDemo
//
//  Created by Michael Utech on 03.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerKeyboardViewController : UIViewController

#pragma mark - Outlets

/**
 Scroll view used by binding behavior to scroll first responder to visible area.
 */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

#pragma mark - View Model

@property(nonatomic) NSString* stringValue;
@property(nonatomic) NSArray*  stringArrayValue;

@property(nonatomic) id        objectValue;
@property(nonatomic) NSArray*  objectArrayValue;

@property(nonatomic) NSDate*   dateValue;

@end
