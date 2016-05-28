//
//  AKATVUpdateBatch.m
//  AKACommons
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATVUpdateBatch.h"
#import "AKALog.h"

@implementation AKATVUpdateBatch

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init])
    {
        _depth = 0;
    }
    return self;
}

#pragma mark Begin and End Updates

- (void)beginUpdatesForTableView:(UITableView*)tableView
{
    UITableView* tv = tableView;   // (multiple references to weak item)
    NSAssert(self.depth == 0 ? _tableView == nil : YES, @"%@: Internal inconsistency, tableView has to be nil if depth is 0", self);

    if (self.depth == 0)
    {
        _tableView = tv;
        _deletedSections = [NSMutableIndexSet new];
        _insertedSections = [NSMutableIndexSet new];
        _deletedRows = [NSMutableDictionary new];
        _insertedRows = [NSMutableDictionary new];
    }

    ++_depth;
    [tableView beginUpdates];
}

- (void)endUpdatesForTableView:(UITableView*)tableView
{
    NSParameterAssert(tableView == _tableView);
    if (self.depth == 1)
    {
        _tableView = nil;
        _deletedSections = nil;
        _insertedSections = nil;
        _deletedRows = nil;
        _insertedRows = nil;
    }
    --_depth;
    
    [tableView endUpdates];
}

#pragma mark - Insertions and Deletions of Sections

//
// iOS reorders updates such that deletions are performed (in the issued order) before any
// insertions are performed. Indexes of deletions are affected by previous deletions but not
// by insertions.
// Insertion indexes take into account all deletions and previously issued insertions.
//
// To undo this mess:
// - deletion indexes have to be corrected if any previous deletions or insertions are made to rows
//   preceeding a row to be deleted. Previously inserted indexes have to be corrected.
// - insertion indexes have to be corrected if any previous deletions or insertion are make to rows
//   preceeding a row to be inserted.
//

- (void)recordDeletionOfSection:(NSInteger)sectionIndex
      forBatchUpdateInTableView:(UITableView*)tableView
{
    NSParameterAssert(sectionIndex >= 0);
    NSParameterAssert(tableView == _tableView);

    NSMutableIndexSet* deletions = self.deletedSections;
    NSUInteger precedingDeletions = [deletions countOfIndexesInRange:NSMakeRange(0, (NSUInteger)(sectionIndex + 1))];

    NSMutableIndexSet* insertions = self.insertedSections;
    NSUInteger precedingInsertions = [insertions countOfIndexesInRange:NSMakeRange(0, (NSUInteger)sectionIndex)];

    NSUInteger originalSectionIndex = (NSUInteger)sectionIndex + precedingDeletions - precedingInsertions;

    while ([deletions containsIndex:originalSectionIndex])
    {
        ++originalSectionIndex;
    }

    [deletions addIndex:originalSectionIndex];

    [insertions shiftIndexesStartingAtIndex:originalSectionIndex+1 by:-1];
}

- (void)recordInsertionOfSection:(NSInteger)sectionIndex
       forBatchUpdateInTableView:(UITableView*)tableView
{
    NSParameterAssert(tableView == _tableView);

    NSMutableIndexSet* insertions = self.insertedSections;
    [insertions shiftIndexesStartingAtIndex:(NSUInteger)sectionIndex by:1];
}

- (void)recordDeletionOfRowAtIndexPath:(NSIndexPath*)indexPath
             forBatchUpdateInTableView:(UITableView*)tableView
{
    NSParameterAssert(tableView == _tableView);

    NSUInteger rowIndex = (NSUInteger)indexPath.row;
    NSMutableIndexSet* deletions = [self deletedRowsInSection:indexPath.section
                                              createIfMissing:YES];
    NSUInteger precedingDeletions = [deletions countOfIndexesInRange:NSMakeRange(0, rowIndex + 1)];

    NSMutableIndexSet* insertions = [self insertedRowsInSection:indexPath.section
                                                createIfMissing:NO];
    NSUInteger precedingInsertions = [insertions countOfIndexesInRange:NSMakeRange(0, rowIndex)];

    NSUInteger originalRowIndex = rowIndex + precedingDeletions - precedingInsertions;

    while ([deletions containsIndex:originalRowIndex])
    {
        ++originalRowIndex;
    }

    [deletions addIndex:originalRowIndex];

    [insertions shiftIndexesStartingAtIndex:originalRowIndex+1 by:-1];
}

- (void)recordInsertionOfRowAtIndexPath:(NSIndexPath*)indexPath
              forBatchUpdateInTableView:(UITableView*)tableView
{
    NSParameterAssert(tableView == _tableView);

    NSInteger rowIndex = indexPath.row;
    NSMutableIndexSet* insertions = [self insertedRowsInSection:indexPath.section
                                                createIfMissing:YES];
    [insertions shiftIndexesStartingAtIndex:(NSUInteger)rowIndex by:1];
    [insertions addIndex:(NSUInteger)rowIndex];
}

- (NSMutableIndexSet*)deletedRowsInSection:(NSInteger)sectionIndex
                           createIfMissing:(BOOL)createIfMissing
{
    NSNumber* section = @(sectionIndex);
    NSMutableIndexSet* result = self.deletedRows[section];

    if (result == nil && createIfMissing)
    {
        result = [NSMutableIndexSet new];
        self.deletedRows[section] = result;
    }
    return result;
}

- (NSMutableIndexSet*)insertedRowsInSection:(NSInteger)sectionIndex
                            createIfMissing:(BOOL)createIfMissing
{
    NSNumber* section = @(sectionIndex);
    NSMutableIndexSet* result = self.insertedRows[section];


    if (result == nil && createIfMissing)
    {
        result = [NSMutableIndexSet new];
        self.insertedRows[section] = result;
    }
    return result;
}

#pragma mark - Public Interface

- (NSInteger)insertionIndexForSection:(NSInteger)sectionIndex
            forBatchUpdateInTableView:(UITableView*)tableView
                recordAsInsertedIndex:(BOOL)recordAsInserted
{
    // Determine the number of preceeding sections which have been previously deleted.
    // The specified sectionIndex is expected to account for all previous deletions
    // and that's what we have to undo.
    NSIndexSet* deletedSections = self.deletedSections;
    NSInteger deletedPrecedingSections = (NSInteger)[deletedSections countOfIndexesInRange:NSMakeRange(0, (NSUInteger)sectionIndex)];

    NSInteger result = sectionIndex + deletedPrecedingSections;

    if (recordAsInserted && self.depth > 0)
    {
        [self recordInsertionOfSection:result
             forBatchUpdateInTableView:tableView];
    }
    return result;
}

- (NSInteger)deletionIndexForSection:(NSInteger)sectionIndex
           forBatchUpdateInTableView:(UITableView*)tableView
               recordAsInsertedIndex:(BOOL)recordAsDeleted
{
    // Determine the number of preceeding sections which have been previously inserted.
    // The specified sectionIndex is expected to account for all previous insertions
    // and that's what we have to undo.
    NSIndexSet* insertedSections = self.insertedSections;
    NSUInteger insertedPrecedingSections = [insertedSections countOfIndexesInRange:NSMakeRange(0, (NSUInteger)sectionIndex)];

    NSInteger result = sectionIndex - (NSInteger)insertedPrecedingSections;

    if (recordAsDeleted && self.depth > 0)
    {
        [self recordDeletionOfSection:result forBatchUpdateInTableView:tableView];
    }
    return result;
}

- (NSIndexPath*)insertionIndexPathForRow:(NSInteger)rowIndex
                               inSection:(NSInteger)sectionIndex
               forBatchUpdateInTableView:(UITableView*)tableView
                   recordAsInsertedIndex:(BOOL)recordAsInserted
{
    NSIndexPath* result = nil;

    // Determine the number of preceeding rows which have been previously deleted.
    // The specified rowIndex is expected to account for all previous deletions
    // and that's what we have to undo.
    NSIndexSet* deletedRows = [self deletedRowsInSection:sectionIndex
                                         createIfMissing:NO];
    NSUInteger deletedPrecedingRows = [deletedRows countOfIndexesInRange:NSMakeRange(0, (NSUInteger)rowIndex)];

    NSIndexSet* insertedRows = [self insertedRowsInSection:sectionIndex
                                           createIfMissing:NO];
    NSUInteger insertedPrecedingRows = [insertedRows countOfIndexesInRange:NSMakeRange(0, (NSUInteger)rowIndex)];
    deletedPrecedingRows = (insertedPrecedingRows > deletedPrecedingRows) ? 0 : deletedPrecedingRows - insertedPrecedingRows;

    result = [NSIndexPath indexPathForRow:rowIndex + (NSInteger)deletedPrecedingRows inSection:sectionIndex];

    if (recordAsInserted && self.depth > 0)
    {
        [self recordInsertionOfRowAtIndexPath:result forBatchUpdateInTableView:tableView];
    }
    return result;
}

- (NSIndexPath*)deletionIndexPathForRow:(NSInteger)rowIndex
                              inSection:(NSInteger)sectionIndex
              forBatchUpdateInTableView:(UITableView*)tableView
                   recordAsDeletedIndex:(BOOL)recordAsDeleted
{
    NSIndexPath* result = nil;

    // Determine the number of preceeding rows which have been previously inserted.
    // The specified rowIndex is expected to account for all previous insertions
    // and that's what we have to undo.
    NSIndexSet* insertedRows = [self insertedRowsInSection:sectionIndex
                                           createIfMissing:NO];
    NSUInteger insertedPrecedingRows = [insertedRows countOfIndexesInRange:NSMakeRange(0, (NSUInteger)rowIndex)];

    result = [NSIndexPath indexPathForRow:rowIndex - (NSInteger)insertedPrecedingRows inSection:sectionIndex];

    if (recordAsDeleted && self.depth > 0)
    {
        [self recordDeletionOfRowAtIndexPath:result
                   forBatchUpdateInTableView:tableView];
    }
    return result;
}

- (void)    movementSourceRowIndex:(inout NSIndexPath*__autoreleasing*)sourceRowIndex
                    targetRowIndex:(inout NSIndexPath*__autoreleasing*)targetRowIndex
         forBatchUpdateInTableView:(UITableView*)tableView
                  recordAsMovedRow:(BOOL)recordAsMovedRow
{
    (void)sourceRowIndex;
    (void)targetRowIndex;
    (void)tableView;
    (void)recordAsMovedRow;
    // do nothing for now, it's not documented if movements also
    // are reordered inside of begin/endUpdate.
    
    // TODO: record movement or refactor the interface of this class alltogether
}

- (NSArray*)correctedIndexPaths:(NSArray*)indexPaths
{
    NSMutableArray* result = NSMutableArray.new;
    for (NSIndexPath* indexPath in indexPaths)
    {
        [result addObject:[self correctedIndexPath:indexPath]];
    }
    return result;
}

- (NSIndexPath*)correctedIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* result = nil;

    // Determine the number of preceeding rows which have been previously deleted.
    // The specified rowIndex is expected to account for all previous deletions
    // and that's what we have to undo.
    NSIndexSet* deletedRows = [self deletedRowsInSection:indexPath.section
                                         createIfMissing:NO];
    NSUInteger deletedPrecedingRows = [deletedRows countOfIndexesInRange:NSMakeRange(0, (NSUInteger)indexPath.row + 1)];

    NSIndexSet* insertedRows = [self insertedRowsInSection:indexPath.section
                                           createIfMissing:NO];
    NSUInteger insertedPrecedingRows = [insertedRows countOfIndexesInRange:NSMakeRange(0, (NSUInteger)indexPath.row)];
    deletedPrecedingRows = (insertedPrecedingRows > deletedPrecedingRows) ? 0 : deletedPrecedingRows - insertedPrecedingRows;

    result = [NSIndexPath indexPathForRow:indexPath.row + (NSInteger)deletedPrecedingRows inSection:indexPath.section];

    return result;
}

@end

