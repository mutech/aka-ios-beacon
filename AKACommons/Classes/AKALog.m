//
//  AKALog.m
//  AKAControls
//
//  Created by Michael Utech on 18.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKALog.h"

@implementation AKALog

#if AKA_SUPPORT_DYNAMIC_LOG_LEVELS

+ (AKALog *)sharedInstance
{
    static AKALog* result;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [AKALog new];
    });

    return result;
}

#endif

@end
