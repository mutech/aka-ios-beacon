//
//  AKATVRowSegment.h
//  AKACommons
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKATVDataSourceSpecification;

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
- (nonnull instancetype)initWithDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource
                         indexPath:(NSIndexPath* __nonnull)indexPath
                             count:(NSUInteger)numberOfRows;

#pragma mark - Properties
/// @name Properties

/**
 * The data source providing the rows in this segment.
 */
@property(nonatomic, readonly, weak, nullable) AKATVDataSourceSpecification* dataSource;

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
- (AKATVRowSegment*__nullable)splitAtOffset:(NSUInteger)offset;

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
            trailingRows:(AKATVRowSegment*__autoreleasing __nullable* __nonnull)trailingRowsStorage
             removedRows:(AKATVRowSegment*__autoreleasing __nullable* __nullable)removedRowsStorage;

@end

