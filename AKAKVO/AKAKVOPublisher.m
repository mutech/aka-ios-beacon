//
//  AKAKVOPublisher.m
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAKVOPublisher.h"
#import "AKAKVOSubscription_Internal.h"
#import "AKAKVOChangeEvent.h"

@interface AKAKVOPublisher()

@property(nonatomic, strong)NSMutableSet* activeSubscriptions;
@property(nonatomic, strong)NSMutableSet* suspendedSubscriptions;

@end

@implementation AKAKVOPublisher

@synthesize target = _target;

#pragma mark - Initialization

- (instancetype)initWithTarget:(NSObject*)target
{
    self = [super init];
    if (self)
    {
        if (!_target)
        {
            self.activeSubscriptions = [[NSMutableSet alloc] init];
            self.suspendedSubscriptions = [[NSMutableSet alloc] init];
            _target = target;
        }
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllSubscriptions];
}

+ (AKAKVOPublisher *)publisherForTarget:(NSObject *)target
{
    AKAKVOPublisher* result = [[AKAKVOPublisher alloc] initWithTarget:target];
    return result;
}

#pragma mark - Properties

- (NSObject *)target { return _target; }

#pragma mark - Subscriptions

- (AKAKVOSubscription *)subscribeToKeyPath:(NSString *)keyPath
                            valueDidChange:(void (^)(AKAKVOChangeEvent *))valueDidChange
{
    return [self subscribeToKeyPath:keyPath
                subscriptionStarted:nil
                     valueDidChange:valueDidChange];
}

- (AKAKVOSubscription *)subscribeToKeyPath:(NSString *)keyPath
                       subscriptionStarted:(void (^)(AKAKVOSubscription *))subscriptionStarted
                            valueDidChange:(void (^)(AKAKVOChangeEvent *))valueDidChange
{
    return [self subscribeToKeyPath:keyPath
                subscriptionStarted:subscriptionStarted
                    valueWillChange:nil
                     valueDidChange:valueDidChange
                    provideOldValue:YES
                    provideNewValue:YES];
}

- (AKAKVOSubscription*)subscribeToKeyPath:(NSString*)keyPath
                      subscriptionStarted:(void(^)(AKAKVOSubscription* s))subscriptionStarted
                          valueWillChange:(void(^)(AKAKVOChangeEvent* e))valueWillChange
                           valueDidChange:(void(^)(AKAKVOChangeEvent* e))valueDidChange
                          provideOldValue:(BOOL)provideOldValue
                          provideNewValue:(BOOL)provideNewValue
{
    AKAKVOSubscription* result;

    result = [[AKAKVOSubscription alloc] initWithPublisher:self
                                                  keyPath:keyPath
                                      subscriptionStarted:subscriptionStarted
                                          valueWillChange:valueWillChange
                                           valueDidChange:valueDidChange
                                           provideOldValue:provideOldValue
                                           provideNewValue:provideNewValue];
    [self startSubscription:result];
    return result;
}

- (void)suspendAllActiveSubscriptions
{
    [self enumerateActiveSubscriptionsUsingBlock:^(AKAKVOSubscription *subscription, BOOL *stop) {
        [self suspendSubscription:subscription];
    }];
}

- (void)suspendSubscription:(AKAKVOSubscription*)subscription
{
    [self validateManagedSubscription:subscription];

    [self.suspendedSubscriptions addObject:subscription];
    [self stopObservingChangesForSubscription:subscription];

    [self validateManagedSubscription:subscription];
}

- (void)resumeAllSuspendedSubscriptions
{
    [self enumerateSuspendedSubscriptionsUsingBlock:^(AKAKVOSubscription *subscription, BOOL *stop) {
        [self resumeSubscription:subscription];
    }];
}

- (void)resumeSubscription:(AKAKVOSubscription*)subscription
{
    [self validateManagedSubscription:subscription];

    // TODO: make this thread-safe
    [self startObservingChangesForSubscription:subscription];
    [self.suspendedSubscriptions removeObject:subscription];

    [self validateManagedSubscription:subscription];
}

- (void)cancelAllSubscriptions
{
    [self enumerateSubscriptionsUsingBlock:^(AKAKVOSubscription *subscription, BOOL *stop) {
        [self cancelSubscription:subscription];
    }];
}

- (BOOL)enumerateActiveSubscriptionsUsingBlock:(void(^)(AKAKVOSubscription* subscription, BOOL* stop))block
{
    BOOL stop = NO;
    NSSet* subscriptions = [NSSet setWithSet:self.activeSubscriptions];
    for (AKAKVOSubscription* subscription in subscriptions)
    {
        block(subscription, &stop);
        if (stop)
        {
            break;
        }
    }
    return !stop;
}

- (BOOL)enumerateSuspendedSubscriptionsUsingBlock:(void(^)(AKAKVOSubscription* subscription, BOOL* stop))block
{
    BOOL stop = NO;
    NSSet* subscriptions = [NSSet setWithSet:self.suspendedSubscriptions];
    for (AKAKVOSubscription* subscription in subscriptions)
    {
        block(subscription, &stop);
        if (stop)
        {
            break;
        }
    }
    return !stop;
}

- (BOOL)enumerateSubscriptionsUsingBlock:(void(^)(AKAKVOSubscription* subscription, BOOL* stop))block
{
    BOOL stop = NO;
    NSSet* subscriptions = [self.activeSubscriptions setByAddingObjectsFromSet:self.suspendedSubscriptions];
    for (AKAKVOSubscription* subscription in subscriptions)
    {
        block(subscription, &stop);
        if (stop)
        {
            break;
        }
    }
    return !stop;
}

- (void)cancelSubscription:(AKAKVOSubscription*)subscription
{
    [self validateManagedSubscription:subscription];

    if (subscription.isActive)
    {
        [self stopObservingChangesForSubscription:subscription];
    }
    else
    {
        [self.suspendedSubscriptions removeObject:subscription];
    }
    [subscription publisherCancelledSubscription:self];

    [self validateUnmanagedSubscription:subscription];
}

#pragma mark - Private

- (void)startSubscription:(AKAKVOSubscription*)subscription
{
    [self validateNewSubscription:subscription];

    [self startObservingChangesForSubscription:subscription];

    [self validateManagedSubscription:subscription];
}

- (void)validateNewSubscription:(AKAKVOSubscription*)subscription
{
    NSParameterAssert(subscription != nil);
    NSParameterAssert(subscription.publisher == self);
    NSParameterAssert(![self.activeSubscriptions containsObject:subscription] &&
                      ![self.suspendedSubscriptions containsObject:subscription]);
}

- (void)validateManagedSubscription:(AKAKVOSubscription*)subscription
{
    NSParameterAssert(subscription != nil);
    NSParameterAssert(subscription.publisher == self);
    NSParameterAssert([self.activeSubscriptions containsObject:subscription] ||
                      [self.suspendedSubscriptions containsObject:subscription]);
}

- (void)validateUnmanagedSubscription:(AKAKVOSubscription*)subscription
{
    NSParameterAssert(subscription != nil);
    NSParameterAssert(subscription.publisher != self);
    NSParameterAssert(![self.activeSubscriptions containsObject:subscription] &&
                      ![self.suspendedSubscriptions containsObject:subscription]);
}

#pragma mark Key Value Observing

- (void)startObservingChangesForSubscription:(AKAKVOSubscription*)subscription
{
    if (!subscription.isActive)
    {
        NSUInteger options = 0;
        if (subscription.providesNewValue)
        {
            options |= NSKeyValueObservingOptionNew;
        }
        if (subscription.providesOldValue)
        {
            options |= NSKeyValueObservingOptionOld;
        }
        if (subscription.valueWillChangeHandler)
        {
            options |= NSKeyValueObservingOptionPrior;
        }

        [self.activeSubscriptions addObject:subscription];
        [self.target addObserver:self
                      forKeyPath:subscription.keyPath
                         options:options
                         context:(__bridge void *)(subscription)];
        if (subscription.subscriptionStartedHandler)
        {
            subscription.subscriptionStartedHandler(subscription);
        }
        [subscription publisherActivatedSubscription:self];
    }
}

- (void)stopObservingChangesForSubscription:(AKAKVOSubscription*)subscription
{
    if (subscription.isActive)
    {
        [self.target removeObserver:self
                         forKeyPath:subscription.keyPath
                            context:(__bridge void *)(subscription)];
        [self.activeSubscriptions removeObject:subscription];
        [subscription publisherDeactivatedSubscription:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.target)
    {
        id contextItem = (__bridge id)(context);
        if ([contextItem isKindOfClass:[AKAKVOSubscription class]])
        {
            AKAKVOSubscription* subscription = (AKAKVOSubscription*)contextItem;
            [self observeValueForSubscription:subscription
                                       change:change];
        }
    }
}

- (void)observeValueForSubscription:(AKAKVOSubscription*)subscription
                             change:(NSDictionary*)change
{
    AKAKVOChangeEvent* event = [[AKAKVOChangeEvent alloc] initWithSubscription:subscription
                                                                        change:change];
    event.subscription.valueWillChangeHandler(event);
}

@end

