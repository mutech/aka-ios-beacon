//
//  AKATVSection.m
//  AKACommons
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATVSection.h"
#import "AKATVRowSegment.h"

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

- (instancetype)initWithDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource
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

- (BOOL)resolveDataSource:(out AKATVDataSourceSpecification*__autoreleasing* __nullable)dataSourceStorage
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
            NSIndexPath* ip = [NSIndexPath indexPathForRow:(NSInteger)offset + rowSegment.indexPath.row
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
    [self enumerateRowSegmentsUsingBlock:^void(AKATVRowSegment* segment, NSUInteger idx, BOOL *stop)
     {
         NSUInteger relativeRowIndex = rowIndex - rowsVisited;

         if (relativeRowIndex < segment.numberOfRows)
         {
             NSAssert(!segment.isExcluded, @"Non-empty excluded row segment breaks this implementation");

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
                 *offsetStorage = (NSUInteger)(relativeRowIndex);
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

- (BOOL)insertRowsFromDataSource:(AKATVDataSourceSpecification*)dataSource
                 sourceIndexPath:(NSIndexPath*)sourceIndexPath
                           count:(NSUInteger)numberOfRows
                      atRowIndex:(NSUInteger)rowIndex
{
    NSParameterAssert(sourceIndexPath != nil);
    NSParameterAssert(numberOfRows > 0);

    AKATVRowSegment* segment =
    [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                      indexPath:sourceIndexPath
                                          count:numberOfRows];
    return [self insertRowSegment:segment
                       atRowIndex:rowIndex];
}

- (BOOL)insertRowSegment:(AKATVRowSegment*)segment
              atRowIndex:(NSUInteger)rowIndex
{
    NSParameterAssert(rowIndex >= 0);

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

- (BOOL)excludeRowAtOffset:(NSUInteger)offsetInSegment
              inRowSegment:(AKATVRowSegment *)rowSegment
            atSegmentIndex:(NSUInteger)rowSegmentIndex
{
    AKATVRowSegment* excludedSegment;
    AKATVRowSegment* trailingSegment;
    BOOL result = [rowSegment excludeRowAtOffset:offsetInSegment
                                excludedRow:&excludedSegment
                               trailingRows:&trailingSegment];
    if (result)
    {
        if (trailingSegment)
        {
            [self.rowSegments insertObject:trailingSegment atIndex:rowSegmentIndex + 1];
        }
        if (excludedSegment != nil)
        {
            [self.rowSegments insertObject:excludedSegment atIndex:rowSegmentIndex + 1];
        }
    }
    return result;
}

- (BOOL)includeRowSegment:(AKATVRowSegment*)rowSegment
           atSegmentIndex:(NSUInteger)segmentIndex
{
    NSAssert(self.rowSegments[segmentIndex] == rowSegment, @"rowSegment %@ is not located at segment index %lu", rowSegment, (unsigned long)segmentIndex);

    return [rowSegment includeExcludedRow];
}

- (BOOL)excludeRowFromIndex:(NSInteger)rowIndex
{
    NSParameterAssert(rowIndex >= 0);

    NSUInteger segmentIndex = NSNotFound;
    NSUInteger segmentFirstRowIndex = NSNotFound;
    NSUInteger offset = NSNotFound;

    AKATVRowSegment* rowSegment = nil;

    BOOL result = [self locateRowSegment:&rowSegment
                            segmentIndex:&segmentIndex
                         offsetInSegment:&offset
                             rowsVisited:&segmentFirstRowIndex
                             forRowIndex:(NSUInteger)rowIndex];
    if (result)
    {
        NSAssert(offset >= 0 && offset < rowSegment.numberOfRows,
                 @"offset %lu out of bounds 0..%lu",
                 (unsigned long)offset,
                 (unsigned long)(rowSegment.numberOfRows - 1));
        NSAssert(!rowSegment.isExcluded, @"locateRowSegment invalidly returned excluded row segment");

        AKATVRowSegment* trailingRowsSegment = nil;
        AKATVRowSegment* exclusionRowSegment = nil;
        result = [rowSegment excludeRowAtOffset:offset
                                    excludedRow:&exclusionRowSegment
                                   trailingRows:&trailingRowsSegment];
        if (result)
        {
            if (exclusionRowSegment != nil)
            {
                [self.rowSegments insertObject:exclusionRowSegment atIndex:segmentIndex + 1];
                ++segmentIndex;
            }
            if (trailingRowsSegment != nil)
            {
                [self.rowSegments insertObject:trailingRowsSegment atIndex:segmentIndex + 1];
            }
        }
    }

    return result;
}

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
           rowsFromIndex:(NSUInteger)rowIndex
{
    return [self removeUpTo:numberOfRows
              rowsFromIndex:rowIndex
         removedRowSegments:nil];
}

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
           rowsFromIndex:(NSUInteger)rowIndex
      removedRowSegments:(NSMutableArray*)removedRowSegments
{
    NSParameterAssert(numberOfRows > 0);
    NSParameterAssert(rowIndex >= 0);

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
        while (rowSegment != nil && (numberOfRowsToRemove > 0 || rowSegment.numberOfRows == 0))
        {
            if (rowSegment.numberOfRows == 0 && rowSegment.isExcluded)
            {
                // Empty excluded row segments are not removed
                ++segmentIndex;
                rowSegment = self.rowSegments.count > segmentIndex ? self.rowSegments[segmentIndex] : nil;
            }
            else if (numberOfRowsToRemove >= rowSegment.numberOfRows)
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
{
    // TODO: check indexes before doing anything

    NSMutableArray* removedSegments = [NSMutableArray new];
    BOOL result = (1 == [self removeUpTo:1
                           rowsFromIndex:rowIndex
                      removedRowSegments:removedSegments]);

    if (result)
    {
        // Might be more than one segment, if empty segments have been lazily removed, check this though...
        //NSAssert(removedSegments.count == 1, nil);
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
                             atRowIndex:effectiveTarget];
    }
    return result;
}

@end
