//
//  NSObject+ConcurrencyTools.m
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "NSObject+AKAConcurrencyTools.h"

@implementation NSObject (AKAConcurrencyTools)

- (void)aka_performBlockInMainThreadOrQueue:(void (^)())block
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@end
