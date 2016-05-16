//
//  AKAKVOPublisher.h
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKAKVOSubscription.h"
#import "AKAKVOChangeEvent.h"
#import "NSObject+AKAConcurrencyTools.h" // Convenience methods

@interface AKAKVOPublisher : NSObject

#pragma mark - Initialization

/**
 * Creates a new KeyValueObserving publisher for the specified target object.
 *
 * @param target the defined object to be observed.
 *
 * @return a new publisher
 */
+ (AKAKVOPublisher*)publisherForTarget:(NSObject*)target;


#pragma mark - Properties

/**
 * The target object to be observed by subscribers.
 */
@property(nonatomic, readonly)NSObject* target;

#pragma mark - Subscriptions

/**
 * Subscribes events for changes to the target's item at the specified keyPath using KeyValueOberservation.
 *
 *
 * @param keyPath the defined and valid keyPath identifying the observed item relative to the publishers target object.
 * @param subscriptionStarted called right after the KVO observer has been added to the target.
 * @param valueWillChange called before a change is made to the specified item.
 * @param valueDidChange called after a change is made to the specified item.
 * @param provideOldValue whether the event describing the change should include the old value.
 * @param provideNewValue whether the event describing the change should include the new value.
 *
 * @return A subscription instance owned and managed by this publisher.
 */
- (AKAKVOSubscription*)subscribeToKeyPath:(NSString*)keyPath
                      subscriptionStarted:(void(^)(AKAKVOSubscription* s))subscriptionStarted
                          valueWillChange:(void(^)(AKAKVOChangeEvent* e))valueWillChange
                           valueDidChange:(void(^)(AKAKVOChangeEvent* e))valueDidChange
                          provideOldValue:(BOOL)provideOldValue
                          provideNewValue:(BOOL)provideNewValue;

/**
 * Subscribes events for changes to the target's item at the specified keyPath using KeyValueOberservation. Provides new and old values in the change event.
 *
 * @param keyPath the defined and valid keyPath identifying the observed item relative to the publishers target object.
 * @param subscriptionStarted called right after the KVO observer has been added to the target.
 * @param valueDidChange called after a change is made to the specified item.
 *
 * @return A subscription instance owned and managed by this publisher.
 */
- (AKAKVOSubscription*)subscribeToKeyPath:(NSString*)keyPath
                      subscriptionStarted:(void(^)(AKAKVOSubscription* s))subscriptionStarted
                           valueDidChange:(void(^)(AKAKVOChangeEvent* e))valueDidChange;

/**
 * Subscribes events for changes to the target's item at the specified keyPath using KeyValueOberservation. Provides new and old values in the change event.
 *
 * @param keyPath the defined and valid keyPath identifying the observed item relative to the publishers target object.
 * @param valueDidChange called after a change is made to the specified item.
 *
 * @return A subscription instance owned and managed by this publisher.
 */
- (AKAKVOSubscription*)subscribeToKeyPath:(NSString*)keyPath
                           valueDidChange:(void(^)(AKAKVOChangeEvent* e))valueDidChange;

- (BOOL)enumerateActiveSubscriptionsUsingBlock:(void(^)(AKAKVOSubscription* subscription, BOOL* stop))block;
- (BOOL)enumerateSuspendedSubscriptionsUsingBlock:(void(^)(AKAKVOSubscription* subscription, BOOL* stop))block;
- (BOOL)enumerateSubscriptionsUsingBlock:(void(^)(AKAKVOSubscription* subscription, BOOL* stop))block;


- (void)suspendAllActiveSubscriptions;
- (void)suspendSubscription:(AKAKVOSubscription*)subscription;

- (void)resumeAllSuspendedSubscriptions;
- (void)resumeSubscription:(AKAKVOSubscription*)subscription;

- (void)cancelAllSubscriptions;
- (void)cancelSubscription:(AKAKVOSubscription*)subscription;

@end
