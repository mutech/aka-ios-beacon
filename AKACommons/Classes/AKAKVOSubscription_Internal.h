//
//  AKAKVOSubscription_Internal.h
//  proReport
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 Trinomica GmbH. All rights reserved.
//

#import "AKAKVOSubscription.h"

@class AKAKVOPublisher;

@interface AKAKVOSubscription (Internal)

#pragma mark - Initialization

- (instancetype)initWithPublisher:(AKAKVOPublisher*)publisher
                          keyPath:(NSString*)keyPath
                notificationQueue:(dispatch_queue_t)notificationQueue
              subscriptionStarted:(void(^)(AKAKVOSubscription* s))subscriptionStarted
                  valueWillChange:(void(^)(AKAKVOChangeEvent* e))valueWillChange
                   valueDidChange:(void(^)(AKAKVOChangeEvent* e))valueDidChange
                  provideOldValue:(BOOL)provideOldValue
                  provideNewValue:(BOOL)provideNewValue;

#pragma mark - Properties

- (dispatch_queue_t)notificationQueue;

#pragma mark - Subscription status updates

- (void)publisherActivatedSubscription:(AKAKVOPublisher*)publisher;
- (void)publisherDeactivatedSubscription:(AKAKVOPublisher*)publisher;
- (void)publisherCancelledSubscription:(AKAKVOPublisher*)publisher;

@end
