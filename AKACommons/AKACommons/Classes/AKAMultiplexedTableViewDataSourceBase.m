//
//  AKAMultiplexedTableViewDataSourceBase.m
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAErrors.h"

#import "AKAMultiplexedTableViewDataSourceBase.h"
#import <objc/runtime.h>

#pragma mark - AKATVDataSource
#pragma mark -

@implementation AKATVDataSource
+ (instancetype)dataSource:(id<UITableViewDataSource>)dataSource
              withDelegate:(id<UITableViewDelegate>)delegate
{
    return [[AKATVDataSource alloc] initWithDataSource:dataSource delegate:delegate];
}
- (instancetype)initWithDataSource:(id<UITableViewDataSource>)dataSource
                          delegate:(id<UITableViewDelegate>)delegate
{
    if (self = [self init])
    {
        _dataSource = dataSource;
        _delegate = delegate;
    }
    return self;
}
@end

#pragma mark - AKAMultiplexedTableViewDataSourceBase
#pragma mark -

@interface AKAMultiplexedTableViewDataSourceBase()

@property(nonatomic, readonly) NSMutableDictionary* dataSourcesByKey;
@property(nonatomic, readonly) NSMutableDictionary* tableViewDelegateSelectorMapping;

@end

@implementation AKAMultiplexedTableViewDataSourceBase

#pragma mark - Initialization

+ (instancetype)proxyDataSourceAndDelegateInTableView:(UITableView*)tableView
{
    AKAMultiplexedTableViewDataSourceBase* result = [[self alloc] init];
    if (tableView.dataSource != nil)
    {
        NSString* key = [self defaultDataSourceKey];
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

+ (instancetype)proxyDataSourceAndDelegateInTableView:(UITableView*)tableView
                                  andAppendDataSource:(id<UITableViewDataSource>)dataSource
                                         withDelegate:(id<UITableViewDelegate>)delegate
                                               forKey:(NSString*)key
{
    AKAMultiplexedTableViewDataSourceBase* result =
    [self proxyDataSourceAndDelegateInTableView:tableView];

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

- (instancetype)initWithTableView:(UITableView*)tableView
{
    if (self = [self init])
    {
        if (tableView.dataSource != nil)
        {
            [self addDataSource:tableView.dataSource
                   withDelegate:tableView.delegate
                         forKey:[self.class defaultDataSourceKey]];
            NSInteger numberOfSections = [tableView.dataSource numberOfSectionsInTableView:tableView];
            [self insertSectionsFromDataSource:[self.class defaultDataSourceKey]
                            sourceSectionIndex:0
                                         count:(NSUInteger)numberOfSections
                                atSectionIndex:0
                             useRowsFromSource:YES
                                     tableView:tableView
                                        update:NO
                              withRowAnimation:UITableViewRowAnimationNone];
        }
        if (tableView.dataSource != nil || tableView.delegate == nil)
        {
            // Only install if delegate was registered (it is unless dataSource is nil)
            // or if no delegate is set.
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView reloadData];
        }
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
                                             withDelegate:delegate];
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

- (BOOL)resolveDataSource:(out __autoreleasing id<UITableViewDataSource> *)dataSourceStorage
                 delegate:(out __autoreleasing id<UITableViewDelegate>*)delegateStorage
       sourceSectionIndex:(out NSInteger *)sectionIndexStorage
          forSectionIndex:(NSInteger)sectionIndex
{
    (void)dataSourceStorage;
    (void)delegateStorage;
    (void)sectionIndexStorage;
    (void)sectionIndex;
    AKAErrorAbstractMethodImplementationMissing();
}

- (BOOL)resolveDataSource:(out __autoreleasing id<UITableViewDataSource> *)dataSourceStorage
                 delegate:(out __autoreleasing id<UITableViewDelegate>*)delegateStorage
          sourceIndexPath:(out NSIndexPath *__autoreleasing *)indexPathStorage
             forIndexPath:(NSIndexPath*)indexPath
{
    (void)dataSourceStorage;
    (void)delegateStorage;
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
    (void)tableView;
    (void)sourceIndexPath;
    (void)destinationIndexPath;
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSInteger)                   tableView:(UITableView *)tableView
              sectionForSectionIndexTitle:(NSString *)title
                                  atIndex:(NSInteger)index
{
    (void)tableView;
    (void)title;
    (void)index;
    AKAErrorAbstractMethodImplementationMissing();
}
#endif

#pragma mark - UITableViewDelegate

+ (NSDictionary*)sharedTableViewDelegateSelectorMapping
{
    static NSDictionary* sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        id<UITableViewDelegate> (^resolveBySection)(AKAMultiplexedTableViewDataSourceBase*, NSInvocation*, NSInteger) =
        ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds,
                                 NSInvocation* inv,
                                 NSInteger parameterIndex)
        {
            id<UITableViewDelegate> result = nil;
            NSInteger section = NSNotFound;
            [inv getArgument:&section atIndex:2+parameterIndex];
            if ([mds resolveDataSource:nil delegate:&result sourceSectionIndex:&section forSectionIndex:section])
            {
                //[inv setArgument:&section atIndex:2+parameterIndex];
            }
            return result;
        };
        id<UITableViewDelegate> (^resolveByIndexPath)(AKAMultiplexedTableViewDataSourceBase*, NSInvocation*, NSInteger) =
        ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds,
                                 NSInvocation* inv,
                                 NSInteger parameterIndex)
        {
            id<UITableViewDelegate> result = nil;

            NSIndexPath* __unsafe_unretained indexPath;
            [inv getArgument:&indexPath atIndex:2+parameterIndex];

            NSIndexPath* sourceIndexPath = nil;
            if ([mds resolveDataSource:nil delegate:&result sourceIndexPath:&sourceIndexPath forIndexPath:indexPath])
            {
                //[inv setArgument:&sourceIndexPath atIndex:2+parameterIndex];
            }
            return result;
        };

        id<UITableViewDelegate> (^sectionAt1)(AKAMultiplexedTableViewDataSourceBase* mds,
                                              NSInvocation* inv) = ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation* inv)
        {
            return resolveBySection(mds, inv, 1);
        };
        id<UITableViewDelegate> (^sectionAt2)(AKAMultiplexedTableViewDataSourceBase* mds,
                                              NSInvocation* inv) = ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation* inv)
        {
            return resolveBySection(mds, inv, 2);
        };
        id<UITableViewDelegate> (^indexPathAt1)(AKAMultiplexedTableViewDataSourceBase* mds,
                                                NSInvocation* inv) = ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation* inv)
        {
            return resolveByIndexPath(mds, inv, 1);
        };
        id<UITableViewDelegate> (^indexPathAt2)(AKAMultiplexedTableViewDataSourceBase* mds,
                                                NSInvocation* inv) = ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation* inv)
        {
            return resolveByIndexPath(mds, inv, 2);
        };
        id<UITableViewDelegate> (^indexPathAt1And2)(AKAMultiplexedTableViewDataSourceBase* mds,
                                                    NSInvocation* inv) = ^id<UITableViewDelegate>(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation* inv)
        {
            (void)mds; (void)inv;
            return nil;
        };

        sharedInstance =
            @{ [NSValue valueWithPointer:@selector(tableView:heightForHeaderInSection:)]: sectionAt1,
               [NSValue valueWithPointer:@selector(tableView:heightForFooterInSection:)]: sectionAt1,
               [NSValue valueWithPointer:@selector(tableView:viewForHeaderInSection:)]: sectionAt1,
               [NSValue valueWithPointer:@selector(tableView:viewForFooterInSection:)]: sectionAt1,
               [NSValue valueWithPointer:@selector(tableView:estimatedHeightForHeaderInSection:)]: sectionAt1,
               [NSValue valueWithPointer:@selector(tableView:estimatedHeightForFooterInSection:)]: sectionAt1,

               [NSValue valueWithPointer:@selector(tableView:willDisplayHeaderView:forSection:)]: sectionAt2,
               [NSValue valueWithPointer:@selector(tableView:willDisplayFooterView:forSection:)]: sectionAt2,
               [NSValue valueWithPointer:@selector(tableView:didEndDisplayingHeaderView:forSection:)]: sectionAt2,
               [NSValue valueWithPointer:@selector(tableView:didEndDisplayingFooterView:forSection:)]: sectionAt2,

               [NSValue valueWithPointer:@selector(tableView:heightForRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:estimatedHeightForRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:accessoryTypeForRowWithIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:shouldHighlightRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:didHighlightRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:didUnhighlightRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:willSelectRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:willDeselectRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:didSelectRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:didDeselectRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:editingStyleForRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:editActionsForRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:willBeginEditingRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:didEndEditingRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:indentationLevelForRowAtIndexPath:)]: indexPathAt1,
               [NSValue valueWithPointer:@selector(tableView:shouldShowMenuForRowAtIndexPath:)]: indexPathAt1,

               [NSValue valueWithPointer:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]: indexPathAt2,
               [NSValue valueWithPointer:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]: indexPathAt2,
               [NSValue valueWithPointer:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)]: indexPathAt2,
               [NSValue valueWithPointer:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]: indexPathAt2,
               [NSValue valueWithPointer:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]: indexPathAt1And2
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
    id<UITableViewDelegate>(^mapping)(AKAMultiplexedTableViewDataSourceBase* mds, NSInvocation *inv) =
        self.tableViewDelegateSelectorMapping[selectorValue];
    if (mapping)
    {
        id<UITableViewDelegate> delegate = mapping(self, anInvocation);
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
