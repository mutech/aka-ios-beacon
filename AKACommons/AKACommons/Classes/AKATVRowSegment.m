//
//  AKATVRowSegment.m
//  AKACommons
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
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
    AKATVRowSegment* result =
    [[AKATVRowSegment alloc] initWithDataSource:self.dataSource
                                      indexPath:[NSIndexPath indexPathForRow:self.indexPath.row + (NSInteger)offset
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
