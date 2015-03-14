//
//  AKAKVOChangeEvent.m
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAKVOChangeEvent.h"
#import "AKAKVOSubscription.h"

@interface AKAKVOChangeEvent()
@property(nonatomic, readonly)NSDictionary* change;
@property(nonatomic, readonly)NSKeyValueChange changeKind;
@end

@implementation AKAKVOChangeEvent

@synthesize subscription = _subscription;
@synthesize change = _change;

#pragma mark - Initialization

- (instancetype)initWithSubscription:(AKAKVOSubscription *)subscription
                              change:(NSDictionary *)change
{
    self = [super init];
    if (self)
    {
        _subscription = subscription;
        _change = change;
    }
    return self;
}

- (BOOL)isPriorNotification
{
    return ((NSNumber*)self.change[NSKeyValueChangeNotificationIsPriorKey]).boolValue;
}

#pragma mark - Properties

- (AKAKVOSubscription *)subscription { return _subscription; }
- (NSDictionary *)change { return _change; }

#pragma mark - Change kind

- (NSKeyValueChange)changeKind
{
    return ((NSNumber*)self.change[NSKeyValueChangeKindKey]).unsignedIntegerValue;
}

- (BOOL)isValueSettingChange
{
    return self.changeKind == NSKeyValueChangeSetting;
}

- (BOOL)isInsertionChange
{
    return self.changeKind == NSKeyValueChangeInsertion;
}

- (BOOL)isRemovalChange
{
    return self.changeKind == NSKeyValueChangeRemoval;
}

- (BOOL)isReplacementChange
{
    return self.changeKind == NSKeyValueChangeReplacement;
}

#pragma mark - Old and new value for value setting changes

- (BOOL)hasOldValue
{
    return self.subscription.providesOldValue && self.change[NSKeyValueChangeOldKey] != nil;
}

- (BOOL)hasNewValue
{
    return self.subscription.providesNewValue && self.change[NSKeyValueChangeNewKey];
}

- (id)oldValue
{
    id result = self.change[NSKeyValueChangeOldKey];
    return result == [NSNull null] ? nil : result;
}

- (id)value
{
    id result = self.change[NSKeyValueChangeNewKey];
    return result == [NSNull null] ? nil : result;
}

#pragma mark - Old and new value for collection changes

- (BOOL)hasIndexes
{
    return !self.isValueSettingChange;
}

- (BOOL)hasOldValues
{
    return self.hasIndexes && self.hasOldValue;
}

- (BOOL)hasNewValues
{
    return self.hasIndexes && self.hasNewValues;
}

- (NSArray*)oldValues
{
    NSArray* result = nil;
    id oldValue = self.oldValue;
    if ([oldValue isKindOfClass:[NSArray class]])
    {
        result = (NSArray*)oldValue;
    }
    return result;
}

- (NSArray*)values
{
    NSArray* result = nil;
    id value = self.value;
    if ([value isKindOfClass:[NSArray class]])
    {
        result = (NSArray*)value;
    }
    return result;
}

@end

