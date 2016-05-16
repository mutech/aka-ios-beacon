//
//  AKAArrayComparer.h
//  AKACommons
//
//  Created by Michael Utech on 25.07.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
#import "AKANullability.h"

/**
 Tool to analyze differences between two arrays (based on NSObject isEqual:).
 
 The analysis assumes that the changes are the result of first deleting items from oldArray, then reordering items and finally inserting new items and represent comparison results accordingly.
 
 The intermediate states are represented by oldArrayWithDeletionsApplied and arrayWithoutInsertions (which contains all but the inserted items in the final order).
 
 The deletedItemIndexes are relative to oldArray.
 
 The permutationAfterDeletionsAndBeforeInsertions are relative to intermediate states.
 
 The insertedItemIndexes relative to the final array.

 */
@interface AKAArrayComparer : NSObject

#pragma mark - Initialization

- initWithOldArray:(req_NSArray)oldArray
          newArray:(req_NSArray)newArray;

#pragma mark - Original and updated arrays

/**
 The original array.
 */
@property(nonatomic, readonly, nonnull) NSArray* oldArray;

/**
 The updated array
 */
@property(nonatomic, readonly, nonnull) NSArray* array;

#pragma mark - Intermediate arrays
/**
 Intermediate array obtained by removing all items from old array which are not contained in the updated array.
 */
@property(nonatomic, readonly, nonnull) NSArray* oldArrayWithDeletionsApplied;

/**
 Intermediate array obtained by removing all items from the updated array which are not contained in oldArray.
 */
@property(nonatomic, readonly, nonnull) NSArray* arrayWithoutInsertions;

#pragma mark - Deletions, Movements and Insertions

/**
 The set of array indexes of items in oldArray which are not contained in the updated array.
 */
@property(nonatomic, readonly, nonnull) NSIndexSet* deletedItemIndexes;

/**
 The set of array indexes of items in the updated array which are not contained in oldArray.
 */
@property(nonatomic, readonly, nonnull) NSIndexSet* insertedItemIndexes;

/**
 When iterating over items in arrayWithoutInsertions starting from index 0, the permutation array contains the offset in oldArrayWithDeletionsApplied. If the offset is 0, the item did not move, otherwise, the offset specifies how many positions the item moved from oldArrayWithDeletionsApplied to its final position. Offsets in subsequent items account for previous movements (meaning that the n-th offset is relative to oldArrayWithDeletionsApplied where the first n - 1 elements have already been rearranged to match arrayWithoutInsertions).
 
 Because movements are processed in ascending order of the final result and account for previous movements, offsets cannot be negative.
 
 See AKAArrayComparerTests::testReplay and the implementation of updateTableView:section:deleteAnimation:insertAnimation: for examples how to use this data.
 */
@property(nonatomic, readonly, nonnull) NSArray<NSNumber*>* permutationAfterDeletionsAndBeforeInsertions;

@property(nonatomic, readonly, nonnull) NSArray<NSNumber*>* movementsForTableViews;

#pragma mark - Table View Updates

/**
 Updates the table view's section with the specified section-index to account for the changes applied to derive array from oldArray. Updates are performed in this order:
 
 1) Deletions of items no longer contained in array
 
 2) Reordering or items contained in both oldArray and array (movements happen in the sequence so that the item with the lowest index which has been moved is processed first)
 
 3) Insertions of items that were not contained in oldArray, starting from the last insertion (highest index).

 @note Callers have to ensure that this method call is embedded in begin/endUpdates

 @param tableView       the table view to update
 @param section         the section to update
 @param deleteAnimation the row animation to use for deletions
 @param insertAnimation the row animation to use for insertions
 */
- (void)updateTableView:(req_UITableView)tableView
                section:(NSUInteger)section
        deleteAnimation:(UITableViewRowAnimation)deleteAnimation
        insertAnimation:(UITableViewRowAnimation)insertAnimation;

#pragma mark - Transformed Arrays

/**
 Applies changes made between old and new array to a third mutable array that contains items obtained
 by mapping array items. More formally, if the transformed array is:
 
 `{ x in OLD | f(x) }`
 
 then applying changes will lead to the transformed array being:
 
 `{ x in NEW | f(x) }`

 @param transformed              A mutable array containing mapped old array items
 @param blockBeforeDeleteItem    Called before an item is removed from the transformed array
 @param blockMappingMovedItem    Called before an item is moved in the transformed array. The block has to return the moved item or a replacement
 @param blockMappingInsertedItem Called before an item is inserted. The block has to return the mapped item.
 */
- (void)applyChangesToTransformedArray:(NSMutableArray* _Nonnull)transformed
               blockBeforeDeletingItem:(void(^_Nullable)(req_id deletedItem))blockBeforeDeleteItem
                 blockMappingMovedItem:(req_id(^_Nullable)(req_id sourceItem, req_id transformedItem, NSUInteger oldIndex, NSUInteger newIndex))blockMappingMovedItem
              blockMappingInsertedItem:(req_id(^_Nullable)(req_id newSourceItem, NSUInteger index))blockMappingInsertedItem;

#pragma mark - Relocated items

/**
 Enumerates all items that are contained in both the old and new array and changed their location due to insertions, deletions or movements.

 @param block a block taking the item and its old and new index
 */
- (void)enumerateRelocatedItemsUsingBlock:(void(^_Nonnull)(req_id item, NSUInteger oldIndex, NSUInteger newIndex))block;

@end
