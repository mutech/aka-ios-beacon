//
//  AKATVSection.h
//  AKACommons
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKATVDataSourceSpecification;
@class AKATVRowSegment;

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
- (nullable instancetype)initWithDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource
                                      index:(NSUInteger)sectionIndex;

#pragma mark - Properties
/// @name Properties

/**
 * The data source providing the section.
 */
@property(nonatomic, readonly, nonnull) AKATVDataSourceSpecification* dataSource;

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

- (void)enumerateRowSegmentsUsingBlock:(void(^__nonnull)(AKATVRowSegment*__nonnull rowSegment,
                                                         NSUInteger idx,
                                                         BOOL*__nonnull stop))block;

#pragma mark - Resolution
/// @name Resolution

- (BOOL)resolveDataSource:(out AKATVDataSourceSpecification*__autoreleasing __nullable* __nullable)dataSourceStorage
       sourceRowIndexPath:(out NSIndexPath*__autoreleasing __nullable* __nullable)rowIndexPathStorage
              forRowIndex:(NSUInteger)rowIndex;

- (BOOL)locateRowSegment:(out AKATVRowSegment*__autoreleasing __nullable* __nullable)rowSegmentStorage
            segmentIndex:(out NSUInteger* __nullable)segmentIndexStorage
         offsetInSegment:(out NSUInteger* __nullable)offsetStorage
             rowsVisited:(out NSUInteger* __nullable)rowsVisitedStorage
             forRowIndex:(NSUInteger)rowIndex;

#pragma mark - Adding and Removing Rows

- (BOOL)insertRowsFromDataSource:(AKATVDataSourceSpecification*__nonnull)dataSource
                 sourceIndexPath:(NSIndexPath*__nonnull)sourceIndexPath
                           count:(NSUInteger)numberOfRows
                      atRowIndex:(NSUInteger)rowIndex;

- (BOOL)insertRowSegment:(AKATVRowSegment*__nonnull)segment
              atRowIndex:(NSUInteger)rowIndex;

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
           rowsFromIndex:(NSUInteger)rowIndex;

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
           rowsFromIndex:(NSUInteger)rowIndex
      removedRowSegments:(NSMutableArray*__nullable)removedRowSegments;

#pragma mark - Moving Rows
// @name Moving Rows

- (BOOL)moveRowFromIndex:(NSUInteger)rowIndex
                 toIndex:(NSUInteger)targetRowIndex;

@end
