//
//  AKABlockOperation.m
//  AKABeacon
//
//  Created by Michael Utech on 11.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABlockOperation.h"

@interface AKABlockOperation()

@property(nonatomic) void(^block)(void (^finish)());

@end

@implementation AKABlockOperation

- (instancetype)initWithBlock:(void(^_Nonnull)(void(^finish)()))block
{
    if (self = [self init])
    {
        self.block = block;
    }
    return self;
}

- (instancetype)initWithMainQueueBlock:(void(^_Nonnull)())mainQueueBlock
{
    if (self = [self init])
    {
        self.block = ^(void(^continuation)()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                mainQueueBlock();
                continuation();
            });
        };
    }
    return self;
}

- (void)execute
{
    void(^block)(void (^finish)()) = self.block ? self.block : ^(void(^continuation)()) {
        continuation();
    };

    block(^{ [self finish]; });
}

@end
