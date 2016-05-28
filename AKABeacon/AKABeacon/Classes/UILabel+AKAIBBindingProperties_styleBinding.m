//
//  UILabel+AKAIBBindingProperties_styleBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UILabel+AKAIBBindingProperties_styleBinding.h"
#import "AKABinding_UILabel_styleBinding.h"

@implementation UILabel (AKAIBBindingProperties_styleBinding)

- (Class)aka_styleBindingType
{
    return [AKABinding_UILabel_styleBinding class];
}

@end
