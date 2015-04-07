//
//  AKACompositeViewBindingConfiguration.m
//  AKAControls
//
//  Created by Michael Utech on 06.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKACompositeViewBindingConfiguration.h"
#import "AKACompositeControl.h"

@implementation AKACompositeViewBindingConfiguration

- (Class)preferredControlType
{
    return [AKACompositeControl class];
}

@end
