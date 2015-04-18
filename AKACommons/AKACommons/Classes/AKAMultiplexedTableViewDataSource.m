//
//  AKAMultiplexedTableViewDataSource.m
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAMultiplexedTableViewDataSource.h"
#import "AKAReference.h"
#import "AKALog.h"
#import "AKAErrors.h"


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
                 @"offset %ld out of bounds 0..%ld", offset, rowSegment.numberOfRows - 1);
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
        AKATVRowSegment* segment =
        [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                              index:sourceRowIndex
                                              count:numberOfRows];
        [self.rowSegments insertObject:segment atIndex:segmentIndex];
    }

    return result;
}

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
           rowsFromIndex:(NSUInteger)rowIndex
               tableView:(UITableView*)tableView
{
    NSParameterAssert(numberOfRows > 0);
    NSParameterAssert(rowIndex >= 0);
    (void)tableView; // not used. TODO: see if we need it

    NSUInteger result = numberOfRows;

    NSUInteger segmentIndex = NSNotFound;
    NSUInteger segmentFirstRowIndex = NSNotFound;
    NSUInteger offset = NSNotFound;

    AKATVRowSegment* rowSegment = nil;

    BOOL done = [self locateRowSegment:&rowSegment
                            segmentIndex:&segmentIndex
                         offsetInSegment:&offset
                             rowsVisited:&segmentFirstRowIndex
                             forRowIndex:rowIndex];
    if (done)
    {
        NSAssert(offset >= 0 && offset < rowSegment.numberOfRows,
                 @"offset %ld out of bounds 0..%ld", offset, rowSegment.numberOfRows - 1);

        AKATVRowSegment* trailingRowsSegment = nil;
        result = [rowSegment removeUpTo:numberOfRows
                          rowsFromIndex:offset
                           trailingRows:&trailingRowsSegment
                            removedRows:nil];
        NSAssert(result > 0 ? trailingRowsSegment == nil : YES, nil);
        if (rowSegment.numberOfRows > 0 && trailingRowsSegment == nil)
        {
            ++segmentIndex;
            rowSegment = segmentIndex < self.rowSegments.count ? self.rowSegments[segmentIndex] : nil;
        }
        while (rowSegment != nil && result > 0)
        {
            if (rowSegment.numberOfRows < result)
            {
                result -= rowSegment.numberOfRows;
                [self.rowSegments removeObjectAtIndex:segmentIndex];
                rowSegment = self.rowSegments.count > segmentIndex ? self.rowSegments[segmentIndex] : nil;
            }
            else
            {
                result = [rowSegment removeUpTo:result
                                  rowsFromIndex:0
                                   trailingRows:&trailingRowsSegment
                                    removedRows:nil];
            }
        }
        if (trailingRowsSegment != nil)
        {
            [self.rowSegments insertObject:trailingRowsSegment atIndex:segmentIndex + 1];
        }
    }

    return result;
}

@end

#pragma mark - AKAMultiplexedTableViewDataSource
#pragma mark -

@interface AKAMultiplexedTableViewDataSource()

@property(nonatomic) NSMutableArray* sectionSegments;
@property(nonatomic, readonly) NSUInteger numberOfSections;

@end

@implementation AKAMultiplexedTableViewDataSource

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init])
    {
        _sectionSegments = NSMutableArray.new;
    }
    return self;
}

#pragma mark - Properties

- (NSUInteger)numberOfSections
{
    return self.sectionSegments.count;
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
        [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                 withRowAnimation:rowAnimation];
    }
}

- (void)        remove:(NSUInteger)numberOfSections
       sectionsAtIndex:(NSUInteger)sectionIndex
             tableView:(UITableView *)tableView
                update:(BOOL)updateTableView
      withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert(sectionIndex + numberOfSections < self.numberOfSections);

    NSRange range = NSMakeRange(sectionIndex, numberOfSections);
    [self.sectionSegments removeObjectsInRange:range];

    if (tableView && updateTableView)
    {
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [tableView deleteSections:indexSet
                 withRowAnimation:rowAnimation];
    }
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
                    [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row+i
                                                             inSection:indexPath.section]];
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
                [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row + i
                                                         inSection:indexPath.section]];
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

- (BOOL)resolveDataSource:(out __autoreleasing id<UITableViewDataSource>*)dataSourceStorage
                 delegate:(out __autoreleasing id<UITableViewDelegate>*)delegateStorage
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
            (*dataSourceStorage) = sectionSpecification.dataSource.dataSource;
        }
        if (delegateStorage)
        {
            (*delegateStorage) = sectionSpecification.dataSource.delegate;
        }
        if (sectionIndexStorage)
        {
            (*sectionIndexStorage)  = (NSInteger)sectionSpecification.sectionIndex;
        }
    }

    return result;
}

- (BOOL)resolveDataSource:(out __autoreleasing id<UITableViewDataSource> *)dataSourceStorage
                 delegate:(out __autoreleasing id<UITableViewDelegate>*)delegateStorage
          sourceIndexPath:(out NSIndexPath *__autoreleasing *)indexPathStorage
             forIndexPath:(NSIndexPath*)indexPath
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
                (*dataSourceStorage) = dataSourceEntry.dataSource;
            }
            if (delegateStorage)
            {
                (*delegateStorage) = dataSourceEntry.delegate;
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
