//
//  AKAKeyboardControl.m
//  AKABeacon
//
//  Created by Michael Utech on 15.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAKeyboardControl.h"

@implementation AKAKeyboardControl

@dynamic controlViewBinding;

- (AKAKeyboardControlViewBinding *)controlViewBinding
{
    AKAControlViewBinding* result = [super controlViewBinding];
    NSAssert(result == nil || [result isKindOfClass:[AKAKeyboardControlViewBinding class]],
             @"Control view binding %@ expected to be an instance of AKAKeyboardControlViewBinding",
             result);
    return (AKAKeyboardControlViewBinding*)result;
}

@end
