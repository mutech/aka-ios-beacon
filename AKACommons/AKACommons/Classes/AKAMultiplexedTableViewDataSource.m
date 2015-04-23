//
//  AKAMultiplexedTableViewDataSource.m
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAMultiplexedTableViewDataSource.h"
#import "AKATVDataSource.h"
#import "AKAReference.h"
#import "AKALog.h"
#import "AKAErrors.h"

#pragma mark - AKATVUpdateBatch
#pragma mark -

@interface AKATVUpdateBatch: NSObject

@property(nonatomic, readonly, weak) UITableView* tableView;
@property(nonatomic)NSUInteger depth;
@property(nonatomic, readonly) NSMutableIndexSet* insertedSections;
@property(nonatomic, readonly) NSMutableIndexSet* deletedSections;
@property(nonatomic, readonly) NSMutableDictionary* insertedRows;
@property(nonatomic, readonly) NSMutableDictionary* deletedRows;

@end

@implementation AKATVUpdateBatch
- (instancetype)init
{
    if (self = [super init])
    {
        _depth = 0;
    }
    return self;
}

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

@end

#pragma mark - AKATVRowSegment
#pragma mark -

@interface AKATVRowSegment: NSObject

- (instancetype)initWithDataSource:(AKATVDataSource*)dataSource
                             index:(NSUInteger)rowIndex
                             count:(NSUInteger)numberOfRows;

@property(nonatomic, readonly, weak) AKATVDataSource* dataSource;
@property(nonatomic, readonly) NSUInteger rowIndex;
@property(nonatomic, readonly) NSUInteger numberOfRows;

@end

@implementation AKATVRowSegment

#pragma mark - Initialization

- (instancetype)initWithDataSource:(AKATVDataSource*)dataSource
                             index:(NSUInteger)rowIndex
                             count:(NSUInteger)numberOfRows
{
    if (self = [self init])
    {
        _dataSource = dataSource;
        _rowIndex = rowIndex;
        _numberOfRows = numberOfRows;
    }
    return self;
}

- (AKATVRowSegment*)splitAtOffset:(NSUInteger)offset
{
    NSParameterAssert(offset > 0 && offset < self.numberOfRows);
    AKATVRowSegment* result =
    [[AKATVRowSegment alloc] initWithDataSource:self.dataSource
                                          index:self.rowIndex + offset
                                          count:self.numberOfRows - offset];
    _numberOfRows -= (self.numberOfRows - offset);
    return result;
}

/**
 * Removes up to numberOfRows rows from this segment, starting at the specified index
 * and returns the number of rows which have not been removed.
 *
 * If the removal leaves trailing rows, a new segment is created and stored in the
 * specified trailingRowsSegment location.
 *
 * If the specified removedRowsSegment location is defined (not nil), a new segment
 * specifying the range of removed rows is created and stored there.
 *
 * @param numberOfRows the number of rows to delete.
 * @param index the zero based index specifying the first row to remove
 * @param trailingRowsSegment location at which to store the trailing rows segment.
 * @param removedRowsSegment if not nil, location at which to store a segment specifying the removed rows.
 *
 * @return the number of rows that have not been deleted because this segment does not contain
 *      a sufficient number of rows.
 */
- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
           rowsFromIndex:(NSUInteger)index
            trailingRows:(AKATVRowSegment*__autoreleasing*)trailingRowsSegment
             removedRows:(AKATVRowSegment*__autoreleasing*)removedRowsSegment
{
    AKATVDataSource* dataSource = self.dataSource;

    NSUInteger result = 0;
    NSUInteger count = numberOfRows;
    if (index + count > self.numberOfRows)
    {
        result = index + count - self.numberOfRows;
        count = count - result;
    }

    // record removed rows if requested
    if (removedRowsSegment != nil)
    {
        *removedRowsSegment =
        [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                              index:self.rowIndex + index
                                              count:count];
    }

    // return trailingRowsSegment if there are trailing rows
    if (index + count < self.numberOfRows && index > 0)
    {
        NSUInteger trailingRows = self.numberOfRows - (index + count);
        _numberOfRows -= trailingRows;
        if (trailingRowsSegment != nil)
        {
            *trailingRowsSegment =
            [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                                  index:self.rowIndex + index + count
                                                  count:trailingRows];
        }
        else
        {
            AKALogError(@"Removal of %ld rows from row segment %@ starting at index %ld resulted in a trailing rows segment, which should/has to be inserted following this segement. The caller did not supply a trailingRowsSegment and will probably fail to update the containing section correctly", (long)count, self, (long)index);
        }
    }

    // Perform removal on this segment
    if (index == 0)
    {
        _rowIndex += count;
    }
    _numberOfRows -= count;

    return result;
}

#pragma mark - Adding and Removing Rows

@end

#pragma mark - AKATVSection
#pragma mark -

@interface AKATVSection: NSObject

- (instancetype)initWithDataSource:(AKATVDataSource*)dataSource
                             index:(NSUInteger)sectionIndex;

@property(nonatomic, readonly) AKATVDataSource* dataSource;
@property(nonatomic, readonly) NSUInteger sectionIndex;
@property(nonatomic, readonly) NSUInteger numberOfRows;

@end

@interface AKATVSection()

@property(nonatomic, readonly) NSMutableArray* rowSegments;

@end

@implementation AKATVSection

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init])
    {
        _rowSegments = NSMutableArray.new;
    }
    return self;
}

- (instancetype)initWithDataSource:(AKATVDataSource*)dataSource
                             index:(NSUInteger)sectionIndex
{
    if (self = [self init])
    {
        _dataSource = dataSource;
        _sectionIndex = sectionIndex;
    }
    return self;
}

#pragma mark - Properties

- (NSUInteger)numberOfRows
{
    __block NSUInteger result = 0;
    [self.rowSegments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        (void)idx; (void)stop; // not used
        AKATVRowSegment* rowSegment = obj;
        result += (NSUInteger)rowSegment.numberOfRows;
    }];
    return result;
}

#pragma mark - Resolution

- (BOOL)resolveDataSource:(out AKATVDataSource*__autoreleasing*)dataSourceStorage
           sourceRowIndex:(out NSUInteger*)rowIndexStorage
              forRowIndex:(NSUInteger)rowIndex
{
    AKATVRowSegment* rowSegment = nil;
    NSUInteger offset = NSNotFound;
    BOOL result = [self locateRowSegment:&rowSegment
                            segmentIndex:nil
                         offsetInSegment:&offset
                             rowsVisited:nil
                             forRowIndex:rowIndex];
    if (result)
    {
        *rowIndexStorage = (NSUInteger)offset + rowSegment.rowIndex;
        if (dataSourceStorage != nil)
        {
            *dataSourceStorage = rowSegment.dataSource;
        }
    }
    return result;
}

- (BOOL)locateRowSegment:(out AKATVRowSegment*__autoreleasing*)rowSegmentStorage
            segmentIndex:(out NSUInteger*)segmentIndexStorage
         offsetInSegment:(out NSUInteger*)offsetStorage
             rowsVisited:(out NSUInteger*)rowsVisitedStorage
             forRowIndex:(NSUInteger)rowIndex
{
    __block BOOL result = NO;
    __block NSUInteger rowsVisited = 0;
    [self.rowSegments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         AKATVRowSegment* segment = obj;
         if (rowIndex - rowsVisited < segment.numberOfRows)
         {
             result = *stop = YES;
             if (rowSegmentStorage)
             {
                 *rowSegmentStorage = segment;
             }
             if (segmentIndexStorage)
             {
                 *segmentIndexStorage = idx;
             }
             if (offsetStorage)
             {
                 *offsetStorage = (NSUInteger)(rowIndex - rowsVisited);
             }
         }
         else
         {
             rowsVisited += segment.numberOfRows;
         }
     }];
    if (rowsVisitedStorage)
    {
        *rowsVisitedStorage = (NSUInteger)rowsVisited;
    }
    return result;
}

#pragma mark - Moving Rows

- (BOOL)moveRowFromIndex:(NSUInteger)rowIndex
                 toIndex:(NSUInteger)targetRowIndex
               tableView:(UITableView*)tableView
{
    // TODO: check indexes before doing anything

    NSMutableArray* removedSegments = [NSMutableArray new];
    NSUInteger toRemove = [self removeUpTo:1
                             rowsFromIndex:rowIndex
                                 tableView:tableView
                        removedRowSegments:removedSegments];
    BOOL result = toRemove == 0;

    if (result)
    {
        NSAssert(removedSegments.count == 1, nil);
        NSAssert([removedSegments.firstObject isKindOfClass:[AKATVRowSegment class]], nil);

        AKATVRowSegment* removedRows = removedSegments.firstObject;
        NSAssert(removedRows.numberOfRows == 1, nil);

        NSUInteger effectiveTarget = targetRowIndex;
        if (rowIndex < targetRowIndex)
        {
            --effectiveTarget;
        }

        // TODO: make sure this does not fail or rollback:
        result = [self insertRowSegment:removedRows
                             atRowIndex:effectiveTarget
                              tableView:tableView];
    }
    return result;
}

#pragma mark - Adding and Removing Rows

/**
 * Takes the specified numberOfRows from the specified dataSource starting
 * at the specified sourceIndexPath and inserts them at the specified
 * rowIndex in this section.
 *
 * @note The source section has to contain a sufficient amount of rows
 *      and the target indexPath has to reference a valid insertion point.
 *
 * @note This method (in contrast to the corresponding multiplexed data source
 *      method) does not update the table view.
 *
 * @param dataSource the data source providing the rows
 * @param sourceIndexPath the indexPath specifying the first row to insert
 * @param numberOfRows the number of rows to insert
 * @param indexPath the location where the rows should be inserted.
 * @param tableView the table view which is passed to data sources in queries.
 *
 * @return YES if the rows have been inserted, NO if the specified rowIndex is
 *      out of range 0..<numberOfRows>
 */
- (BOOL)insertRowsFromDataSource:(AKATVDataSource*)dataSource
                  sourceRowIndex:(NSUInteger)sourceRowIndex
                           count:(NSUInteger)numberOfRows
                      atRowIndex:(NSUInteger)rowIndex
                       tableView:(UITableView*)tableView
{
    NSParameterAssert(sourceRowIndex >= 0);
    NSParameterAssert(numberOfRows > 0);

    AKATVRowSegment* segment =
    [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                          index:sourceRowIndex
                                          count:numberOfRows];
    return [self insertRowSegment:segment
                       atRowIndex:rowIndex
                        tableView:tableView];
}

- (BOOL)insertRowSegment:(AKATVRowSegment*)segment
              atRowIndex:(NSUInteger)rowIndex
               tableView:(UITableView*)tableView
{
    NSParameterAssert(rowIndex >= 0);

    (void)tableView; // not used. TODO: see if we need it

    NSUInteger segmentIndex = NSNotFound;
    NSUInteger rowsVisited = NSNotFound;
    NSUInteger offset = NSNotFound;

    AKATVRowSegment* rowSegment = nil;

    BOOL result = [self locateRowSegment:&rowSegment
                            segmentIndex:&segmentIndex
                         offsetInSegment:&offset
                             rowsVisited:&rowsVisited
                             forRowIndex:rowIndex];
    if (result)
    {
        NSAssert(offset >= 0 && offset < rowSegment.numberOfRows,
                 @"offset %lu out of bounds 0..%lu",
                 (unsigned long)offset,
                 (unsigned long)(rowSegment.numberOfRows - 1));
        if (offset > 0)
        {
            AKATVRowSegment* part = [rowSegment splitAtOffset:offset];
            ++segmentIndex;
            [self.rowSegments insertObject:part atIndex:segmentIndex];
        }
    }
    else if (rowIndex == rowsVisited)
    {
        // locateRowSegment:.. fails if rowIndex is >= #rows, in this case, rowsVisited
        // equals the number of rows in the section (all rows visted).
        result = YES;
        segmentIndex = self.rowSegments.count;
    }

    if (result)
    {
        [self.rowSegments insertObject:segment atIndex:segmentIndex];
    }

    return result;
}

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
           rowsFromIndex:(NSUInteger)rowIndex
               tableView:(UITableView*)tableView
{
    return [self removeUpTo:numberOfRows
              rowsFromIndex:rowIndex
                  tableView:tableView
         removedRowSegments:nil];
}

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
           rowsFromIndex:(NSUInteger)rowIndex
               tableView:(UITableView*)tableView
      removedRowSegments:(NSMutableArray*)removedRowSegments
{
    NSParameterAssert(numberOfRows > 0);
    NSParameterAssert(rowIndex >= 0);
    (void)tableView; // not used. TODO: see if we need it

    NSUInteger numberOfRowsToRemove = numberOfRows;

    NSUInteger segmentIndex = NSNotFound;
    NSUInteger segmentFirstRowIndex = NSNotFound;
    NSUInteger offset = NSNotFound;

    AKATVRowSegment* rowSegment = nil;

    BOOL rowSegmentFound = [self locateRowSegment:&rowSegment
                                     segmentIndex:&segmentIndex
                                  offsetInSegment:&offset
                                      rowsVisited:&segmentFirstRowIndex
                                      forRowIndex:rowIndex];
    if (rowSegmentFound)
    {
        NSAssert(offset >= 0 && offset < rowSegment.numberOfRows,
                 @"offset %lu out of bounds 0..%lu",
                 (unsigned long)offset,
                 (unsigned long)(rowSegment.numberOfRows - 1));

        AKATVRowSegment* trailingRowsSegment = nil;
        AKATVRowSegment* removedRow = nil;
        numberOfRowsToRemove = [rowSegment removeUpTo:numberOfRows
                                        rowsFromIndex:offset
                                         trailingRows:&trailingRowsSegment
                                          removedRows:removedRowSegments != nil ? &removedRow : nil];
        if (removedRowSegments != nil)
        {
            [removedRowSegments addObject:removedRow];
        }

        // If there are rows left to be removed, there is no trailing segment to be inserted
        NSAssert(numberOfRowsToRemove > 0 ? trailingRowsSegment == nil : YES, nil);

        // Proceed to the next segment, unless the row segment is empty (and has to be removed)
        // or we need to insert trailing rows
        if (rowSegment.numberOfRows > 0 && trailingRowsSegment == nil)
        {
            ++segmentIndex;
            rowSegment = segmentIndex < self.rowSegments.count ? self.rowSegments[segmentIndex] : nil;
        }

        // Remove row segments until the number of rows is reached; here we can remove from the first
        // row in the segment (no offset).
        while (rowSegment != nil && numberOfRowsToRemove > 0)
        {
            if (numberOfRowsToRemove > rowSegment.numberOfRows)
            {
                numberOfRowsToRemove -= rowSegment.numberOfRows;

                if (removedRowSegments != nil)
                {
                    AKATVRowSegment* removedSegment = self.rowSegments[segmentIndex];
                    [removedRowSegments addObject:removedSegment];
                }

                [self.rowSegments removeObjectAtIndex:segmentIndex];

                rowSegment = self.rowSegments.count > segmentIndex ? self.rowSegments[segmentIndex] : nil;
            }
            else
            {
                AKATVRowSegment* removedSegment = nil;
                numberOfRowsToRemove = [rowSegment removeUpTo:numberOfRowsToRemove
                                                rowsFromIndex:0
                                                 trailingRows:&trailingRowsSegment
                                                  removedRows:(removedRowSegments != nil) ? &removedSegment : nil];
                if (removedRowSegments != nil && removedSegment != nil)
                {
                    [removedRowSegments addObject:removedSegment];
                }
            }
        }
        if (trailingRowsSegment != nil)
        {
            [self.rowSegments insertObject:trailingRowsSegment atIndex:segmentIndex + 1];
        }
    }

    NSAssert(removedRowSegments ? removedRowSegments.count > 0 : YES, nil);
    NSAssert(removedRowSegments ? [removedRowSegments.firstObject numberOfRows] == numberOfRows - numberOfRowsToRemove : YES, nil);

    return numberOfRowsToRemove;
}

@end

#pragma mark - AKAMultiplexedTableViewDataSource
#pragma mark -

@interface AKAMultiplexedTableViewDataSource()

@property(nonatomic) NSMutableArray* sectionSegments;
@property(nonatomic, readonly) NSUInteger numberOfSections;
@property(nonatomic, readonly) AKATVUpdateBatch* updateBatch;

@end

@implementation AKAMultiplexedTableViewDataSource

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init])
    {
        _sectionSegments = [NSMutableArray new];
        _updateBatch = [AKATVUpdateBatch new];
    }
    return self;
}

#pragma mark - Properties

- (NSUInteger)numberOfSections
{
    return self.sectionSegments.count;
}

#pragma mark - Batch Table View Updates

- (void)beginUpdatesForTableView:(UITableView*)tableView
{
    [self.updateBatch beginUpdatesForTableView:tableView];
}

- (void)endUpdatesForTableView:(UITableView*)tableView
{
    [self.updateBatch endUpdatesForTableView:tableView];
}

#pragma mark - Adding and Removing Sections

- (void)insertSectionsFromDataSource:(NSString*)dataSourceKey
                  sourceSectionIndex:(NSUInteger)sourceSectionIndex
                               count:(NSUInteger)numberOfSections
                      atSectionIndex:(NSUInteger)targetSectionIndex
                   useRowsFromSource:(BOOL)useRowsFromSource
                           tableView:(UITableView *)tableView
                              update:(BOOL)updateTableView
                    withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert(targetSectionIndex >= 0 && targetSectionIndex <= self.numberOfSections);
    AKATVDataSource* dataSourceEntry = [self dataSourceForKey:dataSourceKey];
    id<UITableViewDataSource> dataSource = dataSourceEntry.dataSource;

    for (NSUInteger i = 0; i < numberOfSections; ++i)
    {
        AKATVSection* section = [[AKATVSection alloc] initWithDataSource:dataSourceEntry
                                                                   index:(NSUInteger)sourceSectionIndex + i];
        if (useRowsFromSource)
        {
            [section insertRowsFromDataSource:dataSourceEntry
                               sourceRowIndex:0
                                        count:(NSUInteger)[dataSource tableView:tableView
                                                          numberOfRowsInSection:(NSInteger)(sourceSectionIndex+i)]
                                   atRowIndex:0
                                    tableView:tableView];
        }
        [self insertSection:section atIndex:i + targetSectionIndex
                  tableView:tableView
                     update:updateTableView
           withRowAnimation:rowAnimation];
    }
}

- (void)insertSection:(AKATVSection*)section
              atIndex:(NSUInteger)sectionIndex
{
    [self insertSection:section
                atIndex:sectionIndex
              tableView:nil
                 update:NO
       withRowAnimation:UITableViewRowAnimationNone];
}

- (void)insertSection:(AKATVSection*)section
              atIndex:(NSUInteger)sectionIndex
            tableView:(UITableView *)tableView
               update:(BOOL)updateTableView
     withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert(sectionIndex >= 0 && sectionIndex <= self.numberOfSections);

    [self.sectionSegments insertObject:section atIndex:(NSUInteger)sectionIndex];

    if (tableView && updateTableView)
    {
        NSInteger correctedSectionIndex = [self.updateBatch insertionIndexForSection:(NSInteger)sectionIndex
                                                           forBatchUpdateInTableView:tableView
                                                               recordAsInsertedIndex:YES];
        [tableView insertSections:[NSIndexSet indexSetWithIndex:(NSUInteger)correctedSectionIndex]
                 withRowAnimation:rowAnimation];
    }
}

- (void)        remove:(NSUInteger)numberOfSections
       sectionsAtIndex:(NSUInteger)sectionIndex
             tableView:(UITableView *)tableView
                update:(BOOL)updateTableView
      withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert(sectionIndex + numberOfSections <= self.numberOfSections);

    [self.sectionSegments removeObjectsInRange:NSMakeRange(sectionIndex, numberOfSections)];

    if (tableView && updateTableView)
    {
        NSInteger correctedSectionIndex = [self.updateBatch deletionIndexForSection:(NSInteger)sectionIndex
                                                          forBatchUpdateInTableView:tableView
                                                              recordAsInsertedIndex:YES];

        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange((NSUInteger)correctedSectionIndex, numberOfSections)];
        [tableView deleteSections:indexSet
                 withRowAnimation:rowAnimation];
    }
}

#pragma mark - Moving Rows

- (void)moveRowAtIndexPath:(NSIndexPath*)indexPath
               toIndexPath:(NSIndexPath*)targetIndexPath
                 tableView:(UITableView *)tableView
                    update:(BOOL)updateTableView
{
    NSParameterAssert(indexPath.section >= 0 && indexPath.row >= 0);

    BOOL result = NO;

    AKATVSection* section = nil;
    if ([self resolveSectionSpecification:&section
                             sectionIndex:indexPath.section])
    {
        if (indexPath.section == targetIndexPath.section)
        {
            result = [section moveRowFromIndex:(NSUInteger)indexPath.row
                                       toIndex:(NSUInteger)targetIndexPath.row
                                     tableView:tableView];
        }
        else
        {
            NSMutableArray* segments = [NSMutableArray new];
            result = (0 == [section removeUpTo:1
                                 rowsFromIndex:(NSUInteger)indexPath.row
                                     tableView:tableView
                            removedRowSegments:segments]);
            NSAssert(segments.count == 1, nil);

            AKATVSection* targetSection = nil;
            if ([self resolveSectionSpecification:&targetSection
                                     sectionIndex:targetIndexPath.section])
            {
                [targetSection insertRowSegment:segments.firstObject
                                     atRowIndex:(NSUInteger)targetIndexPath.row
                                      tableView:tableView];
            }
        }
    }
    else
    {
        // TODO: error handling
    }

    if (result && tableView && updateTableView)
    {
        NSIndexPath* srcIndexPath = indexPath;
        NSIndexPath* tgtIndexPath = targetIndexPath;
        [self.updateBatch movementSourceRowIndex:&srcIndexPath
                                  targetRowIndex:&tgtIndexPath
                       forBatchUpdateInTableView:tableView
                                recordAsMovedRow:YES];
        [tableView moveRowAtIndexPath:srcIndexPath
                          toIndexPath:tgtIndexPath];
    }

    return;
}

#pragma mark - Adding and Removing Rows to/from Sections

- (void)insertRowsFromDataSource:(NSString*)dataSourceKey
                 sourceIndexPath:(NSIndexPath*)sourceIndexPath
                           count:(NSUInteger)numberOfRows
                     atIndexPath:(NSIndexPath*)indexPath
                       tableView:(UITableView*)tableView
                          update:(BOOL)updateTableView
                withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert([self dataSourceForKey:dataSourceKey] != nil);
    NSParameterAssert(sourceIndexPath.section >= 0 && sourceIndexPath.row >= 0);
    NSParameterAssert(indexPath.section >= 0 && indexPath.row >= 0);

    AKATVDataSource* dataSource = [self dataSourceForKey:dataSourceKey];
    AKATVSection* section = nil;
    if ([self resolveSectionSpecification:&section
                             sectionIndex:indexPath.section])
    {
        if ([section insertRowsFromDataSource:dataSource
                                    sourceRowIndex:(NSUInteger)sourceIndexPath.row
                                             count:numberOfRows
                                        atRowIndex:(NSUInteger)indexPath.row
                                         tableView:tableView])
        {
            if (tableView && updateTableView)
            {
                NSMutableArray* indexPaths = NSMutableArray.new;
                for (NSInteger i=0; i < numberOfRows; ++i)
                {
                    NSIndexPath* correctedIndexPath = [self.updateBatch insertionIndexPathForRow:indexPath.row+i
                                                                                       inSection:indexPath.section
                                                                       forBatchUpdateInTableView:tableView
                                                                           recordAsInsertedIndex:YES];
                    [indexPaths addObject:correctedIndexPath];
                }
                [tableView insertRowsAtIndexPaths:indexPaths
                                 withRowAnimation:rowAnimation];
            }
        }
        else
        {
            NSString* reason = [NSString stringWithFormat:
                                @"Index path %@ row %ld out of range 0..%ld",
                                indexPath, (long)indexPath.row, (long)[self tableView:tableView
                                                    numberOfRowsInSection:indexPath.section]];
            NSString* message = [NSString stringWithFormat:
                                 @"Failed to insert %ld rows from %@ in %@ at %@: %@",
                                 (long)numberOfRows, sourceIndexPath, dataSource, indexPath, reason];
            @throw [NSException exceptionWithName:message
                                           reason:reason
                                         userInfo:nil];
        }
    }
    else
    {
        NSString* reason = [NSString stringWithFormat:
                            @"Index path %@ section %ld out of range 0..%ld",
                            indexPath, (long)indexPath.section, (long)[self numberOfSections]];
        NSString* message = [NSString stringWithFormat:
                             @"Failed to insert %ld rows from %@ in %@ at %@: %@",
                             (long)numberOfRows, sourceIndexPath, dataSource, indexPath, reason];
        @throw [NSException exceptionWithName:message
                                       reason:reason
                                     userInfo:nil];
    }
}

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
       rowsFromIndexPath:(NSIndexPath*)indexPath
               tableView:(UITableView*)tableView
                  update:(BOOL)updateTableView
        withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert(indexPath.section >= 0 && indexPath.row >= 0);

    NSUInteger result = numberOfRows;

    AKATVSection* section = nil;
    if ([self resolveSectionSpecification:&section
                             sectionIndex:indexPath.section])
    {
        result = [section removeUpTo:numberOfRows
                       rowsFromIndex:(NSUInteger)indexPath.row
                           tableView:tableView];
        NSUInteger rowsRemoved = numberOfRows - result;
        if (rowsRemoved > 0 && tableView && updateTableView)
        {
            NSMutableArray* indexPaths = NSMutableArray.new;
            for (NSInteger i=0; i < rowsRemoved; ++i)
            {
                NSIndexPath* correctedIndexPath = [self.updateBatch deletionIndexPathForRow:indexPath.row + i
                                                                                  inSection:indexPath.section
                                                                  forBatchUpdateInTableView:tableView
                                                                       recordAsDeletedIndex:YES];
                [indexPaths addObject:correctedIndexPath];
            }
            [tableView deleteRowsAtIndexPaths:indexPaths
                             withRowAnimation:rowAnimation];
        }
    }

    return result;
}

#pragma mark - UITableViewDataSource Implementations

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    (void)tableView;
    return (NSInteger)self.numberOfSections;
}

- (NSInteger)                   tableView:(UITableView *)tableView
                    numberOfRowsInSection:(NSInteger)section
{
    (void)tableView; // not used
    NSInteger result = 0;
    AKATVSection* sectionSpecification;
    NSInteger sectionIndex = section;
    if ([self resolveSectionSpecification:&sectionSpecification sectionIndex:sectionIndex])
    {
        result = (NSInteger)sectionSpecification.numberOfRows;
    }
    return result;
}

#pragma mark - Implementation - Resolution

- (BOOL)resolveSectionSpecification:(out AKATVSection*__autoreleasing*)sectionStorage
                       sectionIndex:(NSInteger)sectionIndex
{
    BOOL result = sectionIndex >= 0 && sectionIndex < self.numberOfSections;
    if (result)
    {
        (*sectionStorage) = self.sectionSegments[(NSUInteger)sectionIndex];
    }
    return result;
}

- (BOOL)resolveAKADataSource:(out AKATVDataSource *__autoreleasing *)dataSourceStorage
          sourceSectionIndex:(out NSInteger *)sectionIndexStorage
             forSectionIndex:(NSInteger)sectionIndex
{
    AKATVSection* sectionSpecification = nil;
    BOOL result = [self resolveSectionSpecification:&sectionSpecification
                                       sectionIndex:sectionIndex];
    if (result)
    {
        if (dataSourceStorage)
        {
            (*dataSourceStorage) = sectionSpecification.dataSource;
        }
        if (sectionIndexStorage)
        {
            (*sectionIndexStorage)  = (NSInteger)sectionSpecification.sectionIndex;
        }
    }

    return result;
}

- (BOOL)resolveAKADataSource:(out AKATVDataSource *__autoreleasing *)dataSourceStorage
             sourceIndexPath:(out NSIndexPath *__autoreleasing *)indexPathStorage
                forIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionIndex = indexPath.section;
    AKATVSection* sectionSpecification = nil;
    BOOL result = [self resolveSectionSpecification:&sectionSpecification
                                       sectionIndex:sectionIndex];
    if (result)
    {
        NSUInteger rowIndex = (NSUInteger)indexPath.row;
        AKATVDataSource* dataSourceEntry = nil;
        result = [sectionSpecification resolveDataSource:&dataSourceEntry
                                          sourceRowIndex:&rowIndex
                                             forRowIndex:rowIndex];
        if (result)
        {
            if (dataSourceStorage)
            {
                (*dataSourceStorage) = dataSourceEntry;
            }
            if (indexPathStorage)
            {
                (*indexPathStorage) = [NSIndexPath indexPathForRow:(NSInteger)rowIndex
                                                         inSection:(NSInteger)sectionSpecification.sectionIndex];
            }
        }
    }
    return result;
}

@end
