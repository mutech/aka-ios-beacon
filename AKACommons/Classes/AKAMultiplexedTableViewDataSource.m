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

/**
 * Represents a contiguous sequence of rows originating from a data source.
 *
 * Row segments are used internally and not exposed in the public interface.
 */
@interface AKATVRowSegment: NSObject

#pragma mark - Initialization
/// @name Initialization

/**
 * Initializes the segment to refer to the sequence of the specified @c numberOfRows
 * of the specified @c dataSource starting at the specified @c indexPath.
 *
 * @param dataSource the data source providing the rows.
 * @param indexPath the index path of a row having the required number of successors in the same section.
 * @param numberOfRows the number of rows (greater than or equal to 1).
 *
 * @return an initialized row segment.
 */
- (instancetype)initWithDataSource:(AKATVDataSource* __nonnull)dataSource
                         indexPath:(NSIndexPath* __nonnull)indexPath
                             count:(NSUInteger)numberOfRows;

#pragma mark - Properties
/// @name Properties

/**
 * The data source providing the rows in this segment.
 */
@property(nonatomic, readonly, weak) AKATVDataSource* dataSource;

/**
 * The index path of the first row of this segment.
 */
@property(nonatomic, readonly, nonnull) NSIndexPath* indexPath;

/**
 * The numer of rows in this segment.
 */
@property(nonatomic, readonly) NSUInteger numberOfRows;

#pragma mark - Removing Rows from the Segment
/// @name Removing Rows from the Segment

/**
 * Splits the segments at the specified @c offset into two and and returns the
 * new segment.
 *
 * @param offset The relative index of the first row in the new segment (greater than 0).
 *
 * @return the new segment containing rows starting from the specified offset.
 */
- (AKATVRowSegment*)splitAtOffset:(NSUInteger)offset;

/**
 * Removes up to the specified @c numberOfRows rows from this segment, starting at the specified offset
 * and returns the number of rows which have been removed.
 *
 * If the removal leaves trailing rows, a new segment is created and stored in the
 * specified trailingRowsSegment location.
 *
 * If the specified removedRowsSegment location is defined (not nil), a new segment
 * specifying the range of removed rows is created and stored there.
 *
 * @param numberOfRows the number of rows to delete.
 * @param index the zero based index specifying the first row to remove
 * @param trailingRowsStorage location at which to store the trailing rows segment.
 * @param removedRowsStorage if not nil, location at which to store a segment specifying the removed rows.
 *
 * @return the number of rows that have been removed. This might be less than the requested number if
 *          this segment does not contain a sufficient number of rows.
 */
- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
            rowsAtOffset:(NSUInteger)index
            trailingRows:(AKATVRowSegment*__autoreleasing* __nonnull)trailingRowsStorage
             removedRows:(AKATVRowSegment*__autoreleasing* __nullable)removedRowsStorage;

@end

@implementation AKATVRowSegment

#pragma mark - Initialization

- (instancetype)initWithDataSource:(AKATVDataSource* __nonnull)dataSource
                         indexPath:(NSIndexPath* __nonnull)indexPath
                             count:(NSUInteger)numberOfRows
{
    if (self = [self init])
    {
        _dataSource = dataSource;
        _indexPath = indexPath;
        _numberOfRows = numberOfRows;
    }
    return self;
}

#pragma mark - Removing Rows from the Segment

- (AKATVRowSegment*)splitAtOffset:(NSUInteger)offset
{
    NSParameterAssert(offset > 0 && offset < self.numberOfRows);
    AKATVRowSegment* result =
    [[AKATVRowSegment alloc] initWithDataSource:self.dataSource
                                      indexPath:[NSIndexPath indexPathForRow:self.indexPath.row + offset
                                                                   inSection:self.indexPath.section]
                                          count:self.numberOfRows - offset];
    _numberOfRows -= (self.numberOfRows - offset);
    return result;
}

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
           rowsAtOffset:(NSUInteger)offset
            trailingRows:(AKATVRowSegment*__autoreleasing*)trailingRowsSegment
             removedRows:(AKATVRowSegment*__autoreleasing*)removedRowsSegment
{
    AKATVDataSource* dataSource = self.dataSource;

    NSUInteger rowsNotRemoved = 0;
    NSUInteger rowsToRemove = numberOfRows;
    if (offset + rowsToRemove > self.numberOfRows)
    {
        // limit rows to remove to the number of available rows in this segment
        rowsNotRemoved = offset + rowsToRemove - self.numberOfRows;
        rowsToRemove -= rowsNotRemoved;
    }

    // record removed rows if requested
    if (removedRowsSegment != nil)
    {
        *removedRowsSegment =
        [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                          indexPath:[NSIndexPath indexPathForRow:self.indexPath.row + offset
                                                                       inSection:self.indexPath.section]
                                              count:rowsToRemove];
    }

    // return trailingRowsSegment if there are trailing rows
    if (offset + rowsToRemove < self.numberOfRows && offset > 0)
    {
        NSUInteger trailingRows = self.numberOfRows - (offset + rowsToRemove);
        _numberOfRows -= trailingRows;
        if (trailingRowsSegment != nil)
        {
            *trailingRowsSegment =
            [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                              indexPath:[NSIndexPath indexPathForRow:self.indexPath.row + offset + rowsToRemove
                                                                           inSection:self.indexPath.section]
                                                  count:trailingRows];
        }
        else
        {
            AKALogError(@"Removal of %ld rows from row segment %@ starting at index %ld resulted in a trailing rows segment, which should/has to be inserted following this segement. The caller did not supply a trailingRowsSegment and will probably fail to update the containing section correctly", (long)rowsToRemove, self, (long)offset);
        }
    }

    // Perform removal on this segment
    if (offset == 0)
    {
        _indexPath = [NSIndexPath indexPathForRow:self.indexPath.row + rowsToRemove inSection:self.indexPath.section];
    }
    _numberOfRows -= rowsToRemove;

    return numberOfRows - rowsNotRemoved;
}

#pragma mark - Adding and Removing Rows

@end

#pragma mark - AKATVSection
#pragma mark -

/**
 * Represents a table view section provided by a data source.
 *
 * Independent of the sections own data source reference, a section can contain rows from
 * one or more other data sources.
 *
 * Section instances are used internally and not exposed in the public interface.
 */
@interface AKATVSection: NSObject

#pragma mark - Initialization
/// @name Initialization

/**
 * Initializes a new instance with the specified data source providing the data source implementation
 * required for the section (except for row specific information, which is provided by the respective
 * data sources of corresponding row segments).
 *
 * @param dataSource the data souce providing the section
 * @param sectionIndex the index of the section (relative to the specified data source).
 *
 * @return An initialized instance.
 */
- (instancetype)initWithDataSource:(AKATVDataSource* __nonnull)dataSource
                             index:(NSUInteger)sectionIndex;

#pragma mark - Properties
/// @name Properties

/**
 * The data source providing the section.
 */
@property(nonatomic, readonly) AKATVDataSource* dataSource;

/**
 * The index of the section (relative to the specified data source).
 */
@property(nonatomic, readonly) NSUInteger sectionIndex;

/**
 * The number of rows contained in the section (this is the actual number of rows, not the
 * number of rows provided by the data source section).
 */
@property(nonatomic, readonly) NSUInteger numberOfRows;

#pragma mark - Enumerating Row Segments
/// @name Enumerating Row Segments

- (void)enumerateRowSegmentsUsingBlock:(void(^)(AKATVRowSegment* rowSegment,
                                                NSUInteger idx, BOOL *stop))block;

#pragma mark - Resolution
/// @name Resolution

- (BOOL)resolveDataSource:(out AKATVDataSource*__autoreleasing* __nullable)dataSourceStorage
       sourceRowIndexPath:(out NSIndexPath*__autoreleasing* __nullable)rowIndexPathStorage
              forRowIndex:(NSUInteger)rowIndex;

- (BOOL)locateRowSegment:(out AKATVRowSegment*__autoreleasing* __nullable)rowSegmentStorage
            segmentIndex:(out NSUInteger* __nullable)segmentIndexStorage
         offsetInSegment:(out NSUInteger* __nullable)offsetStorage
             rowsVisited:(out NSUInteger* __nullable)rowsVisitedStorage
             forRowIndex:(NSUInteger)rowIndex;

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
                 sourceIndexPath:(NSIndexPath*)sourceIndexPath
                           count:(NSUInteger)numberOfRows
                      atRowIndex:(NSUInteger)rowIndex
                       tableView:(UITableView*)tableView;

#pragma mark - Moving Rows
// @name Moving Rows

- (BOOL)moveRowFromIndex:(NSUInteger)rowIndex
                 toIndex:(NSUInteger)targetRowIndex
               tableView:(UITableView*)tableView;

@end

@interface AKATVSection()

/**
 * The row segments constituting or specifying the sections rows.
 */
@property(nonatomic, readonly, nonnull) NSMutableArray* rowSegments;

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

- (instancetype)initWithDataSource:(AKATVDataSource* __nonnull)dataSource
                             index:(NSUInteger)sectionIndex
{
    if (self = [self init])
    {
        _dataSource = dataSource;
        _sectionIndex = sectionIndex;
    }
    return self;
}

#pragma mark - Enumerate Row Segments

- (void)enumerateRowSegmentsUsingBlock:(void(^)(AKATVRowSegment* rowSegment, NSUInteger idx, BOOL *stop))block
{
    [self.rowSegments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx, stop);
    }];
}

#pragma mark - Properties

- (NSUInteger)numberOfRows
{
    __block NSUInteger result = 0;
    [self enumerateRowSegmentsUsingBlock:^(AKATVRowSegment *rowSegment, NSUInteger idx, BOOL *stop) {
        (void)idx; (void)stop; // not used
        result += (NSUInteger)rowSegment.numberOfRows;
    }];
    return result;
}

#pragma mark - Resolution

- (BOOL)resolveDataSource:(out AKATVDataSource*__autoreleasing* __nullable)dataSourceStorage
       sourceRowIndexPath:(out NSIndexPath*__autoreleasing* __nullable)rowIndexPathStorage
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
        if (rowIndexPathStorage != nil)
        {
            NSIndexPath* ip = [NSIndexPath indexPathForRow:offset + rowSegment.indexPath.row
                                                 inSection:rowSegment.indexPath.section];
            *rowIndexPathStorage = ip;
        }
        if (dataSourceStorage != nil)
        {
            *dataSourceStorage = rowSegment.dataSource;
        }
    }
    return result;
}

- (BOOL)locateRowSegment:(out AKATVRowSegment*__autoreleasing* __nullable)rowSegmentStorage
            segmentIndex:(out NSUInteger* __nullable)segmentIndexStorage
         offsetInSegment:(out NSUInteger* __nullable)offsetStorage
             rowsVisited:(out NSUInteger* __nullable)rowsVisitedStorage
             forRowIndex:(NSUInteger)rowIndex
{
    __block BOOL result = NO;
    __block NSUInteger rowsVisited = 0;
    [self enumerateRowSegmentsUsingBlock:^void(AKATVRowSegment* segment, NSUInteger idx, BOOL *stop) {
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

#pragma mark - Adding and Removing Rows

- (BOOL)insertRowsFromDataSource:(AKATVDataSource*)dataSource
                 sourceIndexPath:(NSIndexPath*)sourceIndexPath
                           count:(NSUInteger)numberOfRows
                      atRowIndex:(NSUInteger)rowIndex
                       tableView:(UITableView*)tableView
{
    NSParameterAssert(sourceIndexPath != nil);
    NSParameterAssert(numberOfRows > 0);

    AKATVRowSegment* segment =
    [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                      indexPath:sourceIndexPath
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
        numberOfRowsToRemove = numberOfRows - [rowSegment removeUpTo:numberOfRows
                                                        rowsAtOffset:offset
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
                numberOfRowsToRemove = numberOfRowsToRemove - [rowSegment removeUpTo:numberOfRowsToRemove
                                                                        rowsAtOffset:0
                                                                        trailingRows:&trailingRowsSegment
                                                                         removedRows:((removedRowSegments != nil)
                                                                                      ? &removedSegment
                                                                                      : nil)];
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

    return numberOfRows - numberOfRowsToRemove;
}

#pragma mark - Moving Rows

- (BOOL)moveRowFromIndex:(NSUInteger)rowIndex
                 toIndex:(NSUInteger)targetRowIndex
               tableView:(UITableView*)tableView
{
    // TODO: check indexes before doing anything

    NSMutableArray* removedSegments = [NSMutableArray new];
    BOOL result = (1 == [self removeUpTo:1
                             rowsFromIndex:rowIndex
                                 tableView:tableView
                        removedRowSegments:removedSegments]);

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
                              sourceIndexPath:[NSIndexPath indexPathForRow:0 inSection:sourceSectionIndex + i]
                                        count:(NSUInteger)[dataSource tableView:tableView
                                                          numberOfRowsInSection:(NSInteger)(sourceSectionIndex + i)]
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

    NSRange range = NSMakeRange(sectionIndex, numberOfSections);
    [self.sectionSegments removeObjectsInRange:range];


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
            result = (1 == [section removeUpTo:1
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
                                    sourceIndexPath:sourceIndexPath
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

    NSUInteger rowsRemoved = 0;

    AKATVSection* section = nil;
    if ([self resolveSectionSpecification:&section
                             sectionIndex:indexPath.section])
    {
        rowsRemoved = [section removeUpTo:numberOfRows
                       rowsFromIndex:(NSUInteger)indexPath.row
                           tableView:tableView];
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

    return rowsRemoved;
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

- (BOOL)resolveIndexPath:(out NSIndexPath*__autoreleasing* __nullable)indexPathStorage
      forSourceIndexPath:(NSIndexPath* __nonnull)sourceIndexPath
            inDataSource:(AKATVDataSource* __nonnull)dataSource
{
    __block BOOL result = NO;

    NSInteger sourceSection = sourceIndexPath.section;
    NSInteger sourceRow = sourceIndexPath.row;

    [self.sectionSegments enumerateObjectsUsingBlock:^(id obj, NSUInteger sectionIndex, BOOL *stop) {
        AKATVSection* section = obj;
        __block NSUInteger offset = 0;
        [section enumerateRowSegmentsUsingBlock:^(AKATVRowSegment *rowSegment, NSUInteger rowSegmentIndex, BOOL *stop) {
            NSIndexPath* segmentIndexPath = rowSegment.indexPath;
            NSInteger segmentSection = segmentIndexPath.section;
            NSInteger segmentRow = segmentIndexPath.row;
            NSInteger segmentRowCount = rowSegment.numberOfRows;

            if (dataSource == rowSegment.dataSource &&
                sourceSection == segmentSection &&
                sourceRow >= segmentRow &&
                sourceRow < segmentRow + segmentRowCount)
            {
                result = YES;
                if (indexPathStorage != nil)
                {
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:offset + (sourceRow - segmentRow)
                                                                inSection:sectionIndex];
                    *indexPathStorage = indexPath;
                }
            }
            offset += segmentRowCount;
        }];
    }];
    return result;
}

- (BOOL)resolveSection:(out NSInteger* __nullable)sectionStorage
      forSourceSection:(NSInteger)sourceSection
          inDataSource:(AKATVDataSource* __nonnull)dataSource
{
    __block BOOL result = NO;

    [self.sectionSegments enumerateObjectsUsingBlock:^(id obj, NSUInteger sectionIndex, BOOL *stop) {
        AKATVSection* section = obj;
        if (section.dataSource == dataSource)
        {
            result = YES;
            if (sectionStorage != nil)
            {
                *sectionStorage = sectionIndex;
            }
        }
    }];
    return result;
}

- (BOOL)resolveSectionSpecification:(out AKATVSection*__autoreleasing* __nullable)sectionStorage
                       sectionIndex:(NSInteger)sectionIndex
{
    BOOL result = sectionIndex >= 0 && sectionIndex < self.numberOfSections;
    if (result)
    {
        if (sectionStorage != nil)
        {
            (*sectionStorage) = self.sectionSegments[(NSUInteger)sectionIndex];
        }
    }
    return result;
}

- (BOOL)resolveAKADataSource:(out AKATVDataSource *__autoreleasing* __nullable)dataSourceStorage
          sourceSectionIndex:(out NSInteger* __nullable)sectionIndexStorage
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

- (BOOL)resolveAKADataSource:(out AKATVDataSource *__autoreleasing* __nullable)dataSourceStorage
             sourceIndexPath:(out NSIndexPath *__autoreleasing* __nullable)indexPathStorage
                forIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionIndex = indexPath.section;
    AKATVSection* sectionSpecification = nil;
    BOOL result = [self resolveSectionSpecification:&sectionSpecification
                                       sectionIndex:sectionIndex];
    if (result)
    {
        NSUInteger rowIndex = (NSUInteger)indexPath.row;
        NSIndexPath* sourceIndexPath = nil;
        AKATVDataSource* dataSourceEntry = nil;
        result = [sectionSpecification resolveDataSource:&dataSourceEntry
                                      sourceRowIndexPath:&sourceIndexPath
                                             forRowIndex:rowIndex];
        if (result)
        {
            if (dataSourceStorage)
            {
                (*dataSourceStorage) = dataSourceEntry;
            }
            if (indexPathStorage)
            {
                (*indexPathStorage) = sourceIndexPath;
            }
        }
    }
    return result;
}

@end
