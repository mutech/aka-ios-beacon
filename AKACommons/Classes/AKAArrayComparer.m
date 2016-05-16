//
//  AKAArrayComparer.m
//  AKACommons
//
//  Created by Michael Utech on 25.07.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAArrayComparer.h"

@interface AKAArrayComparer()

@end

@implementation AKAArrayComparer

#pragma mark - Initialization

- (id)initWithOldArray:(NSArray *)oldArray newArray:(NSArray *)newArray
{
    if (self = [self init])
    {
        _oldArray = oldArray ? oldArray : @[];
        _array = newArray ? newArray : @[];
    }
    return self;
}

#pragma mark - Properties

#pragma mark - Analysis

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
    if (_permutationAfterDeletionsAndBeforeInsertions.count == 0)
    {
        [self recordMovements];
    }
    return _permutationAfterDeletionsAndBeforeInsertions;
}

- (void)recordInsertions
{
    // Analyze new array identifying insertions
    NSMutableIndexSet* insertedItemIndexes = [NSMutableIndexSet new];
    NSMutableArray* newArrayWithoutInsertions = [NSMutableArray new];

    for (NSInteger i=(NSInteger)self.array.count - 1; i >= 0; --i)
    {
        id item = self.array[(NSUInteger)i];

        NSUInteger oldIndex = [self.oldArray indexOfObject:item];
        if (oldIndex == NSNotFound)
        {
            // Record inserted item
            [insertedItemIndexes addIndex:(NSUInteger)i];
        }
        else
        {
            // Record item that was already in old array but possibly at a different position.
            [newArrayWithoutInsertions insertObject:item atIndex:0];
        }
    }
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

        NSUInteger newIndex = [self.array indexOfObject:item];
        if (newIndex == NSNotFound)
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
    // Note: this implementation ensures that each item that changed its position is moved instead of trying to minimize the number of movements. When it becomes important to optimize this code, please check that optimizations won't break such dependencies. (See AKABinding_UITableView_dataSourceBinding for dynamic sections and applyChangesToTransformedArray:::: for an example of such a dependency)

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

- (NSArray*)movementsForTableViews
{
    // Movement coordinate for table views are appearantly agnostic of deletions and insertions done
    // in the same begin/endUpdate batch.
    NSMutableArray* permutation = [NSMutableArray new];
    for (NSUInteger i=0; i < self.array.count; ++i)
    {
        if ([self.insertedItemIndexes containsIndex:i])
        {
            permutation[i] = @(0);
        }
        else
        {
            id item = self.array[i];
            NSUInteger oldIndex = [self.oldArray indexOfObject:item];
            permutation[i] = @(oldIndex - i);
        }
    }
    return permutation;
}

- (void)applyChangesToTransformedArray:(NSMutableArray*)transformed
               blockBeforeDeletingItem:(void(^)(id deletedItem))blockBeforeDeleteItem
                 blockMappingMovedItem:(id(^)(id sourceItem, id transformedItem, NSUInteger oldIndex, NSUInteger newIndex))blockMappingMovedItem
              blockMappingInsertedItem:(id(^)(id newSourceItem, NSUInteger index))blockMappingInsertedItem
{
    // Note: Relies on implementation of recordMovements to move all items that changed its position

    // Apply deletions
    [self.deletedItemIndexes enumerateIndexesWithOptions:NSEnumerationReverse
                                              usingBlock:
     ^(NSUInteger idx, BOOL * _Nonnull __unused stop)
     {
         if (blockBeforeDeleteItem != NULL)
         {
             blockBeforeDeleteItem(transformed[idx]);
         }
         [transformed removeObjectAtIndex:idx];
     }];

    // Apply movements
    for (NSUInteger i=0; i < transformed.count; ++i)
    {
        NSUInteger offset = self.permutationAfterDeletionsAndBeforeInsertions[i].unsignedIntegerValue;
        if (offset != 0)
        {
            NSAssert(offset > 0, @"Unexpected negative offset in permutation");

            NSUInteger sourceIndex = i + offset;

            id sourceItem = self.oldArrayWithDeletionsApplied[sourceIndex];
            NSUInteger oldIndex = [self.oldArray indexOfObject:sourceItem];
            NSUInteger newIndex = [self.array indexOfObject:sourceItem];

            id transformedItem = transformed[sourceIndex];

            if (blockMappingMovedItem != NULL)
            {
                transformedItem = blockMappingMovedItem(sourceItem, transformedItem,
                                                        oldIndex, newIndex);
            }
            [transformed removeObjectAtIndex:sourceIndex];
            [transformed insertObject:transformedItem atIndex:i];
        }
    }

    // Apply insertions
    [self.insertedItemIndexes enumerateIndexesUsingBlock:
     ^(NSUInteger idx, BOOL * _Nonnull stop __unused) {
         id item = self.array[idx];

         if (blockMappingInsertedItem != NULL)
         {
             item = blockMappingInsertedItem(item, idx);
         }

         [transformed insertObject:item atIndex:idx];
     }];
}

- (void)updateTableView:(UITableView*)tableView
                section:(NSUInteger)section
        deleteAnimation:(UITableViewRowAnimation)deleteAnimation
        insertAnimation:(UITableViewRowAnimation)insertAnimation
{
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
    NSArray* permutation = [self movementsForTableViews];
    for (NSUInteger targetIndex=0;
         targetIndex < permutation.count;
         ++targetIndex)
    {
        NSInteger offset = [permutation[targetIndex] integerValue];
        if (offset != 0)
        {
            NSIndexPath* source = [NSIndexPath indexPathForRow:(NSInteger)targetIndex + offset
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
}

- (void)enumerateRelocatedItemsUsingBlock:(void (^)(id _Nonnull, NSUInteger, NSUInteger))block
{
    for (NSUInteger i=0; i < self.oldArray.count; ++i)
    {
        if (![self.deletedItemIndexes containsIndex:i])
        {
            id item = self.oldArray[i];
            if (i < self.array.count && self.array[i] != item)
            {
                // TODO: check if it's more efficient to use inserted/deleted/moved data gathered elsewhere
                NSUInteger newIndex = [self.array indexOfObject:item];

                block(item, i, newIndex);
            }
        }
    }
}

@end
