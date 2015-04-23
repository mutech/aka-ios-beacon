//
//  AKAMultiplexedTableViewDataSourceBase.m
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAErrors.h"

#import "AKAMultiplexedTableViewDataSourceBase.h"
#import "AKATVDataSource.h"
#import "AKALog.h"

#import <objc/runtime.h>

#pragma mark - AKAMultiplexedTableViewDataSourceBase
#pragma mark -

@interface AKAMultiplexedTableViewDataSourceBase()

@property(nonatomic, readonly) NSMutableDictionary* dataSourcesByKey;
@property(nonatomic, readonly) NSMutableDictionary* tableViewDelegateSelectorMapping;

@end

@implementation AKAMultiplexedTableViewDataSourceBase

#pragma mark - Initialization

+ (instancetype)proxyDataSourceAndDelegateForKey:(NSString*)dataSourceKey
                                     inTableView:(UITableView*)tableView
{
    AKAMultiplexedTableViewDataSourceBase* result = [[self alloc] init];
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
    AKAMultiplexedTableViewDataSourceBase* result =
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
    }
    return self;
}

#pragma mark - Configuration

+ (NSString*)defaultDataSourceKey
{
    return @"default";
}

#pragma mark - Managing Data Sources and associated Delegates

- (AKATVDataSource*)addDataSource:(id<UITableViewDataSource>)dataSource
                     withDelegate:(id<UITableViewDelegate>)delegate
                           forKey:(NSString*)key
{
    NSParameterAssert(self.dataSourcesByKey[key] == nil);
    AKATVDataSource* result = [AKATVDataSource dataSource:dataSource
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

- (AKATVDataSource*)addDataSourceAndDelegate:(id<UITableViewDataSource, UITableViewDelegate>)dataSource
                                      forKey:(NSString*)key
{
    return [self addDataSource:dataSource
                  withDelegate:dataSource
                        forKey:key];
}

- (AKATVDataSource *)dataSourceForKey:(NSString *)key
{
    return self.dataSourcesByKey[key];
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

- (void)insertSectionsFromDataSource:(NSString *)dataSourceKey
                  sourceSectionIndex:(NSUInteger)sourceSectionIndex
                               count:(NSUInteger)numberOfSections
                      atSectionIndex:(NSUInteger)targetSectionIndex
                   useRowsFromSource:(BOOL)useRowsFromSource
                           tableView:(UITableView *)tableView
                              update:(BOOL)updateTableView
                    withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    (void)dataSourceKey;
    (void)sourceSectionIndex;
    (void)numberOfSections;
    (void)targetSectionIndex;
    (void)useRowsFromSource;
    (void)tableView;
    (void)updateTableView;
    (void)rowAnimation;
    AKAErrorAbstractMethodImplementationMissing();
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
    (void)numberOfSections;
    (void)sectionIndex;
    (void)tableView;
    (void)updateTableView;
    (void)rowAnimation;
    AKAErrorAbstractMethodImplementationMissing();
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
    (void)indexPath;
    (void)targetIndexPath;
    (void)tableView;
    (void)updateTableView;
    AKAErrorAbstractMethodImplementationMissing();
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
    (void)dataSourceKey;
    (void)sourceIndexPath;
    (void)numberOfRows;
    (void)indexPath;
    (void)tableView;
    (void)updateTableView;
    (void)rowAnimation;
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
       rowsFromIndexPath:(NSIndexPath*)indexPath
               tableView:(UITableView*)tableView
                  update:(BOOL)updateTableView
        withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    (void)numberOfRows;
    (void)indexPath;
    (void)tableView;
    (void)updateTableView;
    (void)rowAnimation;
    AKAErrorAbstractMethodImplementationMissing();
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
            inDataSource:(AKATVDataSource* __nonnull)dataSource
{
    (void)indexPathStorage;
    (void)sourceIndexPath;
    (void)dataSource;
    AKAErrorAbstractMethodImplementationMissing();
}

- (BOOL)resolveSection:(out NSInteger*)sectionStorage
      forSourceSection:(NSInteger)sourceSection
          inDataSource:(AKATVDataSource* __nonnull)dataSource
{
    (void)sectionStorage;
    (void)sourceSection;
    (void)dataSource;
    AKAErrorAbstractMethodImplementationMissing();
}


- (BOOL)resolveDataSource:(out __autoreleasing id<UITableViewDataSource> *)dataSourceStorage
                 delegate:(out __autoreleasing id<UITableViewDelegate>*)delegateStorage
       sourceSectionIndex:(out NSInteger *)sectionIndexStorage
          forSectionIndex:(NSInteger)sectionIndex
{
    AKATVDataSource* dataSource = nil;
    BOOL result = [self resolveAKADataSource:&dataSource
                          sourceSectionIndex:sectionIndexStorage
                             forSectionIndex:sectionIndex];
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

- (BOOL)resolveAKADataSource:(out __autoreleasing AKATVDataSource **)dataSourceStorage
          sourceSectionIndex:(out NSInteger *)sectionIndexStorage
             forSectionIndex:(NSInteger)sectionIndex
{
    (void)dataSourceStorage;
    (void)sectionIndexStorage;
    (void)sectionIndex;
    AKAErrorAbstractMethodImplementationMissing();
}

- (BOOL)resolveDataSource:(out __autoreleasing id<UITableViewDataSource> *)dataSourceStorage
                 delegate:(out __autoreleasing id<UITableViewDelegate>*)delegateStorage
          sourceIndexPath:(out NSIndexPath *__autoreleasing *)indexPathStorage
             forIndexPath:(NSIndexPath*)indexPath
{
    AKATVDataSource* dataSource = nil;
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

- (BOOL)resolveAKADataSource:(out __autoreleasing AKATVDataSource **)dataSourceStorage
             sourceIndexPath:(out NSIndexPath *__autoreleasing *)indexPathStorage
             forIndexPath:(NSIndexPath*)indexPath
{
    (void)dataSourceStorage;
    (void)indexPathStorage;
    (void)indexPath;
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - Data Source Protocol Implementation

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
    NSInteger result = 0;
    id<UITableViewDataSource> dataSource = nil;
    NSInteger resolvedSection = section;
    if ([self resolveDataSource:&dataSource delegate:nil sourceSectionIndex:&resolvedSection forSectionIndex:section])
    {
        result = [dataSource tableView:tableView numberOfRowsInSection:resolvedSection];
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
    id<UITableViewDataSource> dataSource = nil;
    NSInteger resolvedSection = section;
    if ([self resolveDataSource:&dataSource delegate:nil sourceSectionIndex:&resolvedSection forSectionIndex:section])
    {
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
    id<UITableViewDataSource> dataSource = nil;
    NSInteger resolvedSection = section;
    if ([self resolveDataSource:&dataSource delegate:nil sourceSectionIndex:&resolvedSection forSectionIndex:section])
    {
        if ([dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)])
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
    AKATVDataSource* dataSource = nil;
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
    AKATVDataSource* dataSource = nil;

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
        id<UITableViewDelegate> (^resolveSectionAt1)(AKAMultiplexedTableViewDataSourceBase*, NSInvocation*, BOOL) =
        ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation* inv, BOOL useTableViewProxy)
        {
            return [mds resolveDelegateForInvocation:inv
                       withTableViewParameterAtIndex:0
                             sectionParameterAtIndex:1
                                  resolveCoordinates:YES
                                   useTableViewProxy:useTableViewProxy];
        };
        id<UITableViewDelegate> (^resolveSectionAt2)(AKAMultiplexedTableViewDataSourceBase*, NSInvocation*, BOOL) =
        ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation* inv, BOOL useTableViewProxy)
        {
            return [mds resolveDelegateForInvocation:inv
                       withTableViewParameterAtIndex:0
                             sectionParameterAtIndex:2
                                  resolveCoordinates:YES
                                   useTableViewProxy:useTableViewProxy];
        };

        id<UITableViewDelegate> (^resolveIndexPathAt1)(AKAMultiplexedTableViewDataSourceBase*, NSInvocation*, BOOL) =
        ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation* inv, BOOL useTableViewProxy)
        {
            return [mds resolveDelegateForInvocation:inv
                       withTableViewParameterAtIndex:0
                           indexPathParameterAtIndex:1
                                  resolveCoordinates:YES
                                   useTableViewProxy:useTableViewProxy];
        };
        id<UITableViewDelegate> (^resolveIndexPathAt2)(AKAMultiplexedTableViewDataSourceBase*, NSInvocation*, BOOL) =
        ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation* inv, BOOL useTableViewProxy)
        {
            return [mds resolveDelegateForInvocation:inv
                       withTableViewParameterAtIndex:0
                           indexPathParameterAtIndex:2
                                  resolveCoordinates:YES
                                   useTableViewProxy:useTableViewProxy];
        };
        id<UITableViewDelegate> (^resolveIndexPathAt1And2)(AKAMultiplexedTableViewDataSourceBase* mds,
                                                    NSInvocation* inv) = ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation* inv)
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
    NSDictionary* sharedMappings = [AKAMultiplexedTableViewDataSourceBase sharedTableViewDelegateSelectorMapping];
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
    NSDictionary* sharedMappings = [AKAMultiplexedTableViewDataSourceBase sharedTableViewDelegateSelectorMapping];
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
    id<UITableViewDelegate>(^mapping)(AKAMultiplexedTableViewDataSourceBase* mds,
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
