//
//  AKAKVOSubscription.m
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAKVOSubscription_Internal.h"
#import "AKAKVOPublisher.h"
#import "AKAKVOChangeEvent.h"

@implementation AKAKVOSubscription

@synthesize publisher = _publisher;
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
- (NSString *)keyPath { return _keyPath; }
- (BOOL)isActive { return _isActive; }
- (void (^)(AKAKVOChangeEvent *))valueWillChangeHandler { return _valueWillChangeHandler; }
- (void (^)(AKAKVOChangeEvent *))valueDidChangeHandler { return _valueDidChangeHandler; }
- (void (^)(AKAKVOSubscription *))subscriptionStartedHandler { return _subscriptionStartedHandler; }
- (BOOL)providesNewValue { return _providesNewValue; }
- (BOOL)providesOldValue { return _providesOldValue; }

#pragma mark - Convenience Methods

- (void)suspendSubscription
{
    if (self.isActive)
    {
        [self.publisher suspendSubscription:self];
    }
}

- (void)resumeSubscription
{
    if (!self.isActive)
    {
        [self.publisher resumeSubscription:self];
    }
}

- (void)cancelSubscription
{
    [self.publisher cancelSubscription:self];
}

- (id)value
{
    return [self.publisher.target valueForKeyPath:self.keyPath];
}

- (void)setValue:(id)value
{
    [self.publisher.target setValue:value forKeyPath:self.keyPath];
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

