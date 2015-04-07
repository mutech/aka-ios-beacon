//
//  AKABindingConfiguration.m
//  AKAControls
//
//  Created by Michael Utech on 06.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAViewBindingConfiguration.h"
#import "AKAViewBinding.h"
#import "AKAControl.h"

@implementation AKAViewBindingConfiguration

- (Class)preferredBindingType
{
    return [AKAViewBinding class];
}

- (Class)preferredControlType
{
    return [AKAControl class];
}

- (Class)preferredViewType
{
    return [UIView class];
}

@end
