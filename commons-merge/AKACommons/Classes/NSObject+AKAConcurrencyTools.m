//
//  NSObject+ConcurrencyTools.m
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "NSObject+AKAConcurrencyTools.h"

@implementation NSObject (AKAConcurrencyTools)

- (void)aka_performBlockInMainThreadOrQueue:(void (^)())block
                          waitForCompletion:(BOOL)synchronously
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else if (synchronously)
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@end
