//
//  AKADeallocSentinel.m
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//


#import "AKADeallocSentinel.h"
#import <objc/runtime.h>


@interface AKADeallocSentinel()

@property(nonatomic) void(^deallocNotificationBlock)();

@end


@implementation AKADeallocSentinel

+ (req_instancetype)observeObjectLifeCycle:(id)object deallocation:(void(^)())deallocNotificationBlock
{
    AKADeallocSentinel* sentinel = [[AKADeallocSentinel alloc] initWithDeallocNotificationBlock:deallocNotificationBlock];

    objc_setAssociatedObject(object, (__bridge const void *)(sentinel), sentinel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    return sentinel;
}

- (instancetype)initWithDeallocNotificationBlock:(void(^)())deallocNotificationBlock
{
    if (self = [self init])
    {
        self.deallocNotificationBlock = deallocNotificationBlock;
    }
    return self;
}

- (void)dealloc
{
    if (self.deallocNotificationBlock != NULL)
    {
        self.deallocNotificationBlock();
    }
}

- (void)cancel
{
    self.deallocNotificationBlock = NULL;
}

@end
