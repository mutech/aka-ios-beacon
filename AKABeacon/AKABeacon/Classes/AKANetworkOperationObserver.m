//
//  AKANetworkOperationObserver.m
//  AKABeacon
//
//  Created by Michael Utech on 24/09/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKANetworkOperationObserver.h"
#import "AKAOperation.h"
#import "NSObject+AKAConcurrencyTools.h"


#pragma mark - AKASharedIndicatorStateCounter
#pragma mark -

@interface AKASharedIndicatorStateCounter: NSObject

#pragma mark - State

@property(nonatomic, readonly) BOOL active;

@property(nonatomic, readonly) NSUInteger count;

#pragma mark - Updating the counter

- (void)increment;

- (void)decrement;

#pragma mark - Sub class support

- (void)indicatorDidBecomeActive;

- (void)indicatorDidBecomeInactive;

@end

@interface AKASharedIndicatorStateCounter()

@property(nonatomic) NSUInteger count;

@end

@implementation AKASharedIndicatorStateCounter

- (instancetype)init
{
    if (self = [super init])
    {
        _count = 0;
    }
    return self;
}

- (BOOL)active
{
    return self.count > 0;
}

- (void)setCount:(NSUInteger)count
{
    NSAssert([NSThread isMainThread], nil);
    NSParameterAssert(count >= 0);

    BOOL wasActive = self.active;
    _count = count;
    if (wasActive)
    {
        if (!self.active)
        {
            [self indicatorDidBecomeInactive];
        }
    }
    else
    {
        if (self.active)
        {
            [self indicatorDidBecomeActive];
        }
    }
}

+ (NSSet *)keyPathsForValuesAffectingActive
{
    static NSSet* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [NSSet setWithObject:@"count"];
    });
    return result;
}

- (void)increment
{
    [self aka_performBlockInMainThreadOrQueue:^{
        self.count++;
    } waitForCompletion:NO];
}

- (void)decrement
{
    [self aka_performBlockInMainThreadOrQueue:^{
        self.count--;
    } waitForCompletion:NO];
}

- (void)indicatorDidBecomeActive
{
}

- (void)indicatorDidBecomeInactive
{
}

@end


#pragma mark - AKANetworkActivityIndicatorCounter
#pragma mark -


@interface AKANetworkActivityIndicator: NSObject<AKANetworkActivityIndicatorProtocol>

+ (instancetype)sharedInstance;

@end

@implementation AKANetworkActivityIndicator

+ (instancetype)sharedInstance
{
    static AKANetworkActivityIndicator* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [AKANetworkActivityIndicator new];
    });
    return result;
}

- (NSTimeInterval)hidingDelay
{
    return 0.7;
}

- (NSTimeInterval)hidingDelayTolerance
{
    return 0;
}

- (void)showNetworkActivityIndicator
{
    NSAssert([NSThread isMainThread], nil);

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)hideNetworkActivityIndicator
{
    NSAssert([NSThread isMainThread], nil);

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end


@interface AKANetworkActivityIndicatorCounter: AKASharedIndicatorStateCounter

+ (instancetype)sharedInstance;

@property(nonatomic) id<AKANetworkActivityIndicatorProtocol> networkActivityIndicator;

@end

@interface AKANetworkActivityIndicatorCounter()

@property(nonatomic) BOOL isHideNetworkActivityIndicatorScheduled;

@end

@implementation AKANetworkActivityIndicatorCounter

#pragma mark - Initialization

+ (instancetype)sharedInstance
{
    static AKANetworkActivityIndicatorCounter* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [AKANetworkActivityIndicatorCounter new];
    });
    return result;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.networkActivityIndicator = [AKANetworkActivityIndicator sharedInstance];
    }
    return self;
}

#pragma mark - Events

- (void)indicatorDidBecomeActive
{
    [self showNetworkActivityIndicator];
}

- (void)indicatorDidBecomeInactive
{
    NSAssert([NSThread isMainThread], nil);

    if (![self isHideNetworkActivityIndicatorScheduled])
    {
        [self scheduleHideNetworkActivityIndicator];
    }
}

#pragma mark - Indicator Updates

- (void)showNetworkActivityIndicator
{
    NSAssert([NSThread isMainThread], nil);

    [self cancelTimer];
    [self.networkActivityIndicator showNetworkActivityIndicator];
}

- (void)hideNetworkActivityIndicator
{
    NSAssert([NSThread isMainThread], nil);

    [self cancelTimer];
    [self.networkActivityIndicator hideNetworkActivityIndicator];
}

#pragma mark - Indicator Update Scheduling

- (void)scheduleHideNetworkActivityIndicator
{
    NSAssert([NSThread isMainThread], nil);

    if (!self.isHideNetworkActivityIndicatorScheduled)
    {
        id<AKANetworkActivityIndicatorProtocol> indicator = self.networkActivityIndicator;
        if (isnan(indicator.hidingDelay) || indicator.hidingDelay <= 0)
        {
            [self hideNetworkActivityIndicator];
        }
        else
        {
            self.isHideNetworkActivityIndicatorScheduled = YES;

            __weak AKANetworkActivityIndicatorCounter* weakSelf = self;
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(indicator.hidingDelay * NSEC_PER_SEC));
            dispatch_after(time, dispatch_get_main_queue(), ^{
                __strong AKANetworkActivityIndicatorCounter* strongSelf = weakSelf;
                if (strongSelf.isHideNetworkActivityIndicatorScheduled)
                {
                    [strongSelf hideNetworkActivityIndicator];
                    strongSelf.isHideNetworkActivityIndicatorScheduled = NO;
                }
            });
        }
    }
}

- (void)cancelTimer
{
    NSAssert([NSThread isMainThread], nil);

    self.isHideNetworkActivityIndicatorScheduled = NO;
}

@end


#pragma mark - AKANetworkOperationObserver
#pragma mark -

@implementation AKANetworkOperationObserver

#pragma mark - Initialization

+ (instancetype)sharedInstance
{
    static AKANetworkOperationObserver* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [AKANetworkOperationObserver new];
    });
    return result;
}

#pragma mark - Configuration

+ (void)setNetworkActivityIndicator:(id<AKANetworkActivityIndicatorProtocol>)indicator
{
    AKANetworkActivityIndicatorCounter* counter = [AKANetworkActivityIndicatorCounter sharedInstance];
    [counter aka_performBlockInMainThreadOrQueue:^{
        counter.networkActivityIndicator = indicator;
    } waitForCompletion:NO];
}

+ (id<AKANetworkActivityIndicatorProtocol>)defaultNetworkActivityIndicator
{
    return [AKANetworkActivityIndicator sharedInstance];
}

#pragma mark - Setup operations to update the indicator state

+ (void)showNetworkActivityIndicatorWhileOperationIsRunning:(AKAOperation *)operation
{
    [operation addObserver:[self sharedInstance]];
}

#pragma mark - Direct indicator state updates

+ (void)showNetworkActivityIndicatorWhilePerformingBlock:(void (^)())block
{
    [self startUsingNetwork];
    block();
    [self stopUsingNetwork];
}

+ (void)startUsingNetwork
{
    [[AKANetworkActivityIndicatorCounter sharedInstance] increment];
}

+ (void)stopUsingNetwork
{
    [[AKANetworkActivityIndicatorCounter sharedInstance] decrement];
}

#pragma mark - Operation Events

- (void)    operationDidStart:(AKAOperation*__unused)operation
{
    [[AKANetworkActivityIndicatorCounter sharedInstance] increment];
}

- (void)            operation:(AKAOperation*__unused)operation
          didFinishWithErrors:(NSArray<NSError*>*__unused)errors
{
    [[AKANetworkActivityIndicatorCounter sharedInstance] decrement];
}

@end
