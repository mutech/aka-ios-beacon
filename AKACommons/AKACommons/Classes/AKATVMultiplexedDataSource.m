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

typedef enum {
    resolveSectionAt1,
    resolveSectionAt2,
    resolveIndexPathAt1,
    resolveIndexPathAt1AndResultIndexPath,
    resolveIndexPathAt2,
    resolveIndexPathAt1And2,
    resolveScrollViewDelegate
} AKATVMDSDelegateMappingType;

@interface AKATVMultiplexedDataSource()

@property(nonatomic, readonly) NSMutableDictionary* dataSourcesByKey;
@property(nonatomic, readonly) NSMutableDictionary* tableViewDelegateSelectorMapping;

@property(nonatomic) NSMutableArray* sectionSegments;
@property(nonatomic, readonly) NSUInteger numberOfSections;
@property(nonatomic, readonly) AKATVUpdateBatch* updateBatch;

@property(nonatomic, weak) NSString* defaultDataSourceKey;

@end

@implementation AKATVMultiplexedDataSource

#pragma mark - Configuration

#pragma mark - Initialization

+ (instancetype)proxyDataSourceAndDelegateForKey:(NSString*)dataSourceKey
                                     inTableView:(UITableView*)tableView
{
    AKATVMultiplexedDataSource* result = [[self alloc] initWithTableView:tableView];
    if (tableView.dataSource != nil)
    {
        NSString* key = dataSourceKey;
        id<UITableViewDataSource> dataSource = [result addDataSource:tableView.dataSource
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
    result.defaultDataSourceKey = dataSourceKey;
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

- (void)beginUpdates
{
    [self.updateBatch beginUpdatesForTableView:self.tableView];
}

- (void)endUpdates
{
    [self.updateBatch endUpdatesForTableView:self.tableView];
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
        NSInteger correctedSectionIndex = [self.updateBatch insertionIndexForSection:(NSInteger)sectionIndex
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
{
    [self moveRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]
                 toIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:sectionIndex]];
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
                for (NSUInteger i=0; i < numberOfRows; ++i)
                {
                    NSIndexPath* correctedIndexPath = [self.updateBatch insertionIndexPathForRow:indexPath.row+i
                                                                                       inSection:indexPath.section
                                                                       forBatchUpdateInTableView:tableView
                                                                           recordAsInsertedIndex:YES];
                    [indexPaths addObject:correctedIndexPath];
                }
                // Enable to debug insertion/deletion correction problems
                //AKALogDebug(@"Inserted %lu rows starting from %@, announcing translated insertions to table view: %@", (unsigned long)numberOfRows, indexPath, indexPaths);
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
            for (NSUInteger i=0; i < rowsRemoved; ++i)
            {
                NSIndexPath* correctedIndexPath = [self.updateBatch deletionIndexPathForRow:indexPath.row + i
                                                                                  inSection:indexPath.section
                                                                  forBatchUpdateInTableView:tableView
                                                                       recordAsDeletedIndex:YES];
                [indexPaths addObject:correctedIndexPath];
            }
            // Enable to debug insertion/deletion correction problems
            //AKALogDebug(@"Removed %lu rows starting from %@, announcing translated removals to table view: %@", (unsigned long)rowsRemoved, indexPath, indexPaths);
            [tableView deleteRowsAtIndexPaths:indexPaths
                             withRowAnimation:rowAnimation];
        }
    }

    return rowsRemoved;
}

#pragma mark - Resolution

- (BOOL)resolveIndexPath:(out NSIndexPath* __strong* __nullable)indexPathStorage
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
                result = *stop = *stopSection = YES;
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

- (BOOL)resolveSectionSpecification:(out AKATVSection*__autoreleasing* __nullable)sectionStorage
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

- (BOOL)forwardDelegateInvocation:(NSInvocation *)invocation
    withTableViewParameterAtIndex:(NSInteger)tvParameterIndex
          sectionParameterAtIndex:(NSInteger)parameterIndex
               resolveCoordinates:(BOOL)resolveCoordinates
                useTableViewProxy:(BOOL)useTableViewProxy
                 resolvedDelegate:(id <UITableViewDelegate> *)delegateStorage
{
    id<UITableViewDelegate> delegate = nil;
    AKATVDataSourceSpecification* dataSource = nil;
    NSInteger section = NSNotFound;
    NSInteger sourceSection = NSNotFound;
    [invocation getArgument:&section atIndex:2+parameterIndex];
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
                    [invocation getArgument:&tableView atIndex:2+tvParameterIndex];

                    UITableView* tableViewProxy = [dataSource proxyForTableView:tableView];
                    [invocation setArgument:&tableViewProxy atIndex:2+tvParameterIndex];
                }
                [invocation setArgument:&sourceSection atIndex:2+parameterIndex];
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

- (BOOL)forwardDelegateInvocation:(NSInvocation *)invocation
    withTableViewParameterAtIndex:(NSInteger)tvParameterIndex
        indexPathParameterAtIndex:(NSInteger)parameterIndex
               resolveCoordinates:(BOOL)resolveCoordinates
                useTableViewProxy:(BOOL)useTableViewProxy
                 resolvedDelegate:(id <UITableViewDelegate> *)delegateStorage
{
    return [self forwardDelegateInvocation:invocation
             withTableViewParameterAtIndex:tvParameterIndex
                 indexPathParameterAtIndex:parameterIndex
                           indexPathResult:NO
                        resolveCoordinates:resolveCoordinates
                         useTableViewProxy:useTableViewProxy
                          resolvedDelegate:delegateStorage];
}

- (BOOL)forwardDelegateInvocation:(NSInvocation *)invocation
    withTableViewParameterAtIndex:(NSInteger)tvParameterIndex
        indexPathParameterAtIndex:(NSInteger)parameterIndex
                  indexPathResult:(BOOL)resolveIndexPathResult
               resolveCoordinates:(BOOL)resolveCoordinates
                useTableViewProxy:(BOOL)useTableViewProxy
                 resolvedDelegate:(id <UITableViewDelegate> *)delegateStorage
{
    id<UITableViewDelegate> delegate = nil;
    AKATVDataSourceSpecification* dataSource = nil;

    NSIndexPath* __unsafe_unretained indexPath;
    [invocation getArgument:&indexPath atIndex:2+parameterIndex];

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
                    [invocation getArgument:&tableView atIndex:2+tvParameterIndex];

                    UITableView* tableViewProxy = [dataSource proxyForTableView:tableView];
                    [invocation setArgument:&tableViewProxy atIndex:2+tvParameterIndex];
                }
                [invocation setArgument:&sourceIndexPath atIndex:2+parameterIndex];
            }

            AKALogDebug(@"[%@.delegate %@] indexPath=[%ld-%ld] ([%ld-%ld])",
                        dataSource.key,
                        NSStringFromSelector(invocation.selector),
                        indexPath.section, indexPath.row,
                        sourceIndexPath.section, sourceIndexPath.row);
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

- (BOOL)forwardDelegateInvocation:(NSInvocation *)invocation
   withScrollViewParameterAtIndex:(NSInteger)tvParameterIndex
                 resolvedDelegate:(id <UITableViewDelegate> *)delegateStorage
{
    AKATVDataSourceSpecification* dataSource = (self.defaultDataSourceKey.length > 0
                                                ? self.dataSourcesByKey[self.defaultDataSourceKey]
                                                : nil);
    BOOL result = dataSource.delegate != nil;
    if (result)
    {
        if (delegateStorage != nil)
        {
            *delegateStorage = dataSource.delegate;
        }
        result = [dataSource.delegate respondsToSelector:invocation.selector];
        if (result)
        {
            [invocation invokeWithTarget:dataSource.delegate];
        }
    }

    return result;
}


+ (NSDictionary*)sharedTableViewDelegateSelectorMapping
{
    static NSDictionary* sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{

        sharedInstance =
            @{ [NSValue valueWithPointer:@selector(tableView:heightForHeaderInSection:)]: @(resolveSectionAt1),
               [NSValue valueWithPointer:@selector(tableView:heightForFooterInSection:)]: @(resolveSectionAt1),
               [NSValue valueWithPointer:@selector(tableView:viewForHeaderInSection:)]: @(resolveSectionAt1),
               [NSValue valueWithPointer:@selector(tableView:viewForFooterInSection:)]: @(resolveSectionAt1),
               [NSValue valueWithPointer:@selector(tableView:estimatedHeightForHeaderInSection:)]: @(resolveSectionAt1),
               [NSValue valueWithPointer:@selector(tableView:estimatedHeightForFooterInSection:)]: @(resolveSectionAt1),

               [NSValue valueWithPointer:@selector(tableView:willDisplayHeaderView:forSection:)]: @(resolveSectionAt2),
               [NSValue valueWithPointer:@selector(tableView:willDisplayFooterView:forSection:)]: @(resolveSectionAt2),
               [NSValue valueWithPointer:@selector(tableView:didEndDisplayingHeaderView:forSection:)]: @(resolveSectionAt2),
               [NSValue valueWithPointer:@selector(tableView:didEndDisplayingFooterView:forSection:)]: @(resolveSectionAt2),

               [NSValue valueWithPointer:@selector(tableView:heightForRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:estimatedHeightForRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:accessoryTypeForRowWithIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:shouldHighlightRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:didHighlightRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:didUnhighlightRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:didSelectRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:didDeselectRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:editingStyleForRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:editActionsForRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:willBeginEditingRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:didEndEditingRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:indentationLevelForRowAtIndexPath:)]: @(resolveIndexPathAt1),
               [NSValue valueWithPointer:@selector(tableView:shouldShowMenuForRowAtIndexPath:)]: @(resolveIndexPathAt1),

               [NSValue valueWithPointer:@selector(tableView:willSelectRowAtIndexPath:)]: @(resolveIndexPathAt1AndResultIndexPath),
               [NSValue valueWithPointer:@selector(tableView:willDeselectRowAtIndexPath:)]: @(resolveIndexPathAt1AndResultIndexPath),

               [NSValue valueWithPointer:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]: @(resolveIndexPathAt2),
               [NSValue valueWithPointer:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]: @(resolveIndexPathAt2),
               [NSValue valueWithPointer:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)]: @(resolveIndexPathAt2),
               [NSValue valueWithPointer:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]: @(resolveIndexPathAt2),
               
               [NSValue valueWithPointer:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]: @(resolveIndexPathAt1And2),

               [NSValue valueWithPointer:@selector(scrollViewDidScroll:)]:@(resolveScrollViewDelegate),
               [NSValue valueWithPointer:@selector(scrollViewWillBeginDragging:)]:@(resolveScrollViewDelegate),
               [NSValue valueWithPointer:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]:@(resolveScrollViewDelegate),
               [NSValue valueWithPointer:@selector(scrollViewDidEndDragging:willDecelerate:)]:@(resolveScrollViewDelegate),
               [NSValue valueWithPointer:@selector(scrollViewShouldScrollToTop:)]:@(resolveScrollViewDelegate),
               [NSValue valueWithPointer:@selector(scrollViewDidScrollToTop:)]:@(resolveScrollViewDelegate),
               [NSValue valueWithPointer:@selector(scrollViewWillBeginDecelerating:)]:@(resolveScrollViewDelegate),
               [NSValue valueWithPointer:@selector(scrollViewDidEndDecelerating:)]:@(resolveScrollViewDelegate),

               [NSValue valueWithPointer:@selector(viewForZoomingInScrollView:)]:@(resolveScrollViewDelegate),
               [NSValue valueWithPointer:@selector(scrollViewWillBeginZooming:withView:)]:@(resolveScrollViewDelegate),
               [NSValue valueWithPointer:@selector(scrollViewDidEndZooming:withView:atScale:)]:@(resolveScrollViewDelegate),
               [NSValue valueWithPointer:@selector(scrollViewDidZoom:)]:@(resolveScrollViewDelegate),

               [NSValue valueWithPointer:@selector(scrollViewDidEndScrollingAnimation:)]:@(resolveScrollViewDelegate),
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
    BOOL fallback = NO;
    if (!result)
    {
        fallback = YES;
        result = [super respondsToSelector:aSelector];
    }
    AKALogDebug(@"%@: respondsToSelector:%@ %@ (fallback: %@)", self.description, NSStringFromSelector(aSelector), result?@"YES":@"NO", fallback?@"YES":@"NO");
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

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSValue* selectorValue = [NSValue valueWithPointer:invocation.selector];
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
    }
    else
    {
        [super forwardInvocation:invocation];
    }
}

@end
