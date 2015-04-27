//
//  AKAMultiplexedTableViewDataSourceBase.m
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
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
#pragma mark -

@interface AKATVMultiplexedDataSource()

@property(nonatomic, readonly) NSMutableDictionary* dataSourcesByKey;
@property(nonatomic, readonly) NSMutableDictionary* tableViewDelegateSelectorMapping;

@property(nonatomic) NSMutableArray* sectionSegments;
@property(nonatomic, readonly) NSUInteger numberOfSections;
@property(nonatomic, readonly) AKATVUpdateBatch* updateBatch;

@end

@implementation AKATVMultiplexedDataSource

#pragma mark - Initialization

+ (instancetype)proxyDataSourceAndDelegateForKey:(NSString*)dataSourceKey
                                     inTableView:(UITableView*)tableView
{
    AKATVMultiplexedDataSource* result = [[self alloc] init];
    if (tableView.dataSource != nil)
    {
        NSString* key = dataSourceKey;
        id<UITableViewDataSource> dataSource = [result addDataSource:tableView.dataSource
                                                        withDelegate:tableView.delegate
                                                              forKey:key].dataSource;
        [result insertSectionsFromDataSource:key
                          sourceSectionIndex:0
                                       count:(NSUInteger)[dataSource numberOfSectionsInTableView:tableView]
                              atSectionIndex:0
                           useRowsFromSource:YES
                                   tableView:tableView
                                      update:NO
                            withRowAnimation:UITableViewRowAnimationNone];
        tableView.dataSource = result;
        tableView.delegate = result;
    }
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
    [result insertSectionsFromDataSource:key
                      sourceSectionIndex:0
                                   count:(NSUInteger)[dataSource numberOfSectionsInTableView:tableView]
                          atSectionIndex:(NSUInteger)[result numberOfSectionsInTableView:tableView]
                       useRowsFromSource:YES
                               tableView:tableView
                                  update:NO
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

- (AKATVDataSourceSpecification *)dataSourceForKey:(NSString *)key
{
    return self.dataSourcesByKey[key];
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
{
    [self insertSectionsFromDataSource:dataSourceKey
                    sourceSectionIndex:sourceSectionIndex
                                 count:numberOfSections
                        atSectionIndex:targetSectionIndex
                     useRowsFromSource:useRowsFromSource
                             tableView:tableView
                                update:YES
                      withRowAnimation:UITableViewRowAnimationAutomatic];
}

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
{
    [self           remove:numberOfSections
           sectionsAtIndex:sectionIndex
                 tableView:tableView
                    update:YES
          withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (void)moveRowAtIndex:(NSInteger)rowIndex
             inSection:(NSInteger)sectionIndex
            toRowIndex:(NSInteger)targetIndex
             tableView:(UITableView*)tableView
{
    [self moveRowAtIndex:rowIndex
               inSection:sectionIndex
              toRowIndex:targetIndex
               tableView:tableView
                  update:YES];
}

- (void)moveRowAtIndex:(NSInteger)rowIndex
             inSection:(NSInteger)sectionIndex
            toRowIndex:(NSInteger)targetIndex
             tableView:(UITableView *)tableView
                update:(BOOL)updateTableView
{
    [self moveRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]
                 toIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:sectionIndex]
                   tableView:tableView
                      update:updateTableView];
}

- (void)moveRowAtIndexPath:(NSIndexPath*)indexPath
               toIndexPath:(NSIndexPath*)targetIndexPath
                 tableView:(UITableView *)tableView
{
    [self moveRowAtIndexPath:indexPath
                 toIndexPath:targetIndexPath
                   tableView:tableView
                      update:YES];
}

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
{
    [self insertRowsFromDataSource:dataSourceKey
                   sourceIndexPath:sourceIndexPath
                             count:numberOfRows
                       atIndexPath:indexPath
                         tableView:tableView
                            update:(tableView != nil)
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

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

    AKATVDataSourceSpecification* dataSource = [self dataSourceForKey:dataSourceKey];
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

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
       rowsFromIndexPath:(NSIndexPath*)indexPath
               tableView:(UITableView*)tableView
{
    return [self removeUpTo:numberOfRows
          rowsFromIndexPath:indexPath
                  tableView:tableView
                     update:YES
           withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Resolution

- (BOOL)resolveIndexPath:(out NSIndexPath*__autoreleasing* __nullable)indexPathStorage
      forSourceIndexPath:(NSIndexPath* __nonnull)sourceIndexPath
            inDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource
{
    __block BOOL result = NO;

    NSInteger sourceSection = sourceIndexPath.section;
    NSInteger sourceRow = sourceIndexPath.row;

    [self.sectionSegments enumerateObjectsUsingBlock:^(id obj, NSUInteger sectionIndex, BOOL *stopSection) {
        (void)stopSection;
        AKATVSection* section = obj;
        __block NSUInteger offset = 0;
        [section enumerateRowSegmentsUsingBlock:^(AKATVRowSegment *rowSegment,
                                                  NSUInteger rowSegmentIndex,
                                                  BOOL *stop) {
            (void)rowSegmentIndex;
            NSIndexPath* segmentIndexPath = rowSegment.indexPath;
            NSInteger segmentSection = segmentIndexPath.section;
            NSInteger segmentRow = segmentIndexPath.row;
            NSUInteger segmentRowCount = rowSegment.numberOfRows;

            if (dataSource == rowSegment.dataSource &&
                sourceSection == segmentSection &&
                sourceRow >= segmentRow &&
                sourceRow < segmentRow + (NSInteger)segmentRowCount)
            {
                result = *stop = YES;
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

- (BOOL)resolveSection:(out NSInteger* __nullable)sectionStorage
      forSourceSection:(NSInteger)sourceSection
          inDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource
{
    __block BOOL result = NO;

    [self.sectionSegments enumerateObjectsUsingBlock:^(id obj, NSUInteger sectionIndex, BOOL *stop) {
        AKATVSection* section = obj;
        if (section.dataSource == dataSource &&
            section.sectionIndex == sourceSection)
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

- (BOOL)resolveAKADataSource:(out AKATVDataSourceSpecification *__autoreleasing* __nullable)dataSourceStorage
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


- (BOOL)resolveDataSource:(out __autoreleasing id<UITableViewDataSource> *)dataSourceStorage
                 delegate:(out __autoreleasing id<UITableViewDelegate>*)delegateStorage
          sourceIndexPath:(out NSIndexPath *__autoreleasing *)indexPathStorage
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

- (BOOL)resolveAKADataSource:(out AKATVDataSourceSpecification *__autoreleasing* __nullable)dataSourceStorage
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    (void)tableView;
    return (NSInteger)self.numberOfSections;
}

- (UITableViewCell*)            tableView:(UITableView *)tableView
                    cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* result = nil;
    id<UITableViewDataSource> dataSource = nil;
    NSIndexPath* resolvedIndexPath = indexPath;
    if ([self resolveDataSource:&dataSource delegate:nil sourceIndexPath:&resolvedIndexPath forIndexPath:indexPath])
    {
        result = [dataSource tableView:tableView
                 cellForRowAtIndexPath:resolvedIndexPath];
    }
    return result;
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

- (BOOL)                        tableView:(UITableView *)tableView
                    canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL result = NO;
    id<UITableViewDataSource> dataSource = nil;
    NSIndexPath* resolvedIndexPath = indexPath;
    if ([self resolveDataSource:&dataSource delegate:nil sourceIndexPath:&resolvedIndexPath forIndexPath:indexPath])
    {
        if ([dataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
            result = [dataSource tableView:tableView
                     canEditRowAtIndexPath:resolvedIndexPath];
    }
    return result;
}

- (void)                        tableView:(UITableView *)tableView
                       commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                        forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<UITableViewDataSource> dataSource = nil;
    NSIndexPath* resolvedIndexPath = indexPath;
    if ([self resolveDataSource:&dataSource delegate:nil sourceIndexPath:&resolvedIndexPath forIndexPath:indexPath])
    {
        if ([dataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
            [dataSource tableView:tableView
               commitEditingStyle:editingStyle
                forRowAtIndexPath:resolvedIndexPath];
    }
}

- (BOOL)                        tableView:(UITableView *)tableView
                    canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL result = NO;
    id<UITableViewDataSource> dataSource = nil;
    NSIndexPath* resolvedIndexPath = indexPath;
    if ([self resolveDataSource:&dataSource delegate:nil sourceIndexPath:&resolvedIndexPath forIndexPath:indexPath])
    {
        if ([dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)])
            result = [dataSource tableView:tableView
                     canMoveRowAtIndexPath:resolvedIndexPath];
    }
    return result;
}

- (NSString *)                  tableView:(UITableView *)tableView
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

- (NSString *)                  tableView:(UITableView *)tableView
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
- (void)                        tableView:(UITableView *)tableView
                       moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                              toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // Not implemented becuase I have no idea yet how to handle cross DS row movements.
    // This should probably be implemented in a subclass of the multiplexed data source
    // TODO: implement this if at all possible.
    (void)tableView;
    (void)sourceIndexPath;
    (void)destinationIndexPath;
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSInteger)                   tableView:(UITableView *)tableView
              sectionForSectionIndexTitle:(NSString *)title
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

- (id<UITableViewDelegate>)resolveDelegateForInvocation:(NSInvocation*)invocation
                          withTableViewParameterAtIndex:(NSInteger)tvParameterIndex
                                sectionParameterAtIndex:(NSInteger)parameterIndex
                                     resolveCoordinates:(BOOL)resolveCoordinates
                                      useTableViewProxy:(BOOL)useTableViewProxy
{
    id<UITableViewDelegate> result = nil;
    AKATVDataSourceSpecification* dataSource = nil;
    NSInteger section = NSNotFound;
    [invocation getArgument:&section atIndex:2+parameterIndex];
    if ([self resolveAKADataSource:&dataSource sourceSectionIndex:&section forSectionIndex:section])
    {
        result = dataSource.delegate;
        if (resolveCoordinates)
        {
            if (useTableViewProxy)
            {
                [invocation retainArguments];

                UITableView* __unsafe_unretained tableView = nil;
                [invocation getArgument:&tableView atIndex:2+tvParameterIndex];

                UITableView* tableViewProxy = [dataSource proxyForTableView:tableView];
                [invocation setArgument:&tableViewProxy atIndex:2+tvParameterIndex];
            }
            [invocation setArgument:&section atIndex:2+parameterIndex];
        }
    }
    return result;
}

- (id<UITableViewDelegate>)resolveDelegateForInvocation:(NSInvocation*)invocation
                          withTableViewParameterAtIndex:(NSInteger)tvParameterIndex
                              indexPathParameterAtIndex:(NSInteger)parameterIndex
                                     resolveCoordinates:(BOOL)resolveCoordinates
                                      useTableViewProxy:(BOOL)useTableViewProxy
{
    id<UITableViewDelegate> result = nil;
    AKATVDataSourceSpecification* dataSource = nil;

    NSIndexPath* __unsafe_unretained indexPath;
    [invocation getArgument:&indexPath atIndex:2+parameterIndex];

    NSIndexPath* sourceIndexPath = nil;
    if ([self resolveAKADataSource:&dataSource sourceIndexPath:&sourceIndexPath forIndexPath:indexPath])
    {
        result = dataSource.delegate;
        if (resolveCoordinates)
        {
            if (useTableViewProxy)
            {
                [invocation retainArguments];

                UITableView* __unsafe_unretained tableView = nil;
                [invocation getArgument:&tableView atIndex:2+tvParameterIndex];

                UITableView* tableViewProxy = [dataSource proxyForTableView:tableView];
                [invocation setArgument:&tableViewProxy atIndex:2+tvParameterIndex];
            }
            [invocation setArgument:&sourceIndexPath atIndex:2+parameterIndex];
        }
    }
    return result;
}


+ (NSDictionary*)sharedTableViewDelegateSelectorMapping
{
    static NSDictionary* sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        id<UITableViewDelegate> (^resolveSectionAt1)(AKATVMultiplexedDataSource*, NSInvocation*, BOOL) =
        ^id<UITableViewDelegate>(AKATVMultiplexedDataSource* mds, NSInvocation* inv, BOOL useTableViewProxy)
        {
            return [mds resolveDelegateForInvocation:inv
                       withTableViewParameterAtIndex:0
                             sectionParameterAtIndex:1
                                  resolveCoordinates:YES
                                   useTableViewProxy:useTableViewProxy];
        };
        id<UITableViewDelegate> (^resolveSectionAt2)(AKATVMultiplexedDataSource*, NSInvocation*, BOOL) =
        ^id<UITableViewDelegate>(AKATVMultiplexedDataSource* mds, NSInvocation* inv, BOOL useTableViewProxy)
        {
            return [mds resolveDelegateForInvocation:inv
                       withTableViewParameterAtIndex:0
                             sectionParameterAtIndex:2
                                  resolveCoordinates:YES
                                   useTableViewProxy:useTableViewProxy];
        };

        id<UITableViewDelegate> (^resolveIndexPathAt1)(AKATVMultiplexedDataSource*, NSInvocation*, BOOL) =
        ^id<UITableViewDelegate>(AKATVMultiplexedDataSource* mds, NSInvocation* inv, BOOL useTableViewProxy)
        {
            return [mds resolveDelegateForInvocation:inv
                       withTableViewParameterAtIndex:0
                           indexPathParameterAtIndex:1
                                  resolveCoordinates:YES
                                   useTableViewProxy:useTableViewProxy];
        };
        id<UITableViewDelegate> (^resolveIndexPathAt2)(AKATVMultiplexedDataSource*, NSInvocation*, BOOL) =
        ^id<UITableViewDelegate>(AKATVMultiplexedDataSource* mds, NSInvocation* inv, BOOL useTableViewProxy)
        {
            return [mds resolveDelegateForInvocation:inv
                       withTableViewParameterAtIndex:0
                           indexPathParameterAtIndex:2
                                  resolveCoordinates:YES
                                   useTableViewProxy:useTableViewProxy];
        };
        id<UITableViewDelegate> (^resolveIndexPathAt1And2)(AKATVMultiplexedDataSource* mds,
                                                    NSInvocation* inv) = ^id<UITableViewDelegate>(AKATVMultiplexedDataSource* mds, NSInvocation* inv)
        {
            (void)mds; (void)inv;
            return nil;
        };

        sharedInstance =
            @{ [NSValue valueWithPointer:@selector(tableView:heightForHeaderInSection:)]: resolveSectionAt1,
               [NSValue valueWithPointer:@selector(tableView:heightForFooterInSection:)]: resolveSectionAt1,
               [NSValue valueWithPointer:@selector(tableView:viewForHeaderInSection:)]: resolveSectionAt1,
               [NSValue valueWithPointer:@selector(tableView:viewForFooterInSection:)]: resolveSectionAt1,
               [NSValue valueWithPointer:@selector(tableView:estimatedHeightForHeaderInSection:)]: resolveSectionAt1,
               [NSValue valueWithPointer:@selector(tableView:estimatedHeightForFooterInSection:)]: resolveSectionAt1,

               [NSValue valueWithPointer:@selector(tableView:willDisplayHeaderView:forSection:)]: resolveSectionAt2,
               [NSValue valueWithPointer:@selector(tableView:willDisplayFooterView:forSection:)]: resolveSectionAt2,
               [NSValue valueWithPointer:@selector(tableView:didEndDisplayingHeaderView:forSection:)]: resolveSectionAt2,
               [NSValue valueWithPointer:@selector(tableView:didEndDisplayingFooterView:forSection:)]: resolveSectionAt2,

               [NSValue valueWithPointer:@selector(tableView:heightForRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:estimatedHeightForRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:accessoryTypeForRowWithIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:shouldHighlightRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:didHighlightRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:didUnhighlightRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:willSelectRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:willDeselectRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:didSelectRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:didDeselectRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:editingStyleForRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:editActionsForRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:willBeginEditingRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:didEndEditingRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:indentationLevelForRowAtIndexPath:)]: resolveIndexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:shouldShowMenuForRowAtIndexPath:)]: resolveIndexPathAt1,

               [NSValue valueWithPointer:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]: resolveIndexPathAt2,
               [NSValue valueWithPointer:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]: resolveIndexPathAt2,
               [NSValue valueWithPointer:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)]: resolveIndexPathAt2,
               [NSValue valueWithPointer:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]: resolveIndexPathAt2,
               
               [NSValue valueWithPointer:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]: resolveIndexPathAt1And2
            };
    });
    return sharedInstance;
}

- (void)addTableViewDelegateSelectorsRespondedBy:(id<UITableViewDelegate>)delegate
{
    NSDictionary* sharedMappings = [AKATVMultiplexedDataSource sharedTableViewDelegateSelectorMapping];
    for (NSValue* selectorValue in sharedMappings.keyEnumerator)
    {
        SEL selector = selectorValue.pointerValue;
        if ([delegate respondsToSelector:selector])
        {
            self.tableViewDelegateSelectorMapping[selectorValue] = sharedMappings[selectorValue];
        }
    }
}

- (void)addTableViewDelegateSelector:(SEL)selector
{
    NSValue* selectorValue = [NSValue valueWithPointer:selector];
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
    NSValue* selectorValue = [NSValue valueWithPointer:selector];
    [self.tableViewDelegateSelectorMapping removeObjectForKey:selectorValue];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSValue* selectorValue = [NSValue valueWithPointer:aSelector];
    BOOL result = self.tableViewDelegateSelectorMapping[selectorValue] != nil;
    if (!result)
    {
        result = [super respondsToSelector:aSelector];
    }
    return result;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *result = [super methodSignatureForSelector:selector];
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

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSValue* selectorValue = [NSValue valueWithPointer:anInvocation.selector];
    id<UITableViewDelegate>(^mapping)(AKATVMultiplexedDataSource* mds,
                                      NSInvocation *invocation,
                                      BOOL useTableViewProxy) =
        self.tableViewDelegateSelectorMapping[selectorValue];
    if (mapping)
    {
        // mapping() maps row/section coordinates between multiplexed and source data sources,
        // resolves the source delegate and optionally replaces the invocation's table view
        // parameter with a proxy that also performs row/section coordinate mapping (so that
        // if the delegate calls table view methods with coordinate parameters, it will not
        // fail due to the different structure of the multiplexed table view.
        id<UITableViewDelegate> delegate = mapping(self, anInvocation, YES);
        if ([delegate respondsToSelector:anInvocation.selector])
        {
            [anInvocation invokeWithTarget:delegate];
        }
    }
    else
    {
        [super forwardInvocation:anInvocation];
    }
}

@end
