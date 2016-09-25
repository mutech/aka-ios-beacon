//
//  AKADelayedOperationCondition.m
//  AKABeacon
//
//  Created by Michael Utech on 25/09/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKADelayedOperationCondition.h"
#import "AKAOperation.h"

@implementation AKADelayedOperationCondition

#pragma mark - Conveniences

+ (void)       delayOperation:(AKAOperation *)operation
                 withDuration:(NSTimeInterval)delay
{
    if (delay > 0.0 && !isnan(delay))
    {
        AKADelayedOperationCondition* condition = [[AKADelayedOperationCondition alloc] initWithDelay:delay];
        [operation addCondition:condition];
    }
}

#pragma mark - Initialization

- (instancetype)initWithDelay:(NSTimeInterval)delay
{
    if (self = [self init])
    {
        _delay = delay;
    }
    return self;
}

+ (BOOL)  isMutuallyExclusive
{
    return NO;
}

- (void) evaluateForOperation:(AKAOperation*__unused)operation
                   completion:(void (^)(BOOL, NSError * _Nullable))completion
{
    if (self.delay > 0.0 && !isnan(self.delay))
    {
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW,
                                             (int64_t)(self.delay * NSEC_PER_SEC));
        dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
        dispatch_after(time, queue, ^{
            completion(YES, nil);
        });
    }
    else
    {
        completion(YES, nil);
    }
}

@end


