//
//  AKAKVOChangeEvent.h
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKAKVOSubscription;


/**
 * Wrapper for the KVO change specification including subscription information.
 */
@interface AKAKVOChangeEvent: NSObject

- (instancetype)initWithSubscription:(AKAKVOSubscription*)subscription
                              change:(NSDictionary*)change;

/**
 * The subscription receiving the event via one of the specified handlers.
 */
@property(nonatomic, weak)AKAKVOSubscription* subscription;

#pragma mark -
/**
 * Indicates whether the change will happen (YES) or was already effected (NO).
 */
@property(nonatomic, readonly)BOOL  isPriorNotification;

#pragma mark - Change kind

/**
 * Indicates whether the change is the modification of an attribute or relation.
 */
@property(nonatomic, readonly)BOOL          isValueSettingChange;

/**
 * Indicates whether the change is the insertion of elements into a relation.
 */
@property(nonatomic, readonly)BOOL          isInsertionChange;

/**
 * Indicates whethr the change is the removal of elements from a relation.
 */
@property(nonatomic, readonly)BOOL          isRemovalChange;

/**
 * Indicates whether the change is the replacement of elements of a relation.
 */
@property(nonatomic, readonly)BOOL          isReplacementChange;

#pragma mark - Old and new value for value setting changes

/**
 * Indicates whether the event provides the old value.
 */
@property(nonatomic, readonly)BOOL          hasOldValue;

/**
 * Indicates whether the event provides the new value.
 */
@property(nonatomic, readonly)BOOL          hasNewValue;
@property(nonatomic, readonly)id            oldValue;
@property(nonatomic, readonly)id            value;

#pragma mark - Old and new value for collection changes

@property(nonatomic, readonly)BOOL          hasIndexes;
@property(nonatomic, readonly)BOOL          hasOldValues;
@property(nonatomic, readonly)BOOL          hasNewValues;
@property(nonatomic, readonly)NSArray*      oldValues;
@property(nonatomic, readonly)NSArray*      values;
@property(nonatomic, readonly)NSIndexSet*   indexes;

@end

