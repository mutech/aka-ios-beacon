//
//  AKAArrayComparer.m
//  AKACommons
//
//  Created by Michael Utech on 25.07.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAArrayComparer.h"

@interface AKAArrayComparer()

@property(nonatomic, readonly, nonnull) NSDictionary<id, NSNumber*>* oldIndexesByItems;
@property(nonatomic, readonly, nonnull) NSDictionary<id, NSNumber*>* indexesByItems;

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
    }
    return self;
}

#pragma mark - Properties

#pragma mark - Analysis

@synthesize oldIndexesByItems = _oldIndexesByItems;
- (NSDictionary<id, NSNumber*>*)oldIndexesByItems
{
    if (_oldIndexesByItems == nil)
    {
        // Record old indexes by items
        NSMutableDictionary* oldIndexesByItems = [NSMutableDictionary new];
        for (NSInteger i=(NSInteger)self.oldArray.count - 1; i >= 0; --i)
        {
            id item = self.oldArray[(NSUInteger)i];
            oldIndexesByItems[item] = @(i);
        }
        _oldIndexesByItems = oldIndexesByItems;
    }
    return _oldIndexesByItems;
}

@synthesize indexesByItems = _indexesByItems;
- (NSDictionary<id,NSNumber *> *)indexesByItems
{
    if (_indexesByItems == nil)
    {
        [self recordInsertions];
    }
    return _indexesByItems;
}

@synthesize deletedItemIndexes = _deletedItemIndexes;
- (NSIndexSet *)deletedItemIndexes
{
    if (_deletedItemIndexes == nil)
    {
        [self recordDeletions];
    }
    return _deletedItemIndexes;
}

@synthesize insertedItemIndexes = _insertedItemIndexes;
- (NSIndexSet *)insertedItemIndexes
{
    if (_insertedItemIndexes == nil)
    {
        [self recordInsertions];
    }
    return _insertedItemIndexes;
}

@synthesize arrayWithoutInsertions = _arrayWithoutInsertions;
- (NSArray *)arrayWithoutInsertions
{
    if (_arrayWithoutInsertions == nil)
    {
        [self recordInsertions];
    }
    return _arrayWithoutInsertions;
}

@synthesize oldArrayWithDeletionsApplied = _oldArrayWithDeletionsApplied;
- (NSArray *)oldArrayWithDeletionsApplied
{
    if (_oldArrayWithDeletionsApplied == nil)
    {
        [self recordDeletions];
    }
    return _oldArrayWithDeletionsApplied;
}

@synthesize permutationAfterDeletionsAndBeforeInsertions = _permutationAfterDeletionsAndBeforeInsertions;
- (NSArray<NSNumber *> *)permutationAfterDeletionsAndBeforeInsertions
{
    if (_permutationAfterDeletionsAndBeforeInsertions == nil)
    {
        [self recordMovements];
    }
    return _permutationAfterDeletionsAndBeforeInsertions;
}

- (void)recordInsertions
{
    // Analyze new array identifying insertions
    NSMutableDictionary* indexesByItems = [NSMutableDictionary new];
    NSMutableIndexSet* insertedItemIndexes = [NSMutableIndexSet new];
    //NSMutableSet* insertedItems = [NSMutableSet new]; // not needed
    NSMutableArray* newArrayWithoutInsertions = [NSMutableArray new];

    for (NSInteger i=(NSInteger)self.array.count - 1; i >= 0; --i)
    {
        id item = self.array[(NSUInteger)i];

        NSNumber* oldIndex = self.oldIndexesByItems[item];
        if (oldIndex == nil)
        {
            // Record inserted item
            [insertedItemIndexes addIndex:(NSUInteger)i];
            //[insertedItems addObject:item];
        }
        else
        {
            // Record item that was already in old array but possibly at a different position.
            [newArrayWithoutInsertions insertObject:item atIndex:0];
        }
        indexesByItems[item] = @(i);
    }
    _indexesByItems = indexesByItems;
    _insertedItemIndexes = insertedItemIndexes;
    _arrayWithoutInsertions = newArrayWithoutInsertions;
}

- (void)recordDeletions
{
    // Record deletion indexes
    NSMutableArray* oldArrayWithDeletionsApplied = [NSMutableArray new];
    NSMutableIndexSet* deletedItemIndexes = [NSMutableIndexSet new];
    for (NSInteger i=(NSInteger)self.oldArray.count - 1; i >= 0; --i)
    {
        id item = self.oldArray[(NSUInteger)i];

        NSNumber* newIndex = self.indexesByItems[item];
        if (newIndex == nil)
        {
            [deletedItemIndexes addIndex:(NSUInteger)i];
        }
        else
        {
            [oldArrayWithDeletionsApplied insertObject:item atIndex:0];
        }
    }
    _deletedItemIndexes = deletedItemIndexes;
    _oldArrayWithDeletionsApplied = oldArrayWithDeletionsApplied;
}

- (void)recordMovements
{
    // Scan for reordered items
    NSAssert(self.oldArrayWithDeletionsApplied.count == self.arrayWithoutInsertions.count,
             @"Intermediate representation inconsistent");
    NSMutableArray* oldArrayWithDeletionsApplied = [NSMutableArray arrayWithArray:self.oldArrayWithDeletionsApplied];

    NSMutableIndexSet* inserted = [NSMutableIndexSet new];
    NSMutableIndexSet* deleted = [NSMutableIndexSet new];

    NSMutableArray* permutationAfterDeletionsAndBeforeInsertions = [NSMutableArray new];
    for (NSUInteger i=0; i < self.arrayWithoutInsertions.count; ++i)
    {
        id item = self.arrayWithoutInsertions[i];
        NSUInteger oldIndex = [oldArrayWithDeletionsApplied indexOfObject:item];
        NSUInteger currentOldIndex =
            (oldIndex
             - [deleted  countOfIndexesInRange:NSMakeRange(0, oldIndex)]
             + [inserted countOfIndexesInRange:NSMakeRange(0, i)]);

        permutationAfterDeletionsAndBeforeInsertions[i] = @(currentOldIndex - i);
        if (currentOldIndex != i)
        {
            [inserted addIndex:i];
            [deleted addIndex:oldIndex];
        }
    }
    _permutationAfterDeletionsAndBeforeInsertions = permutationAfterDeletionsAndBeforeInsertions;
}

- (void)updateTableView:(UITableView*)tableView
                section:(NSUInteger)section
        deleteAnimation:(UITableViewRowAnimation)deleteAnimation
        insertAnimation:(UITableViewRowAnimation)insertAnimation
{
    [tableView beginUpdates];

    // Deletions
    NSMutableArray* deletedIndexPaths = [NSMutableArray new];
    [self.deletedItemIndexes enumerateIndexesWithOptions:NSEnumerationReverse
                                              usingBlock:
     ^(NSUInteger idx, BOOL * _Nonnull stop)
     {
         (void)stop;
         [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:(NSInteger)idx
                                                         inSection:(NSInteger)section]];
     }];
    [tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:deleteAnimation];

    // Movements
    for (NSUInteger targetIndex=0;
         targetIndex < self.permutationAfterDeletionsAndBeforeInsertions.count;
         ++targetIndex)
    {
        NSUInteger offset = [self.permutationAfterDeletionsAndBeforeInsertions[targetIndex] unsignedIntegerValue];
        if (offset != 0)
        {
            NSIndexPath* source = [NSIndexPath indexPathForRow:(NSInteger)(targetIndex + offset)
                                                     inSection:(NSInteger)section];
            NSIndexPath* target = [NSIndexPath indexPathForRow:(NSInteger)targetIndex
                                                     inSection:(NSInteger)section];
            [tableView moveRowAtIndexPath:source toIndexPath:target];
        }
    }

    // Insertions
    NSMutableArray* insertedIndexPaths = [NSMutableArray new];
    [self.insertedItemIndexes enumerateIndexesWithOptions:NSEnumerationReverse
                                               usingBlock:
     ^(NSUInteger idx, BOOL * _Nonnull stop)
     {
         (void)stop;
         NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)idx inSection:(NSInteger)section];
         [insertedIndexPaths addObject:indexPath];
     }];
    [tableView insertRowsAtIndexPaths:insertedIndexPaths withRowAnimation:insertAnimation];

    [tableView endUpdates];
}

@end
