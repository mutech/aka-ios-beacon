//
//  AKAMultiplexedTableViewDataSourceBase.m
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAErrors.h"

#import "AKATVMultiplexedDataSource.h"
#import "AKATVDataSourceSpecification.h"
#import "AKATVRowSegment.h"
#import "AKATVSection.h"
#import "AKATVUpdateBatch.h"

#import "AKAErrors.h"
#import "AKALog.h"

#import <objc/runtime.h>

#pragma mark - AKAMultiplexedTableViewDataSourceBase

/**
   Enumerates supported strategies for mapping coordinates of UITableViewDelegate method's
   parameters and results.
 */
typedef enum
{
    resolveSectionAt1,
    resolveSectionAt2,
    resolveIndexPathAt1,
    resolveIndexPathAt1AndResultIndexPath,
    resolveIndexPathAt2,
    resolveIndexPathAt1And2,
    resolveScrollViewDelegate
} AKATVMDSDelegateMappingType;


@interface AKATVMultiplexedDataSource ()

@property(nonatomic, readonly) NSMutableDictionary* dataSourcesByKey;
@property(nonatomic, readonly) NSMutableDictionary* tableViewDelegateSelectorMapping;
@property(nonatomic, readonly) NSMapTable<req_NSString, req_UITableViewDelegate>* tableViewDelegateOverrides;

@property(nonatomic) NSMutableArray<AKATVSection*>* sectionSegments;
@property(nonatomic, readonly) NSUInteger numberOfSections;
@property(nonatomic, readonly) AKATVUpdateBatch* updateBatch;


#pragma mark - Configuration - Support for per-class log level setting

+ (DDLogLevel)ddLogLevel;
+ (void)ddSetLogLevel:(DDLogLevel)logLevel;

@end

@implementation AKATVMultiplexedDataSource

#pragma mark - Configuration

static DDLogLevel _ddLogLevel = DDLogLevelWarning;

+ (DDLogLevel)ddLogLevel
{
    return _ddLogLevel;
}

+ (void)ddSetLogLevel:(DDLogLevel)logLevel
{
    _ddLogLevel = logLevel;
}

#pragma mark - Initialization

+ (instancetype)proxyDataSourceAndDelegateForKey:(NSString*)dataSourceKey
                                     inTableView:(UITableView*)tableView
{
    id<UITableViewDataSource> originalDataSource = tableView.dataSource;
    AKATVMultiplexedDataSource* result = [[self alloc] initWithTableView:tableView];

    if (originalDataSource != nil)
    {
        NSString* key = dataSourceKey;
        id<UITableViewDataSource> dataSource = [result addDataSource:originalDataSource
                                                        withDelegate:tableView.delegate
                                                              forKey:key].dataSource;
        NSUInteger nbSections = (NSUInteger)[dataSource numberOfSectionsInTableView:tableView];
        [result insertSectionsFromDataSource:key
                          sourceSectionIndex:0
                                       count:nbSections
                              atSectionIndex:0
                           useRowsFromSource:YES
                                      update:NO
                            withRowAnimation:UITableViewRowAnimationNone];
        tableView.dataSource = result;
        tableView.delegate = result;
    }
    result->_defaultDataSourceKey = dataSourceKey;

    return result;
}

+ (instancetype)proxyDataSourceAndDelegateForKey:(NSString*)dataSourceKey
                                     inTableView:(UITableView*)tableView
                             andAppendDataSource:(id<UITableViewDataSource>)dataSource
                                    withDelegate:(id<UITableViewDelegate>)delegate
                                          forKey:(NSString*)key
{
    AKATVMultiplexedDataSource* result =
        [self proxyDataSourceAndDelegateForKey:dataSourceKey
                                   inTableView:tableView];

    [result addDataSource:dataSource
             withDelegate:delegate
                   forKey:key];
    NSUInteger nbSections = (NSUInteger)[dataSource numberOfSectionsInTableView:tableView];
    [result insertSectionsFromDataSource:key
                      sourceSectionIndex:0
                                   count:nbSections
                          atSectionIndex:nbSections
                       useRowsFromSource:YES
                        withRowAnimation:UITableViewRowAnimationNone];
    [tableView reloadData];

    return result;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _tableViewDelegateSelectorMapping = NSMutableDictionary.new;
        _dataSourcesByKey = NSMutableDictionary.new;

        _sectionSegments = [NSMutableArray new];
        _updateBatch = [AKATVUpdateBatch new];
    }

    return self;
}

- (instancetype)initWithTableView:(UITableView*)tableView
{
    if (self = [self init])
    {
        _tableView = tableView;
    }

    return self;
}

- (void)dealloc
{
    UITableView* tableView = self.tableView;

    if (tableView != nil && tableView.dataSource == self)
    {
        AKATVDataSourceSpecification* defaultDataSource =
            [self dataSourceForKey:self.defaultDataSourceKey];

        if (defaultDataSource)
        {
            tableView.dataSource = defaultDataSource.dataSource;
            tableView.delegate = defaultDataSource.delegate;
        }
    }
}

#pragma mark - Properties


#pragma mark - Managing Data Sources and associated Delegates

- (AKATVDataSourceSpecification*)addDataSource:(id<UITableViewDataSource>)dataSource
                                  withDelegate:(id<UITableViewDelegate>)delegate
                                        forKey:(NSString*)key
{
    NSParameterAssert(self.dataSourcesByKey[key] == nil);
    AKATVDataSourceSpecification* result = [AKATVDataSourceSpecification dataSource:dataSource
                                                                       withDelegate:delegate
                                                                             forKey:key
                                                                      inMultiplexer:self];
    self.dataSourcesByKey[key] = result;

    if (delegate != nil)
    {
        [self addTableViewDelegateSelectorsRespondedBy:delegate];
    }

    return result;
}

- (AKATVDataSourceSpecification*)addDataSourceAndDelegate:(id<UITableViewDataSource, UITableViewDelegate>)dataSource
                                                   forKey:(NSString*)key
{
    return [self addDataSource:dataSource
                  withDelegate:dataSource
                        forKey:key];
}

- (AKATVDataSourceSpecification*)dataSourceForKey:(NSString*)key
{
    return self.dataSourcesByKey[key];
}

#pragma mark - Batch Table View Updates

- (void)beginUpdates
{
    UITableView* tableView = self.tableView;

    AKALogVerbose(@"[self.updateBatch beginUpdatesForTableView:%p", tableView);
    [self.updateBatch beginUpdatesForTableView:tableView];
}

- (void)endUpdates
{
    UITableView* tableView = self.tableView;

    AKALogVerbose(@"[self.updateBatch endUpdatesForTableView:%p", tableView);
    [self.updateBatch endUpdatesForTableView:tableView];
}

#pragma mark - Adding and Removing Sections

- (void)insertSectionsFromDataSource:(NSString*)dataSourceKey
                  sourceSectionIndex:(NSUInteger)sourceSectionIndex
                               count:(NSUInteger)numberOfSections
                      atSectionIndex:(NSUInteger)targetSectionIndex
                   useRowsFromSource:(BOOL)useRowsFromSource
                    withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    [self insertSectionsFromDataSource:dataSourceKey
                    sourceSectionIndex:sourceSectionIndex
                                 count:numberOfSections
                        atSectionIndex:targetSectionIndex
                     useRowsFromSource:useRowsFromSource
                                update:YES
                      withRowAnimation:rowAnimation];
}

- (void)insertSectionsFromDataSource:(NSString*)dataSourceKey
                  sourceSectionIndex:(NSUInteger)sourceSectionIndex
                               count:(NSUInteger)numberOfSections
                      atSectionIndex:(NSUInteger)targetSectionIndex
                   useRowsFromSource:(BOOL)useRowsFromSource
                              update:(BOOL)update
                    withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert(targetSectionIndex >= 0 && targetSectionIndex <= self.numberOfSections);
    AKATVDataSourceSpecification* dataSourceEntry = [self dataSourceForKey:dataSourceKey];
    id<UITableViewDataSource> dataSource = dataSourceEntry.dataSource;

    for (NSUInteger i = 0; i < numberOfSections; ++i)
    {
        AKATVSection* section = [[AKATVSection alloc] initWithDataSource:dataSourceEntry
                                                                   index:(NSUInteger)sourceSectionIndex + i];

        if (useRowsFromSource)
        {
            [section insertRowsFromDataSource:dataSourceEntry
                              sourceIndexPath:[NSIndexPath indexPathForRow:0
                                                                 inSection:(NSInteger)(sourceSectionIndex + i)]
                                        count:(NSUInteger)[dataSource tableView:self.tableView
                                                          numberOfRowsInSection:(NSInteger)(sourceSectionIndex + i)]
                                   atRowIndex:0];
        }
        [self insertSection:section
                    atIndex:i + targetSectionIndex
                     update:update
           withRowAnimation:rowAnimation];
    }
}

- (void)insertSection:(AKATVSection*)section
              atIndex:(NSUInteger)sectionIndex
               update:(BOOL)update
     withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert(sectionIndex >= 0 && sectionIndex <= self.numberOfSections);
    UITableView* tableView = self.tableView;

    [self.sectionSegments insertObject:section atIndex:(NSUInteger)sectionIndex];

    if (tableView && update)
    {
        NSInteger correctedSectionIndex = [self.updateBatch
                                            insertionIndexForSection:(NSInteger)sectionIndex
                                           forBatchUpdateInTableView:tableView
                                               recordAsInsertedIndex:YES];
        [tableView insertSections:[NSIndexSet indexSetWithIndex:(NSUInteger)correctedSectionIndex]
                 withRowAnimation:rowAnimation];
    }
}

- (void)        remove:(NSUInteger)numberOfSections
       sectionsAtIndex:(NSUInteger)sectionIndex
      withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert(sectionIndex + numberOfSections <= self.numberOfSections);

    NSRange range = NSMakeRange(sectionIndex, numberOfSections);
    [self.sectionSegments removeObjectsInRange:range];
    UITableView* tableView = self.tableView;

    if (tableView)
    {
        NSInteger correctedSectionIndex = [self.updateBatch
                                             deletionIndexForSection:(NSInteger)sectionIndex
                                           forBatchUpdateInTableView:tableView
                                               recordAsInsertedIndex:YES];

        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange((NSUInteger)correctedSectionIndex, numberOfSections)];
        [tableView deleteSections:indexSet
                 withRowAnimation:rowAnimation];
    }
}

#pragma mark - Updating rows

- (void)reloadRowsAtIndexPaths:(NSArray*)indexPaths
              withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    UITableView* tableView = self.tableView;

    if (tableView)
    {
        NSArray* correctedIndexPaths = [self.updateBatch correctedIndexPaths:indexPaths];
        AKALogVerbose(@"[tableView:%p reloadRowsAtIndexPaths:@[%@]] withRowAnimation:%ld",
                      tableView, [correctedIndexPaths componentsJoinedByString:@", "], (long)rowAnimation);
        [tableView reloadRowsAtIndexPaths:correctedIndexPaths
                         withRowAnimation:rowAnimation];
    }

    return;
}

#pragma mark - Moving Rows

- (void)moveRowAtIndex:(NSInteger)rowIndex
             inSection:(NSInteger)sectionIndex
            toRowIndex:(NSInteger)targetIndex
{
    [self moveRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex
                                                inSection:sectionIndex]
                 toIndexPath:[NSIndexPath indexPathForRow:targetIndex
                                                inSection:sectionIndex]];
}

- (void)rowAtIndexPath:(NSIndexPath*)indexPath
    didMoveToIndexPath:(NSIndexPath*)targetIndexPath
{
    NSParameterAssert(indexPath.section >= 0 && indexPath.row >= 0);

    UITableView* tableView = self.tableView;

    if (tableView)
    {
        NSIndexPath* srcIndexPath = indexPath;
        NSIndexPath* tgtIndexPath = targetIndexPath;
        [self.updateBatch
            movementSourceRowIndex:&srcIndexPath
                    targetRowIndex:&tgtIndexPath
         forBatchUpdateInTableView:tableView
                  recordAsMovedRow:YES];
        AKALogVerbose(@"[tableView:%p moveRowAtIndexPath:%@ toIndexPath:%@]", tableView, srcIndexPath, tgtIndexPath);
        [tableView moveRowAtIndexPath:srcIndexPath
                          toIndexPath:tgtIndexPath];
    }

    return;
}

- (void)moveRowAtIndexPath:(NSIndexPath*)indexPath
               toIndexPath:(NSIndexPath*)targetIndexPath
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
                                       toIndex:(NSUInteger)targetIndexPath.row];
        }
        else
        {
            NSMutableArray* segments = [NSMutableArray new];
            result = (1 == [section removeUpTo:1
                                 rowsFromIndex:(NSUInteger)indexPath.row
                            removedRowSegments:segments]);
            NSAssert(segments.count == 1, nil);

            AKATVSection* targetSection = nil;

            if ([self resolveSectionSpecification:&targetSection
                                     sectionIndex:targetIndexPath.section])
            {
                [targetSection insertRowSegment:segments.firstObject
                                     atRowIndex:(NSUInteger)targetIndexPath.row];
            }
        }
    }
    else
    {
        // TODO: error handling
    }

    UITableView* tableView = self.tableView;

    if (result && tableView)
    {
        NSIndexPath* srcIndexPath = indexPath;
        NSIndexPath* tgtIndexPath = targetIndexPath;
        [self.updateBatch
            movementSourceRowIndex:&srcIndexPath
                    targetRowIndex:&tgtIndexPath
         forBatchUpdateInTableView:tableView
                  recordAsMovedRow:YES];
        AKALogVerbose(@"[tableView:%p moveRowAtIndexPath:%@ toIndexPath:%@]", tableView, srcIndexPath, tgtIndexPath);
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
                withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert([self dataSourceForKey:dataSourceKey] != nil);
    NSParameterAssert(sourceIndexPath.section >= 0 && sourceIndexPath.row >= 0);
    NSParameterAssert(indexPath.section >= 0 && indexPath.row >= 0);

    AKATVDataSourceSpecification* dataSource = [self dataSourceForKey:dataSourceKey];
    AKATVSection* section = nil;

    if ([self resolveSectionSpecification:&section
                             sectionIndex:indexPath.section])
    {
        UITableView* tableView = self.tableView;

        if ([section insertRowsFromDataSource:dataSource
                              sourceIndexPath:sourceIndexPath
                                        count:numberOfRows
                                   atRowIndex:(NSUInteger)indexPath.row])
        {
            if (tableView)
            {
                NSMutableArray* indexPaths = NSMutableArray.new;
                for (NSUInteger i = 0; i < numberOfRows; ++i)
                {
                    NSIndexPath* correctedIndexPath = [self.updateBatch
                                                        insertionIndexPathForRow:indexPath.row + (NSInteger)i
                                                                       inSection:indexPath.section
                                                       forBatchUpdateInTableView:tableView
                                                           recordAsInsertedIndex:YES];
                    [indexPaths addObject:correctedIndexPath];
                }

                AKALogVerbose(@"[tableView:%p insertRowsAtIndexPaths:@[%@] withRowAnimation:%ld]",
                              tableView, [indexPaths componentsJoinedByString:@", "], (long)rowAnimation);
                [tableView insertRowsAtIndexPaths:indexPaths
                                 withRowAnimation:rowAnimation];
            }
        }
        else
        {
            NSString* reason = [NSString stringWithFormat:
                                @"Index path %@ row %ld out of range 0..%ld",
                                indexPath, (long)indexPath.row, (long)[self        tableView:tableView
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

- (BOOL)excludeRowFromSourceIndexPath:(NSIndexPath*)sourceIndexPath
                         inDataSource:(AKATVDataSourceSpecification*)dataSource
                     withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    AKATVSection* section = nil;
    AKATVRowSegment* rowSegment = nil;
    NSUInteger rowSegmentIndex = NSNotFound;
    NSIndexPath* indexPath = nil;

    BOOL result = [self resolveSectionSpecification:&section
                                         rowSegment:&rowSegment
                                    rowSegmentIndex:&rowSegmentIndex
                                          indexPath:&indexPath
                                 forSourceIndexPath:sourceIndexPath
                                       inDataSource:dataSource];

    if (result)
    {
        NSUInteger offsetInSegment = (NSUInteger)(sourceIndexPath.row - rowSegment.indexPath.row);
        result = [section excludeRowAtOffset:offsetInSegment
                                inRowSegment:rowSegment
                              atSegmentIndex:rowSegmentIndex];
        UITableView* tableView = self.tableView;

        if (result && tableView)
        {
            NSIndexPath* correctedIndexPath = [self.updateBatch
                                                 deletionIndexPathForRow:indexPath.row
                                                               inSection:indexPath.section
                                               forBatchUpdateInTableView:tableView
                                                    recordAsDeletedIndex:YES];
            AKALogVerbose(@"[tableView:%p deleteRowsAtIndexPaths:@[%@] withRowAnimation:%ld]",
                          tableView, correctedIndexPath, (long)rowAnimation);
            [tableView deleteRowsAtIndexPaths:@[ correctedIndexPath ]
                             withRowAnimation:rowAnimation];
        }
    }

    return result;
}

- (BOOL)includeRowFromSourceIndexPath:(NSIndexPath*)sourceIndexPath
                         inDataSource:(AKATVDataSourceSpecification*)dataSource
                     withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    AKATVSection* section = nil;
    AKATVRowSegment* rowSegment = nil;
    NSUInteger rowSegmentIndex = NSNotFound;
    NSIndexPath* indexPath = nil;

    BOOL result = [self resolveSectionSpecification:&section
                                         rowSegment:&rowSegment
                                    rowSegmentIndex:&rowSegmentIndex
                                          indexPath:&indexPath
                                 forSourceIndexPath:sourceIndexPath
                                       inDataSource:dataSource];

    if (result)
    {
        NSAssert(rowSegment.isExcluded && rowSegment.numberOfRows == 0, @"Expected %@ to be an excluded row segment with numberOfRows==0", rowSegment);

        result = [section includeRowSegment:rowSegment
                             atSegmentIndex:rowSegmentIndex];

        UITableView* tableView = self.tableView;

        if (result && tableView)
        {
            NSIndexPath* correctedIndexPath = [self.updateBatch
                                                insertionIndexPathForRow:indexPath.row
                                                               inSection:indexPath.section
                                               forBatchUpdateInTableView:tableView
                                                   recordAsInsertedIndex:YES];

            AKALogVerbose(@"[tableView:%p insertRowsAtIndexPaths:@[%@] withRowAnimation:%ld]",
                          tableView, correctedIndexPath, (long)rowAnimation);
            [tableView insertRowsAtIndexPaths:@[ correctedIndexPath ]
                             withRowAnimation:rowAnimation];
        }
    }

    return result;
}

- (BOOL)excludeRowAtIndexPath:(NSIndexPath*)indexPath
             withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert(indexPath.section >= 0 && indexPath.row >= 0);

    BOOL result = NO;

    AKATVSection* section = nil;

    if ([self resolveSectionSpecification:&section
                             sectionIndex:indexPath.section])
    {
        result = [section excludeRowFromIndex:indexPath.row];
        UITableView* tableView = self.tableView;

        if (result && tableView)
        {
            NSIndexPath* correctedIndexPath = [self.updateBatch
                                                 deletionIndexPathForRow:indexPath.row
                                                               inSection:indexPath.section
                                               forBatchUpdateInTableView:tableView
                                                    recordAsDeletedIndex:YES];
            AKALogVerbose(@"[tableView:%p deleteRowsAtIndexPaths:@[%@] withRowAnimation:%ld]",
                          tableView, correctedIndexPath, (long)rowAnimation);
            [tableView deleteRowsAtIndexPaths:@[ correctedIndexPath ]
                             withRowAnimation:rowAnimation];
        }
    }

    return result;
}

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
       rowsFromIndexPath:(NSIndexPath*)indexPath
        withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSParameterAssert(indexPath.section >= 0 && indexPath.row >= 0);

    NSUInteger rowsRemoved = 0;
    UITableView* tableView = self.tableView;
    AKATVSection* section = nil;

    if ([self resolveSectionSpecification:&section
                             sectionIndex:indexPath.section])
    {
        rowsRemoved = [section removeUpTo:numberOfRows
                            rowsFromIndex:(NSUInteger)indexPath.row];

        if (rowsRemoved > 0 && tableView)
        {
            NSMutableArray* indexPaths = NSMutableArray.new;
            for (NSUInteger i = 0; i < rowsRemoved; ++i)
            {
                NSIndexPath* correctedIndexPath = [self.updateBatch
                                                     deletionIndexPathForRow:indexPath.row + (NSInteger)i
                                                                   inSection:indexPath.section
                                                   forBatchUpdateInTableView:tableView
                                                        recordAsDeletedIndex:YES];
                [indexPaths addObject:correctedIndexPath];
            }

            AKALogVerbose(@"[tableView:%p deleteRowsAtIndexPaths:@[%@] withRowAnimation:%ld]",
                          tableView, [indexPaths componentsJoinedByString:@", "], (long)rowAnimation);
            [tableView deleteRowsAtIndexPaths:indexPaths
                             withRowAnimation:rowAnimation];
        }
    }

    return rowsRemoved;
}

#pragma mark - Source Coordinate Changes

- (void)          dataSourceWithKey:(req_NSString)key
             insertedRowAtIndexPath:(req_NSIndexPath)indexPath
{
    [self.sectionSegments
     enumerateObjectsUsingBlock:
     ^(AKATVSection* _Nonnull sectionSegment,
       NSUInteger sectionIndex,
       BOOL* _Nonnull stopSectionEnumeration)
     {
         (void)sectionIndex;
         (void)stopSectionEnumeration;
         [sectionSegment dataSourceWithKey:key
                    insertedRowAtIndexPath:indexPath];
     }];
}

- (void)          dataSourceWithKey:(req_NSString)key
              removedRowAtIndexPath:(req_NSIndexPath)indexPath
{
    [self.sectionSegments
     enumerateObjectsUsingBlock:
     ^(AKATVSection* _Nonnull sectionSegment,
       NSUInteger sectionIndex,
       BOOL* _Nonnull stopSectionEnumation)
     {
         (void)sectionIndex;
         (void)stopSectionEnumation;
         [sectionSegment dataSourceWithKey:key
                     removedRowAtIndexPath:indexPath];
     }];
}

- (void)          dataSourceWithKey:(req_NSString)key
              movedRowFromIndexPath:(req_NSIndexPath)fromIndexPath
                        toIndexPath:(req_NSIndexPath)toIndexPath
{
    [self.sectionSegments
     enumerateObjectsUsingBlock:
     ^(AKATVSection* _Nonnull sectionSegment,
       NSUInteger sectionIndex,
       BOOL* _Nonnull stopSectionEnumation)
     {
         (void)sectionIndex;
         (void)stopSectionEnumation;
         [sectionSegment dataSourceWithKey:key
                     movedRowFromIndexPath:fromIndexPath
                               toIndexPath:toIndexPath];
     }];
}

#pragma mark - Resolution

- (BOOL)resolveSectionSpecification:(out AKATVSection* __strong* __nullable)sectionStorage
                         rowSegment:(out AKATVRowSegment* __strong* __nullable)rowSegmentStorage
                    rowSegmentIndex:(out NSUInteger* __nullable)rowSegmentIndexStorage
                          indexPath:(out NSIndexPath* __strong* __nullable)indexPathStorage
                 forSourceIndexPath:(NSIndexPath*)sourceIndexPath
                       inDataSource:(AKATVDataSourceSpecification*)dataSource
{
    __block BOOL result = NO;

    NSInteger sourceSection = sourceIndexPath.section;
    NSInteger sourceRow = sourceIndexPath.row;

    [self.sectionSegments
     enumerateObjectsUsingBlock:^(id obj, NSUInteger sectionIndex, BOOL* stopSection) {
         (void)stopSection;
         AKATVSection* section = obj;
         __block NSUInteger offset = 0;
         [section enumerateRowSegmentsUsingBlock:^(AKATVRowSegment* rowSegment,
                                                   NSUInteger rowSegmentIndex,
                                                   BOOL* stop) {
              (void)rowSegmentIndex;
              NSIndexPath* segmentIndexPath = rowSegment.indexPath;
              NSInteger segmentSection = segmentIndexPath.section;
              NSInteger segmentRow = segmentIndexPath.row;
              NSUInteger segmentRowCount = rowSegment.numberOfRows;

              if (dataSource == rowSegment.dataSource &&
                  sourceSection == segmentSection &&
                  sourceRow >= segmentRow &&
                  (sourceRow < segmentRow + (NSInteger)segmentRowCount ||
                   (rowSegment.isExcluded && sourceRow == segmentRow)
                  )
                  )
              {
                  result = *stop = *stopSection = YES;

                  if (sectionStorage != nil)
                  {
                      *sectionStorage = section;
                  }

                  if (rowSegmentIndexStorage != nil)
                  {
                      *rowSegmentIndexStorage = rowSegmentIndex;
                  }

                  if (rowSegmentStorage != nil)
                  {
                      *rowSegmentStorage = rowSegment;
                  }

                  if (indexPathStorage != nil)
                  {
                      NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)offset + (sourceRow - segmentRow)
                                                                  inSection:(NSInteger)sectionIndex];
                      *indexPathStorage = indexPath;
                  }
              }
              offset += segmentRowCount;
          }];
     }];

    return result;
}

- (BOOL)resolveIndexPath:(out NSIndexPath* __strong* __nullable)indexPathStorage
      forSourceIndexPath:(NSIndexPath* __nonnull)sourceIndexPath
            inDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource
{
    return [self resolveSectionSpecification:nil
                                  rowSegment:nil
                             rowSegmentIndex:nil
                                   indexPath:indexPathStorage
                          forSourceIndexPath:sourceIndexPath
                                inDataSource:dataSource];
}

- (BOOL)resolveSection:(out NSInteger* __nullable)sectionStorage
      forSourceSection:(NSInteger)sourceSection
          inDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource
{
    __block BOOL result = NO;

    [self.sectionSegments
     enumerateObjectsUsingBlock:^(id obj, NSUInteger sectionIndex, BOOL* stop) {
         AKATVSection* section = obj;

         if (section.dataSource == dataSource &&
             section.sectionIndex == (NSUInteger)sourceSection)
         {
             result = *stop = YES;

             if (sectionStorage != nil)
             {
                 *sectionStorage = (NSInteger)sectionIndex;
             }
         }
     }];

    return result;
}

- (BOOL)resolveSectionSpecification:(out AKATVSection* __autoreleasing* __nullable)sectionStorage
                       sectionIndex:(NSInteger)sectionIndex
{
    BOOL result = sectionIndex >= 0 && (NSUInteger)sectionIndex < self.numberOfSections;

    if (result)
    {
        if (sectionStorage != nil)
        {
            (*sectionStorage) = self.sectionSegments[(NSUInteger)sectionIndex];
        }
    }

    return result;
}

- (BOOL)resolveAKADataSource:(out AKATVDataSourceSpecification* __autoreleasing* __nullable)dataSourceStorage
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
            (*sectionIndexStorage) = (NSInteger)sectionSpecification.sectionIndex;
        }
    }

    return result;
}

- (BOOL)resolveDataSource:(out __autoreleasing id<UITableViewDataSource>*)dataSourceStorage
                 delegate:(out __autoreleasing id<UITableViewDelegate>*)delegateStorage
          sourceIndexPath:(out NSIndexPath* __autoreleasing*)indexPathStorage
             forIndexPath:(NSIndexPath*)indexPath
{
    AKATVDataSourceSpecification* dataSource = nil;
    BOOL result = [self resolveAKADataSource:&dataSource
                             sourceIndexPath:indexPathStorage
                                forIndexPath:indexPath];

    if (result)
    {
        if (dataSourceStorage != nil)
        {
            *dataSourceStorage = dataSource.dataSource;
        }

        if (delegateStorage != nil)
        {
            *delegateStorage = dataSource.delegate;
        }
    }

    return result;
}

- (BOOL)resolveAKADataSource:(out AKATVDataSourceSpecification* __autoreleasing* __nullable)dataSourceStorage
             sourceIndexPath:(out NSIndexPath* __autoreleasing* __nullable)indexPathStorage
                forIndexPath:(NSIndexPath*)indexPath
{
    NSInteger sectionIndex = indexPath.section;
    AKATVSection* sectionSpecification = nil;
    BOOL result = [self resolveSectionSpecification:&sectionSpecification
                                       sectionIndex:sectionIndex];

    if (result)
    {
        NSUInteger rowIndex = (NSUInteger)indexPath.row;
        NSIndexPath* sourceIndexPath = nil;
        AKATVDataSourceSpecification* dataSourceEntry = nil;
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

#pragma mark - Data Source Protocol Implementation

- (NSUInteger)numberOfSections
{
    return self.sectionSegments.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    (void)tableView;
    NSInteger result = (NSInteger)self.numberOfSections;
    AKALogVerbose(@"[self numberOfSectionsInTableView:%p] (%ld)", tableView, (long)result);

    return result;
}

- (UITableViewCell*)            tableView:(UITableView*)tableView
                    cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* result = nil;

    id<UITableViewDataSource> dataSource = nil;
    NSIndexPath* resolvedIndexPath = indexPath;

    if ([self resolveDataSource:&dataSource delegate:nil sourceIndexPath:&resolvedIndexPath forIndexPath:indexPath])
    {
        result = [dataSource  tableView:tableView
                  cellForRowAtIndexPath:resolvedIndexPath];
    }
    AKALogVerbose(@"[tableView:%p cellForRowAtIndexPath:%@] (%@, dataSource = %@)", tableView, indexPath, result, dataSource);

    return result;
}

- (NSInteger)                   tableView:(UITableView*)tableView
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
    AKALogVerbose(@"[tableView:%p numberOfRowsInSection:%ld] (%ld)", tableView, (long)section, (long)result);

    return result;
}

- (BOOL)                        tableView:(UITableView*)tableView
                    canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL result = NO;

    id<UITableViewDataSource> dataSource = nil;
    NSIndexPath* resolvedIndexPath = indexPath;

    if ([self resolveDataSource:&dataSource delegate:nil sourceIndexPath:&resolvedIndexPath forIndexPath:indexPath])
    {
        if ([dataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
        {
            result = [dataSource  tableView:tableView
                      canEditRowAtIndexPath:resolvedIndexPath];
        }
    }

    return result;
}

- (void)                        tableView:(UITableView*)tableView
                       commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                        forRowAtIndexPath:(NSIndexPath*)indexPath
{
    id<UITableViewDataSource> dataSource = nil;
    NSIndexPath* resolvedIndexPath = indexPath;

    if ([self resolveDataSource:&dataSource delegate:nil sourceIndexPath:&resolvedIndexPath forIndexPath:indexPath])
    {
        if ([dataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
        {
            [dataSource tableView:tableView
               commitEditingStyle:editingStyle
                forRowAtIndexPath:resolvedIndexPath];
        }
    }
}

- (BOOL)                        tableView:(UITableView*)tableView
                    canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL result = NO;

    id<UITableViewDataSource> dataSource = nil;
    NSIndexPath* resolvedIndexPath = indexPath;

    if ([self resolveDataSource:&dataSource delegate:nil sourceIndexPath:&resolvedIndexPath forIndexPath:indexPath])
    {
        if ([dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)])
        {
            result = [dataSource  tableView:tableView
                      canMoveRowAtIndexPath:resolvedIndexPath];
        }
    }

    return result;
}

- (NSString*)                  tableView:(UITableView*)tableView
                 titleForFooterInSection:(NSInteger)section
{
    NSString* result = nil;
    AKATVDataSourceSpecification* akaDataSource = nil;
    NSInteger resolvedSection = section;

    if ([self resolveAKADataSource:&akaDataSource
                sourceSectionIndex:&resolvedSection
                   forSectionIndex:section])
    {
        id<UITableViewDataSource> dataSource = akaDataSource.dataSource;

        if ([dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)])
        {
            result = [dataSource tableView:tableView titleForFooterInSection:resolvedSection];
        }
    }

    return result;
}

- (NSString*)                  tableView:(UITableView*)tableView
                 titleForHeaderInSection:(NSInteger)section
{
    NSString* result = nil;
    AKATVDataSourceSpecification* akaDataSource = nil;
    NSInteger resolvedSection = section;

    if ([self resolveAKADataSource:&akaDataSource
                sourceSectionIndex:&resolvedSection
                   forSectionIndex:section])
    {
        id<UITableViewDataSource> dataSource = akaDataSource.dataSource;

        if ([dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)])
        {
            result = [dataSource tableView:tableView titleForHeaderInSection:resolvedSection];
        }
    }

    return result;
}

#pragma mark - Not implemented data source methods:

#if NO
- (void)                        tableView:(UITableView*)tableView
                       moveRowAtIndexPath:(NSIndexPath*)sourceIndexPath
                              toIndexPath:(NSIndexPath*)destinationIndexPath
{
    // Not implemented becuase I have no idea yet how to handle cross DS row movements.
    // This should probably be implemented in a subclass of the multiplexed data source
    // TODO: implement this if at all possible.
    (void)tableView;
    (void)sourceIndexPath;
    (void)destinationIndexPath;
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSInteger)                   tableView:(UITableView*)tableView
              sectionForSectionIndexTitle:(NSString*)title
                                  atIndex:(NSInteger)index
{
    // Not implemented becuase I have no idea yet how to handle cross DS section indexes.
    // This should probably be implemented in a subclass of the multiplexed data source
    // TODO: implement this if at all possible.
    (void)tableView;
    (void)title;
    (void)index;
    AKAErrorAbstractMethodImplementationMissing();
}

#endif

#pragma mark - UITableViewDelegate

#if 0
- (CGFloat)                 tableView:(UITableView*)tableView
             heightForHeaderInSection:(NSInteger)section
{
    return [self            tableView:tableView
             heightForHeaderInSection:section
                          withDefault:tableView.sectionHeaderHeight];
}

- (CGFloat)                 tableView:(UITableView*)tableView
             heightForHeaderInSection:(NSInteger)section
                          withDefault:(CGFloat)defaultHeight
{
    CGFloat result = defaultHeight;

    AKATVDataSourceSpecification* dataSource = nil;
    NSInteger sourceSection = NSNotFound;

    if ([self resolveAKADataSource:&dataSource
                sourceSectionIndex:&sourceSection
                   forSectionIndex:section])
    {
        id<UITableViewDelegate> delegate = dataSource.delegate;

        if ([delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
        {
            result = [delegate       tableView:[dataSource proxyForTableView:tableView]
                      heightForHeaderInSection:sourceSection];
        }
    }

    return result;
}

- (CGFloat)                 tableView:(UITableView*)tableView
    estimatedHeightForHeaderInSection:(NSInteger)section
{
    return [self                    tableView:tableView
            estimatedHeightForHeaderInSection:section
                                  withDefault:tableView.estimatedSectionHeaderHeight];
}

- (CGFloat)                 tableView:(UITableView*)tableView
    estimatedHeightForHeaderInSection:(NSInteger)section
                          withDefault:(CGFloat)defaultHeight
{
    CGFloat result = defaultHeight;

    AKATVDataSourceSpecification* dataSource = nil;
    NSInteger sourceSection = NSNotFound;

    if ([self resolveAKADataSource:&dataSource
                sourceSectionIndex:&sourceSection
                   forSectionIndex:section])
    {
        id<UITableViewDelegate> delegate = dataSource.delegate;

        if ([delegate respondsToSelector:@selector(tableView:estimatedHeightForHeaderInSection:)])
        {
            result = [delegate                tableView:[dataSource proxyForTableView:tableView]
                      estimatedHeightForHeaderInSection:sourceSection];
        }
    }

    return result;
}

- (CGFloat)                 tableView:(UITableView*)tableView
             heightForFooterInSection:(NSInteger)section
{
    return [self            tableView:tableView
             heightForFooterInSection:section
                          withDefault:tableView.sectionFooterHeight];
}

- (CGFloat)                 tableView:(UITableView*)tableView
             heightForFooterInSection:(NSInteger)section
                          withDefault:(CGFloat)defaultHeight
{
    CGFloat result = defaultHeight;

    AKATVDataSourceSpecification* dataSource = nil;
    NSInteger sourceSection = NSNotFound;

    if ([self resolveAKADataSource:&dataSource
                sourceSectionIndex:&sourceSection
                   forSectionIndex:section])
    {
        id<UITableViewDelegate> delegate = dataSource.delegate;

        if ([delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)])
        {
            result = [delegate       tableView:[dataSource proxyForTableView:tableView]
                      heightForFooterInSection:sourceSection];
        }
    }

    return result;
}

- (CGFloat)                 tableView:(UITableView*)tableView
    estimatedHeightForFooterInSection:(NSInteger)section
{
    return [self                    tableView:tableView
            estimatedHeightForFooterInSection:section
                                  withDefault:tableView.estimatedSectionFooterHeight];
}

- (CGFloat)                 tableView:(UITableView*)tableView
    estimatedHeightForFooterInSection:(NSInteger)section
                          withDefault:(CGFloat)defaultHeight
{
    CGFloat result = defaultHeight;

    AKATVDataSourceSpecification* dataSource = nil;
    NSInteger sourceSection = NSNotFound;

    if ([self resolveAKADataSource:&dataSource
                sourceSectionIndex:&sourceSection
                   forSectionIndex:section])
    {
        id<UITableViewDelegate> delegate = dataSource.delegate;

        if ([delegate respondsToSelector:@selector(tableView:estimatedHeightForFooterInSection:)])
        {
            result = [delegate                tableView:[dataSource proxyForTableView:tableView]
                      estimatedHeightForFooterInSection:sourceSection];
        }
    }

    return result;
}

#endif

- (CGFloat)                 tableView:(UITableView*)tableView
              heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self            tableView:tableView
              heightForRowAtIndexPath:indexPath
                          withDefault:tableView.rowHeight];
}

- (CGFloat)                 tableView:(UITableView*)tableView
              heightForRowAtIndexPath:(NSIndexPath*)indexPath
                          withDefault:(CGFloat)defaultHeight
{
    CGFloat result = defaultHeight;

    AKATVDataSourceSpecification* dataSource = nil;
    NSIndexPath* sourceIndexPath = nil;

    if ([self resolveAKADataSource:&dataSource
                   sourceIndexPath:&sourceIndexPath
                      forIndexPath:indexPath])
    {
        id<UITableViewDelegate> delegate = dataSource.delegate;

        if ([delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
        {
            result = [delegate      tableView:[dataSource proxyForTableView:tableView]
                      heightForRowAtIndexPath:sourceIndexPath];
        }
#if 0
        AKALogDebug(@"row %ld-%ld height %lf from delegate %@ (%ld-%ld)",
                    (long)indexPath.section, (long)indexPath.row, result,
                    delegate, (long)sourceIndexPath.section, (long)sourceIndexPath.row);
    }
    else
    {
        AKALogDebug(@"row %ld-%ld height %lf (default)",
                    (long)indexPath.section, (long)indexPath.row, result);

#endif
    }

    return result;
}

- (CGFloat)                 tableView:(UITableView*)tableView
     estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self                   tableView:tableView
            estimatedHeightForRowAtIndexPath:indexPath
                                 withDefault:tableView.estimatedRowHeight];
}

- (CGFloat)                 tableView:(UITableView*)tableView
     estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
                          withDefault:(CGFloat)defaultHeight
{
    CGFloat result = defaultHeight;

    AKATVDataSourceSpecification* dataSource = nil;
    NSIndexPath* sourceIndexPath = nil;

    if ([self resolveAKADataSource:&dataSource
                   sourceIndexPath:&sourceIndexPath
                      forIndexPath:indexPath])
    {
        id<UITableViewDelegate> delegate = dataSource.delegate;

        if ([delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)])
        {
            result = [delegate               tableView:[dataSource proxyForTableView:tableView]
                      estimatedHeightForRowAtIndexPath:sourceIndexPath];
        }
#if 0
        AKALogDebug(@"row %ld-%ld estimated height %lf from delegate %@ (%ld-%ld)",
                    (long)indexPath.section, (long)indexPath.row, result,
                    delegate, (long)sourceIndexPath.section, (long)sourceIndexPath.row);
    }
    else
    {
        AKALogDebug(@"row %ld-%ld estimated height %lf (default)",
                    (long)indexPath.section, (long)indexPath.row, result);
#endif
    }

    return result;
}

- (BOOL)forwardDelegateInvocation:(NSInvocation*)invocation
    withTableViewParameterAtIndex:(NSInteger)tvParameterIndex
          sectionParameterAtIndex:(NSInteger)parameterIndex
               resolveCoordinates:(BOOL)resolveCoordinates
                useTableViewProxy:(BOOL)useTableViewProxy
                 resolvedDelegate:(id <UITableViewDelegate> __autoreleasing*)delegateStorage
{
    id<UITableViewDelegate> delegate = nil;
    AKATVDataSourceSpecification* dataSource = nil;
    NSInteger section = NSNotFound;
    NSInteger sourceSection = NSNotFound;
    [invocation getArgument:&section atIndex:2 + parameterIndex];
    BOOL result = [self resolveAKADataSource:&dataSource
                          sourceSectionIndex:&sourceSection
                             forSectionIndex:section];

    if (result)
    {
        delegate = dataSource.delegate;

        if (delegateStorage != nil)
        {
            *delegateStorage = delegate;
        }
        result = [delegate respondsToSelector:invocation.selector];

        if (result)
        {
            if (resolveCoordinates)
            {
                if (useTableViewProxy)
                {
                    [invocation retainArguments]; // TODO: check if this is really needed

                    UITableView* __unsafe_unretained tableView = nil;
                    [invocation getArgument:&tableView atIndex:2 + tvParameterIndex];

                    UITableView* tableViewProxy = [dataSource proxyForTableView:tableView];
                    [invocation setArgument:&tableViewProxy atIndex:2 + tvParameterIndex];
                }
                [invocation setArgument:&sourceSection atIndex:2 + parameterIndex];
            }

            /*AKALogDebug(@"[%@.delegate %@] section=%ld (%ld)",
                        dataSource.key,
                        NSStringFromSelector(invocation.selector),
                        (long)section,
                        (long)sourceSection);*/
            [invocation invokeWithTarget:delegate];
        }
    }

    return result;
}

- (BOOL)forwardDelegateInvocation:(NSInvocation*)invocation
    withTableViewParameterAtIndex:(NSInteger)tvParameterIndex
        indexPathParameterAtIndex:(NSInteger)parameterIndex
               resolveCoordinates:(BOOL)resolveCoordinates
                useTableViewProxy:(BOOL)useTableViewProxy
                 resolvedDelegate:(id <UITableViewDelegate> __autoreleasing*)delegateStorage
{
    return [self forwardDelegateInvocation:invocation
             withTableViewParameterAtIndex:tvParameterIndex
                 indexPathParameterAtIndex:parameterIndex
                           indexPathResult:NO
                        resolveCoordinates:resolveCoordinates
                         useTableViewProxy:useTableViewProxy
                          resolvedDelegate:delegateStorage];
}

- (BOOL)forwardDelegateInvocation:(NSInvocation*)invocation
    withTableViewParameterAtIndex:(NSInteger)tvParameterIndex
        indexPathParameterAtIndex:(NSInteger)parameterIndex
                  indexPathResult:(BOOL)resolveIndexPathResult
               resolveCoordinates:(BOOL)resolveCoordinates
                useTableViewProxy:(BOOL)useTableViewProxy
                 resolvedDelegate:(id <UITableViewDelegate> __autoreleasing*)delegateStorage
{
    id<UITableViewDelegate> delegate = nil;
    AKATVDataSourceSpecification* dataSource = nil;

    NSIndexPath* __unsafe_unretained indexPath;
    [invocation getArgument:&indexPath atIndex:2 + parameterIndex];

    NSIndexPath* sourceIndexPath = nil;
    BOOL result = [self resolveAKADataSource:&dataSource
                             sourceIndexPath:&sourceIndexPath
                                forIndexPath:indexPath];

    if (result)
    {
        delegate = dataSource.delegate;

        if (delegateStorage != nil)
        {
            *delegateStorage = delegate;
        }
        result = [delegate respondsToSelector:invocation.selector];

        if (result)
        {
            if (resolveCoordinates)
            {
                if (useTableViewProxy)
                {
                    [invocation retainArguments];

                    UITableView* __unsafe_unretained tableView = nil;
                    [invocation getArgument:&tableView atIndex:2 + tvParameterIndex];

                    UITableView* tableViewProxy = [dataSource proxyForTableView:tableView];
                    [invocation setArgument:&tableViewProxy atIndex:2 + tvParameterIndex];
                }
                [invocation setArgument:&sourceIndexPath atIndex:2 + parameterIndex];
            }

            /*AKALogDebug(@"[%@.delegate %@] indexPath=[%ld-%ld] ([%ld-%ld])",
                        dataSource.key,
                        NSStringFromSelector(invocation.selector),
                        (long)indexPath.section, (long)indexPath.row,
                        (long)sourceIndexPath.section, (long)sourceIndexPath.row);*/
            [invocation invokeWithTarget:delegate];

            if (resolveIndexPathResult)
            {
                NSIndexPath* __unsafe_unretained invocationResult = nil;
                [invocation getReturnValue:&invocationResult];

                NSIndexPath* reverseResolvedInvocationResult = nil;

                if ([self resolveIndexPath:&reverseResolvedInvocationResult
                        forSourceIndexPath:invocationResult
                              inDataSource:dataSource])
                {
                    [invocation setReturnValue:&reverseResolvedInvocationResult];
                }
            }
        }
    }

    return result;
}

- (BOOL) forwardDelegateInvocation:(NSInvocation*)invocation
    withScrollViewParameterAtIndex:(NSInteger)tvParameterIndex
                  resolvedDelegate:(id <UITableViewDelegate> __autoreleasing*)delegateStorage
{
    (void)tvParameterIndex; // TODO: remove parameter reference or proxy scrollview if needed
    AKATVDataSourceSpecification* dataSource = (self.defaultDataSourceKey.length > 0
                                                ? self.dataSourcesByKey[self.defaultDataSourceKey]
                                                : nil);
    id <UITableViewDelegate> delegate = dataSource.delegate;
    BOOL result = delegate != nil;

    if (result)
    {
        if (delegateStorage != nil)
        {
            *delegateStorage = delegate;
        }
        result = [delegate respondsToSelector:invocation.selector];

        if (result)
        {
            [invocation invokeWithTarget:delegate];
        }
    }

    return result;
}

+ (NSDictionary*)sharedTableViewDelegateSelectorMapping
{
    static NSDictionary<NSString*, NSNumber*>* sharedInstance = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
        sharedInstance =
            @{ NSStringFromSelector(@selector(tableView:heightForHeaderInSection:)): @(resolveSectionAt1),
               NSStringFromSelector(@selector(tableView:heightForFooterInSection:)): @(resolveSectionAt1),
               NSStringFromSelector(@selector(tableView:viewForHeaderInSection:)): @(resolveSectionAt1),
               NSStringFromSelector(@selector(tableView:viewForFooterInSection:)): @(resolveSectionAt1),
               NSStringFromSelector(@selector(tableView:estimatedHeightForHeaderInSection:)): @(resolveSectionAt1),
               NSStringFromSelector(@selector(tableView:estimatedHeightForFooterInSection:)): @(resolveSectionAt1),

               NSStringFromSelector(@selector(tableView:willDisplayHeaderView:forSection:)): @(resolveSectionAt2),
               NSStringFromSelector(@selector(tableView:willDisplayFooterView:forSection:)): @(resolveSectionAt2),
               NSStringFromSelector(@selector(tableView:didEndDisplayingHeaderView:forSection:)): @(resolveSectionAt2),
               NSStringFromSelector(@selector(tableView:didEndDisplayingFooterView:forSection:)): @(resolveSectionAt2),

               NSStringFromSelector(@selector(tableView:heightForRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:estimatedHeightForRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:accessoryTypeForRowWithIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:shouldHighlightRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:didHighlightRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:didUnhighlightRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:didSelectRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:didDeselectRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:editingStyleForRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:editActionsForRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:willBeginEditingRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:didEndEditingRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:indentationLevelForRowAtIndexPath:)): @(resolveIndexPathAt1),
               NSStringFromSelector(@selector(tableView:shouldShowMenuForRowAtIndexPath:)): @(resolveIndexPathAt1),

               NSStringFromSelector(@selector(tableView:willSelectRowAtIndexPath:)): @(resolveIndexPathAt1AndResultIndexPath),
               NSStringFromSelector(@selector(tableView:willDeselectRowAtIndexPath:)): @(resolveIndexPathAt1AndResultIndexPath),

               NSStringFromSelector(@selector(tableView:willDisplayCell:forRowAtIndexPath:)): @(resolveIndexPathAt2),
               NSStringFromSelector(@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)): @(resolveIndexPathAt2),
               NSStringFromSelector(@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)): @(resolveIndexPathAt2),
               NSStringFromSelector(@selector(tableView:performAction:forRowAtIndexPath:withSender:)): @(resolveIndexPathAt2),

               NSStringFromSelector(@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)): @(resolveIndexPathAt1And2),

               NSStringFromSelector(@selector(scrollViewDidScroll:)): @(resolveScrollViewDelegate),
               NSStringFromSelector(@selector(scrollViewWillBeginDragging:)): @(resolveScrollViewDelegate),
               NSStringFromSelector(@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)): @(resolveScrollViewDelegate),
               NSStringFromSelector(@selector(scrollViewDidEndDragging:willDecelerate:)): @(resolveScrollViewDelegate),
               NSStringFromSelector(@selector(scrollViewShouldScrollToTop:)): @(resolveScrollViewDelegate),
               NSStringFromSelector(@selector(scrollViewDidScrollToTop:)): @(resolveScrollViewDelegate),
               NSStringFromSelector(@selector(scrollViewWillBeginDecelerating:)): @(resolveScrollViewDelegate),
               NSStringFromSelector(@selector(scrollViewDidEndDecelerating:)): @(resolveScrollViewDelegate),

               NSStringFromSelector(@selector(viewForZoomingInScrollView:)): @(resolveScrollViewDelegate),
               NSStringFromSelector(@selector(scrollViewWillBeginZooming:withView:)): @(resolveScrollViewDelegate),
               NSStringFromSelector(@selector(scrollViewDidEndZooming:withView:atScale:)): @(resolveScrollViewDelegate),
               NSStringFromSelector(@selector(scrollViewDidZoom:)): @(resolveScrollViewDelegate),

               NSStringFromSelector(@selector(scrollViewDidEndScrollingAnimation:)): @(resolveScrollViewDelegate), };
    });

    return sharedInstance;
}

/**
 * Inspects the specified delegate instance and identifies all methods conforming to the
 * UITableViewDelegate that have been overridden by the delegates class relative to the specified
 * type. Does nothing if the delegates class is not a subclass of the specified type or if
 * it's class is the specified type.
 *
 * For all registered methods, the multiplexer will not dispatch table view delegate messages to
 * the specified delegate without performing section or indexPath resolution and it will pass the
 * original table view instead of proxy. Consequently, method implementations have to be aware of
 * the multiplexer and it's implications.
 *
 * @param type a base class of the specified delegates class
 * @param delegate the delegate to inspect.
 */
- (void)registerTableViewDelegateOverridesTo:(Class)type
                                fromDelegate:(id<UITableViewDelegate>)delegate
{
    Class delegateType = delegate.class;

    if (delegateType != type && [delegateType isSubclassOfClass:type])
    {
        NSDictionary* sharedMappings = [AKATVMultiplexedDataSource sharedTableViewDelegateSelectorMapping];
        for (NSString* selectorValue in sharedMappings.keyEnumerator)
        {
            SEL selector = NSSelectorFromString(selectorValue);

            if ([delegate respondsToSelector:selector])
            {
                if ([delegateType instanceMethodForSelector:selector] != [type instanceMethodForSelector:selector])
                {
                    if (self.tableViewDelegateOverrides == nil)
                    {
                        _tableViewDelegateOverrides = [NSMapTable strongToWeakObjectsMapTable];
                    }
                    [self.tableViewDelegateOverrides setObject:delegate forKey:selectorValue];
                }
            }
        }
    }
}

- (void)addTableViewDelegateSelectorsRespondedBy:(id<UITableViewDelegate>)delegate
{
    NSDictionary* sharedMappings = [AKATVMultiplexedDataSource sharedTableViewDelegateSelectorMapping];

    for (NSString* selectorValue in sharedMappings.keyEnumerator)
    {
        SEL selector = NSSelectorFromString(selectorValue);

        if ([delegate respondsToSelector:selector])
        {
            self.tableViewDelegateSelectorMapping[selectorValue] = sharedMappings[selectorValue];
        }
    }
}

- (void)addTableViewDelegateSelector:(SEL)selector
{
    NSString* selectorValue = NSStringFromSelector(selector);
    NSDictionary* sharedMappings = [AKATVMultiplexedDataSource sharedTableViewDelegateSelectorMapping];
    id mapping = sharedMappings[selectorValue];

    if (mapping != nil)
    {
        self.tableViewDelegateSelectorMapping[selectorValue] = mapping;
    }
    else
    {
        // TODO: error handling
        NSAssert(NO, @"Selector %@ is not a UITableViewDelegate method or not known to %@",
                 NSStringFromSelector(selector),
                 NSStringFromClass(self.class));
    }
}

- (void)removeTableViewDelegateSelector:(SEL)selector
{
    NSString* selectorValue = NSStringFromSelector(selector);

    [self.tableViewDelegateSelectorMapping removeObjectForKey:selectorValue];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSString* selectorValue = NSStringFromSelector(aSelector);
    BOOL result = self.tableViewDelegateSelectorMapping[selectorValue] != nil;

    if (!result)
    {
        result = [super respondsToSelector:aSelector];
    }

    return result;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* result = [super methodSignatureForSelector:selector];

    if (result == NULL)
    {
        // We only look for delegate methods, since we only forward those and rely on
        // default implementations in all other cases.
        struct objc_method_description theDescription =
            protocol_getMethodDescription(@protocol(UITableViewDelegate),
                                          selector,
                                          NO, YES);

        if (theDescription.name != NULL || theDescription.types != NULL)
        {
            result = [NSMethodSignature signatureWithObjCTypes:theDescription.types];
        }
    }

    return result;
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    NSString* selectorValue = NSStringFromSelector(invocation.selector);

    NSObject<UITableViewDelegate>* delegate = [self.tableViewDelegateOverrides objectForKey:selectorValue];

    if (delegate != nil)
    {
        [invocation invokeWithTarget:delegate];

        return;
    }

    NSNumber* mapping = self.tableViewDelegateSelectorMapping[selectorValue];

    if (mapping != nil)
    {
        BOOL result = NO;
        BOOL resolveCoordinates = YES;
        BOOL useTableViewProxy = YES;

        AKATVMDSDelegateMappingType type = (AKATVMDSDelegateMappingType)mapping.integerValue;
        switch (type)
        {
        case resolveSectionAt1:
            result = [self forwardDelegateInvocation:invocation
                       withTableViewParameterAtIndex:0
                             sectionParameterAtIndex:1
                                  resolveCoordinates:resolveCoordinates
                                   useTableViewProxy:useTableViewProxy
                                    resolvedDelegate:nil];
            break;

        case resolveSectionAt2:
            result = [self forwardDelegateInvocation:invocation
                       withTableViewParameterAtIndex:0
                             sectionParameterAtIndex:2
                                  resolveCoordinates:resolveCoordinates
                                   useTableViewProxy:useTableViewProxy
                                    resolvedDelegate:nil];
            break;

        case resolveIndexPathAt1:
            result = [self forwardDelegateInvocation:invocation
                       withTableViewParameterAtIndex:0
                           indexPathParameterAtIndex:1
                                  resolveCoordinates:resolveCoordinates
                                   useTableViewProxy:useTableViewProxy
                                    resolvedDelegate:nil];
            break;

        case resolveIndexPathAt1AndResultIndexPath:
            result = [self forwardDelegateInvocation:invocation
                       withTableViewParameterAtIndex:0
                           indexPathParameterAtIndex:1
                                     indexPathResult:resolveCoordinates
                                  resolveCoordinates:resolveCoordinates
                                   useTableViewProxy:useTableViewProxy
                                    resolvedDelegate:nil];
            break;

        case resolveIndexPathAt2:
            result = [self forwardDelegateInvocation:invocation
                       withTableViewParameterAtIndex:0
                           indexPathParameterAtIndex:2
                                  resolveCoordinates:resolveCoordinates
                                   useTableViewProxy:useTableViewProxy
                                    resolvedDelegate:nil];
            break;

        case resolveIndexPathAt1And2:
            result = NO;
            break;

        case resolveScrollViewDelegate:
            result = [self forwardDelegateInvocation:invocation
                      withScrollViewParameterAtIndex:0
                                    resolvedDelegate:nil];
            break;
        }
        // TODO: check if we should call [super forwardInvocation:invocation]; if result is NO
        (void)result;
    }
    else
    {
        [super forwardInvocation:invocation];
    }
}

@end
