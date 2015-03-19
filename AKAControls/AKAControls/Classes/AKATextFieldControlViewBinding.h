//
//  AKATextFieldControlViewBinding.h
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlViewBinding.h"
#import "AKATextField.h"

@interface AKATextFieldControlViewBinding: AKAControlViewBinding

#pragma mark - Initialization

#pragma mark - Convenience

@property(nonatomic, readonly) UITextField* textField;
@property(nonatomic, readonly) AKATextField* akaTextField;

@end
