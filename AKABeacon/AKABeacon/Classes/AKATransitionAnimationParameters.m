//
//  AKATransitionAnimationParameters.m
//  AKABeacon
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATransitionAnimationParameters.h"


@implementation AKATransitionAnimationParameters

- (instancetype)init
{
    if (self = [super init])
    {
        self.duration = .2f;
        self.options = (UIViewAnimationOptionCurveEaseInOut |
                        UIViewAnimationOptionTransitionCrossDissolve);
    }

    return self;
}

@end
