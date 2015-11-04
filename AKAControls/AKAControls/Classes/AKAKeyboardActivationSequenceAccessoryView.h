//
//  AKAKeyboardActivationSequenceAccessoryView.h
//  AKABeacon
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKAKeyboardActivationSequence;

@interface AKAKeyboardActivationSequenceAccessoryView : UIToolbar

#pragma mark - Initialization

#pragma mark - Configuration

@property(nonatomic, weak)AKAKeyboardActivationSequence* keyboardActivationSequence;

- (void)updateBarItemStates;

#pragma mark - Outlets

@property(nonatomic)IBOutlet UIBarButtonItem* activatePreviousBarButtonItem;
@property(nonatomic)IBOutlet UIBarButtonItem* closeKeyboardBarButtonItem;
@property(nonatomic)IBOutlet UIBarButtonItem* activateNextBarButtonItem;

@end
