//
//  AKAKVOPublisher_Internal.h
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAKVOPublisher.h"

@interface AKAKVOPublisher ()

#pragma mark - Initialization

/**
 * Creates a new KeyValueObserving publisher for the specified target object using
 * the specified notificationQueue to dispatch (non-prior) change events (unless
 * subscriptions specify their own queue).
 *
 * Remark: It seems to generate more problems than it solves to dispatch notifications to a
 * predefined queue. For this reason all related features were moved to internal headers.
 *
 * @param target the defined object to be observed.
 * @param notificationQueue the notification queue used to dispatch valueDidChange events in the absence of a subscriber defined queue. If nil, all notifications are send from threads triggering change notifications.
 *
 * @return a new publisher
 */
+ (AKAKVOPublisher*)publisherForTarget:(NSObject*)target
              defaultNotificationQueue:(dispatch_queue_t)notificationQueue;

#pragma mark - Properties

/**
 * The queue, to which valueDidChange notifications are dispatched
 * if a subscription does not specify a notificationQueue. If neither a default
 * nor a subscription notificationQueue are specified, notifications are send
 * from the thread which triggered the KVO change event.
 *
 * Remark: It seems to generate more problems than it solves to dispatch notifications to a
 * predefined queue. For this reason all related features were moved to internal headers.
 */
@property(nonatomic, readonly)dispatch_queue_t defaultNotificationQueue;

#pragma mark - Subscriptions

/**
 * Subscribes events for changes to the target's item at the specified keyPath using KeyValueOberservation.
 *
 * Remark: It seems to generate more problems than it solves to dispatch notifications to a
 * predefined queue. For this reason all related features were moved to internal headers.
 *
 * @param keyPath the defined and valid keyPath identifying the observed item relative to the publishers target object.
 * @param notificationQueue the notification queue to which all valueDidChange events are dispatched.
 * @param subscriptionStarted called (in the current thread) right after the KVO observer has been added to the target.
 * @param valueWillChange called before a change is made to the specified item. The handler is called from the thread effecting the change.
 * @param valueDidChange called after a change is made to the specified item. The called is dispatched to the notificationQueue or - if nil - to the publishers default notification queue. If that is also nil, the handler will be called from the thread effecting the change.
 * @param provideOldValue whether the event describing the change should include the old value.
 * @param provideNewValue whether the event describing the change should include the new value.
 *
 * @return A subscription instance owned and managed by this publisher.
 */
- (AKAKVOSubscription*)subscribeToKeyPath:(NSString*)keyPath
                        notificationQueue:(dispatch_queue_t)notificationQueue
                      subscriptionStarted:(void(^)(AKAKVOSubscription* s))subscriptionStarted
                          valueWillChange:(void(^)(AKAKVOChangeEvent* e))valueWillChange
                           valueDidChange:(void(^)(AKAKVOChangeEvent* e))valueDidChange
                          provideOldValue:(BOOL)provideOldValue
                          provideNewValue:(BOOL)provideNewValue;

@end
