//
//  AKABindingController+KeyboardActivationSequence.h
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController.h"
#import "AKAKeyboardActivationSequence.h"


#pragma mark - AKABindingController(KeyboardActivationSequence) - Private Interface
#pragma mark -

@interface AKABindingController(KeyboardActivationSequence) <AKAKeyboardActivationSequenceDelegate>

@property(nonatomic, readonly) AKAKeyboardActivationSequence* keyboardActivationSequence;

- (void)initializeKeyboardActivationSequence;

@end
