//
//  AKAKeyboardActivationSequenceAccessoryView.m
//  AKAControls
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAKeyboardActivationSequenceAccessoryView.h"
#import "AKAKeyboardActivationSequence.h"
#import "AKAControlsStyleKit.h"

#import <AKACommons/AKALog.h>

@implementation AKAKeyboardActivationSequenceAccessoryView

#pragma mark - Initialization

#pragma mark - Configuration

- (void)setKeyboardActivationSequence:(AKAKeyboardActivationSequence *)keyboardActivationSequence
{
    if (_keyboardActivationSequence == nil)
    {
        _keyboardActivationSequence = keyboardActivationSequence;
        [self createBarItems];
        [self updateBarItemStates];
    }
    else
    {
        // TODO: error handling
        AKALogError(@"Invalid attempt to change owner keyboard activation sequence of input accessory view %@ assocuated with activation sequence %@", self, self.keyboardActivationSequence);
    }
}

- (void)updateBarItemStates
{
    self.activateNextBarButtonItem.enabled = self.keyboardActivationSequence.nextItem != nil;
    self.closeKeyboardBarButtonItem.enabled = YES;
    self.activatePreviousBarButtonItem.enabled = self.keyboardActivationSequence.previousItem != nil;
}

- (void)createBarItems
{
    self.tintColor = [UIColor blackColor];

    [self setBarStyle:UIBarStyleDefault];
    [self sizeToFit];

    self.activatePreviousBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                         style:UIBarButtonItemStylePlain
                                        target:self.keyboardActivationSequence
                                        action:@selector(activatePrevious:)];
    self.activatePreviousBarButtonItem.image =
        [AKAControlsStyleKit imageOfBackBarButtonItemIcon];

    UIBarButtonItem* hs12 =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    self.closeKeyboardBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                         style:UIBarButtonItemStylePlain
                                        target:self.keyboardActivationSequence
                                        action:@selector(closeKeyboard:)];
    self.closeKeyboardBarButtonItem.image =
        [AKAControlsStyleKit imageOfCloseKeyboardBarButtonItemIcon];

    UIBarButtonItem* hs23 =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                  target:nil
                                                  action:nil];
    self.activateNextBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                         style:UIBarButtonItemStylePlain
                                        target:self.keyboardActivationSequence
                                        action:@selector(activateNext:)];
    self.activateNextBarButtonItem.image = [AKAControlsStyleKit imageOfForthBarButtonItemIcon];

    [self setItems:@[self.activatePreviousBarButtonItem, hs12,
                     self.closeKeyboardBarButtonItem, hs23,
                     self.activateNextBarButtonItem]];
}

@end
