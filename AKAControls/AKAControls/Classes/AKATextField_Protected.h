//
//  AKATextField_Protected.h
//  AKAControls
//
//  Created by Michael Utech on 09.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextField.h"
#import "AKATextFieldBinding.h"

@interface AKATextField ()

@property (nonatomic, readonly) AKATextFieldBindingConfiguration* textFieldBindingConfiguration;

- (AKATextFieldBindingConfiguration*)createTextFieldBindingConfiguration;

- (void)setupDefaultValues;

@end
