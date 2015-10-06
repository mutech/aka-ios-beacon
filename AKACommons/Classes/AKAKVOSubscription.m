//
//  AKAKVOSubscription.m
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAKVOSubscription_Internal.h"
#import "AKAKVOPublisher.h"
#import "AKAKVOChangeEvent.h"

@interface AKAKVOSubscription ()

/**
 * The queue which is used to call handlers (except valueWillChange). Calls to handlers are dispatched to
 * this queue. If no queue is defined, calls are dispatched to the main queue or,
 * if changes are effected in the main thread, called immediately from the KVO
 * handler.
 *
 * Please note that the valueWillChangeHandler is called in the thread that effect the change
 * because it would otherwise (likely) be called after the change occurred.
 *
 * Remark: It seems to generate more problems than it solves to dispatch notifications to a
 * predefined queue. For this reason all related features were moved to internal headers.
 */
@property(nonatomic, weak)dispatch_queue_t notificationQueue;

@end

@implementation AKAKVOSubscription

@synthesize publisher = _publisher;
@synthesize notificationQueue = _notificationQueue;
@synthesize keyPath = _keyPath;
@synthesize isActive = _isActive;
@synthesize valueWillChangeHandler = _valueWillChangeHandler;
@synthesize valueDidChangeHandler = _valueDidChangeHandler;
@synthesize subscriptionStartedHandler = _subscriptionStartedHandler;
@synthesize providesOldValue = _providesOldValue;
@synthesize providesNewValue = _providesNewValue;

#pragma mark - Initialization

- (instancetype)initWithPublisher:(AKAKVOPublisher*)publisher
                          keyPath:(NSString*)keyPath
                notificationQueue:(dispatch_queue_t)notificationQueue
              subscriptionStarted:(void(^)(AKAKVOSubscription* s))subscriptionStarted
                  valueWillChange:(void(^)(AKAKVOChangeEvent* e))valueWillChange
                   valueDidChange:(void(^)(AKAKVOChangeEvent* e))valueDidChange
                  provideOldValue:(BOOL)provideOldValue
                  provideNewValue:(BOOL)provideNewValue
{
    NSParameterAssert(publisher != nil);
    NSParameterAssert(keyPath.length > 0);
    NSParameterAssert(valueWillChange != nil || valueDidChange != nil);

    self = [super init];
    if (self)
    {
        _publisher = publisher;
        _keyPath = keyPath;
        _notificationQueue = notificationQueue;
        _subscriptionStartedHandler = subscriptionStarted;
        _valueWillChangeHandler = valueWillChange;
        _valueDidChangeHandler = valueDidChange;
        _providesOldValue = provideOldValue;
        _providesNewValue = provideNewValue;
        _isActive = NO;
    }
    return self;
}

#pragma mark - Properties

- (AKAKVOPublisher *)publisher { return _publisher; }
- (dispatch_queue_t)notificationQueue { return _notificationQueue; }
- (NSString *)keyPath { return _keyPath; }
- (BOOL)isActive { return _isActive; }
- (void (^)(AKAKVOChangeEvent *))valueWillChangeHandler { return _valueWillChangeHandler; }
- (void (^)(AKAKVOChangeEvent *))valueDidChangeHandler { return _valueDidChangeHandler; }
- (void (^)(AKAKVOSubscription *))subscriptionStartedHandler { return _subscriptionStartedHandler; }
- (BOOL)providesNewValue { return _providesNewValue; }
- (BOOL)providesOldValue { return _providesOldValue; }

#pragma mark - Convenience Methods

- (void)suspend
{
    if (self.isActive)
    {
        [self.publisher suspendSubscription:self];
    }
}

- (void)resume
{
    if (!self.isActive)
    {
        [self.publisher resumeSubscription:self];
    }
}

- (void)cancel
{
    [self.publisher cancelSubscription:self];
}

- (id)currentValue
{
    return [self.publisher.target valueForKeyPath:self.keyPath];
}

#pragma mark - Subscription status updates

- (void)publisherActivatedSubscription:(AKAKVOPublisher*)publisher
{
    NSParameterAssert(publisher == self.publisher);
    _isActive = YES;
}

- (void)publisherDeactivatedSubscription:(AKAKVOPublisher*)publisher
{
    NSParameterAssert(publisher == self.publisher);
    _isActive = NO;
}

- (void)publisherCancelledSubscription:(AKAKVOPublisher*)publisher
{
    NSParameterAssert(publisher == self.publisher);
    NSAssert(!self.isActive, @"Attempt to cancel active subscription, publisher is expected to deactivate before cancelling");

    _publisher = nil;
    // Reset handlers to release resources bound to handlers
    _subscriptionStartedHandler = nil;
    _valueWillChangeHandler = nil;
    _valueDidChangeHandler = nil;
}

@end

