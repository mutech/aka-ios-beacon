//
//  AKAArrayComparer.m
//  AKACommons
//
//  Created by Michael Utech on 25.07.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAArrayComparer.h"

@interface AKAArrayComparer()

@property(nonatomic, strong)NSMutableDictionary* oldIndexesByItems;
@property(nonatomic, strong)NSMutableDictionary* indexesByItems;
@property(nonatomic, strong)NSMutableIndexSet* deletedItemIndexes;
@property(nonatomic, strong)NSMutableIndexSet* insertedItemIndexes;

@end

@implementation AKAArrayComparer

#pragma mark - Initialization

- (id)initWithOldArray:(NSArray *)oldArray newArray:(NSArray *)newArray
{
    NSParameterAssert(oldArray != nil);
    NSParameterAssert(newArray != nil);

    if (self = [self init])
    {
        _oldArray = oldArray;
        _array = newArray;

        [self analyzeArrays];
    }
    return self;
}

#pragma mark - Properties

#pragma mark - Analysis

- (void)analyzeArrays
{
    self.oldIndexesByItems = NSMutableDictionary.new;
    for (NSInteger i=self.oldArray.count - 1; i >= 0; --i)
    {
        id item = self.oldArray[i];
        self.oldIndexesByItems[item] = @(i);
    }

    self.indexesByItems = NSMutableDictionary.new;
    for (NSInteger i=self.array.count - 1; i >= 0; --i)
    {
        id item = self.array[i];

        NSNumber* oldIndex = self.oldIndexesByItems[item];
        if (oldIndex == nil)
        {
            [self.insertedItemIndexes addIndex:i];
        }
        self.indexesByItems[item] = @(i);
    }

    for (NSInteger i=self.oldArray.count - 1; i >= 0; --i)
    {
        id item = self.oldArray[i];
        NSNumber* newIndex = self.indexesByItems[item];
        if (newIndex == nil)
        {
            [self.deletedItemIndexes addIndex:i];
        }
    }

}

@end
