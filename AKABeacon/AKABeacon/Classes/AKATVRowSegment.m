//
//  AKATVRowSegment.m
//  AKACommons
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATVRowSegment.h"

#import "AKALog.h"

#pragma mark - AKATVRowSegment
#pragma mark -

@implementation AKATVRowSegment

#pragma mark - Initialization

- (instancetype)initWithDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource
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

    AKATVDataSourceSpecification* dataSource = self.dataSource;
    NSAssert(dataSource, @"Cannot split rowsegment without data source (check if/why it might have been released unexpectedly)");

    AKATVRowSegment* result =
    [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                      indexPath:[NSIndexPath indexPathForRow:self.indexPath.row + (NSInteger)offset
                                                                   inSection:self.indexPath.section]
                                          count:self.numberOfRows - offset];
    _numberOfRows -= (self.numberOfRows - offset);
    return result;
}

- (BOOL)includeExcludedRow
{
    BOOL result = self.isExcluded && self.numberOfRows == 0;
    if (result)
    {
        _isExcluded = NO;
        _numberOfRows = 1;
    }
    return result;
}

- (BOOL)excludeRowAtOffset:(NSUInteger)offset
               excludedRow:(AKATVRowSegment*__autoreleasing*)excludedRowsSegment
              trailingRows:(AKATVRowSegment*__autoreleasing*)trailingRowsSegment
{
    AKATVDataSourceSpecification* dataSource = self.dataSource;

    BOOL result = offset < self.numberOfRows && !self.isExcluded;

    if (result)
    {
        // Decide whether this segment becomes excluded or a new exclusion segment will be created
        if (offset == 0)
        {
            // The first row is excluded, so this segment will become marked as excluded
            _isExcluded = YES;
        }
        else if (excludedRowsSegment != nil)
        {
            // A new exclusion segment will be created, this segment keeps leading rows
            NSIndexPath* excludedIndexPath = [NSIndexPath indexPathForRow:self.indexPath.row + (NSInteger)offset
                                                                inSection:self.indexPath.section];
            *excludedRowsSegment = [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                                                     indexPath:excludedIndexPath
                                                                         count:0];
            (*excludedRowsSegment)->_isExcluded = YES;
        }
        else
        {
            AKALogError(@"Exclusion of %ld rows from row segment %@ starting at index %ld resulted in a new exclusion rows segment, which should/has to be inserted following this segement. The caller did not supply a excludedRowsSegment reference and will probably fail to update the containing section correctly", (long)1, self, (long)offset);
        }

        // Decrease count of this segment and create a trailing segment if needed
        if (offset + 1 < self.numberOfRows)
        {
            NSUInteger trailingRows = self.numberOfRows - (offset + 1);
            _numberOfRows -= trailingRows + 1;
            if (trailingRowsSegment != nil)
            {
                NSIndexPath* trailingIndexPath = [NSIndexPath indexPathForRow:self.indexPath.row + (NSInteger)(offset) + 1
                                                                    inSection:self.indexPath.section];
                *trailingRowsSegment = [[AKATVRowSegment alloc] initWithDataSource:dataSource
                                                                         indexPath:trailingIndexPath
                                                                             count:trailingRows];
            }
            else
            {
                AKALogError(@"Exclusion of %ld rows from row segment %@ starting at index %ld resulted in a trailing rows segment, which should/has to be inserted following this segement. The caller did not supply a trailingRowsSegment reference and will probably fail to update the containing section correctly", (long)1, self, (long)offset);
            }
        }
        else
        {
            _numberOfRows -= 1;
        }
    }

    return result;
}

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
            rowsAtOffset:(NSUInteger)offset
            trailingRows:(AKATVRowSegment*__autoreleasing*)trailingRowsSegment
             removedRows:(AKATVRowSegment*__autoreleasing*)removedRowsSegment
{
    AKATVDataSourceSpecification* dataSource = self.dataSource;

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
                                          indexPath:[NSIndexPath indexPathForRow:self.indexPath.row + (NSInteger)offset
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
                                              indexPath:[NSIndexPath indexPathForRow:self.indexPath.row + (NSInteger)(offset + rowsToRemove)
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
        _indexPath = [NSIndexPath indexPathForRow:self.indexPath.row + (NSInteger)rowsToRemove
                                        inSection:self.indexPath.section];
    }
    _numberOfRows -= rowsToRemove;

    return numberOfRows - rowsNotRemoved;
}

#pragma mark - Adding and Removing Rows

@end
