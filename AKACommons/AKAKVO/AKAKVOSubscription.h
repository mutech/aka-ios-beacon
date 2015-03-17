//
//  AKAKVOSubscription.h
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKAKVOPublisher;
@class AKAKVOChangeEvent;

@interface AKAKVOSubscription: NSObject

/**
 * The publisher issuing the subscription.
 */
@property(nonatomic, weak)AKAKVOPublisher* publisher;

/**
 * The keypath specifying the observed item relative to the publishers target object.
 */
@property(nonatomic, readonly)NSString* keyPath;

/**
 * Indicates whether the subscription is active and change notifications will be send.
 */
@property(nonatomic, readonly)BOOL isActive;

/**
 * Called when the subscription is activated (prior in KVO terms).
 */
@property(nonatomic, readonly) void(^subscriptionStartedHandler)(AKAKVOSubscription* s);

/**
 * Called before a change to the observed item's value is effected.
 */
@property(nonatomic, readonly) void(^valueWillChangeHandler)(AKAKVOChangeEvent* e);

/**
 * Called after the value of the observed item was changed.
 */
@property(nonatomic, readonly) void(^valueDidChangeHandler)(AKAKVOChangeEvent* e);

@property(nonatomic, readonly) BOOL providesOldValue;
@property(nonatomic, readonly) BOOL providesNewValue;

/**
 * Queries the current value of the subcriptions target item using the keyPath relative
 * to the publishers target object.
 */
@property(nonatomic) id value;

/**
 * Suspends change notification to handlers temporarily. The subscription can subsequently
 * be resumed. Has no effect if the subscription is inactive (already resumed or
 * cancelled).
 */
- (void)suspendSubscription;

/**
 * Resumes a previously suspended subscription. Has no effect if the subscription is active
 * or if it was cancelled before.
 */
- (void)resumeSubscription;

/**
 * Cancels the subscription and resets handlers (to release resources potitially bound to
 * handler blocks). A cancelled subscription cannot be resumed or otherwise reactivated.
 * If only the publisher holds a reference to the subscription, the instance will be
 * released.
 */
- (void)cancelSubscription;

@end
