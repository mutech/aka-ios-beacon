//
//  AKANumberTextField.m
//  AKAControls
//
//  Created by Michael Utech on 09.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextField_Protected.h"
#import "AKANumberTextField.h"
#import "UIView+AKABinding.h"
#import "AKAControlsStyleKit.h"
#import "AKANumberTextConverter.h"

@implementation AKANumberTextField

- (AKATextFieldBindingConfiguration *)createTextFieldBindingConfiguration
{
    return AKANumberTextFieldBindingConfiguration.new;
}

- (void)setupDefaultValues
{
    [super setupDefaultValues];

    self.keyboardType = UIKeyboardTypeDecimalPad;
}

@end

@implementation AKANumberTextFieldBinding

+ (id<AKAControlConverterProtocol>)defaultConverter
{
    return [[AKANumberTextConverter alloc] init];
}

@end

@implementation AKANumberTextFieldBindingConfiguration

- (Class)preferredBindingType
{
    return [AKANumberTextFieldBinding class];
}

- (Class)preferredViewType
{
    return [AKANumberTextField class];
}

@end