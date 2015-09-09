//
//  AKATableViewProxy.m
//  AKACommons
//
//  Created by Michael Utech on 22.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATVProxy.h"
#import "AKATVDataSourceSpecification.h"
#import "AKATVCoordinateMappingProtocol.h"

/**
 * Proxy for a table view which maps section and row coordinates between
 * what a data source or delegate expects and the real table view which
 * is controlled by another (multiplexing) data source and/or delegate.
 *
 * This proxy is used in the context of multiplexed table view data sources
 * which provide the proxy to source delegates in order to make them work
 * with a table view that has a different structure from what they assume.
 *
 * @note You should not perform any view hierarchy manipulations with this
 *      proxy (that will almost certainly fail).
 */
@interface AKATVProxy()

@property(nonnull, readonly, weak) UITableView* aka_proxiedTableView;
@property(nonnull, readonly, weak) AKATVDataSourceSpecification* aka_dataSource;

@end

@implementation AKATVProxy

#pragma mark - Initialization

- (instancetype)initWithTableView:(UITableView*)tableView
                       dataSource:(AKATVDataSourceSpecification*)dataSource
{
    _aka_proxiedTableView = tableView;
    _aka_dataSource = dataSource;
    return self;
}

#pragma mark - Proxy Implementation

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.aka_proxiedTableView];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    UITableView* tableView = self.aka_proxiedTableView;
    return [tableView methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    UITableView* tableView = self.aka_proxiedTableView;
    return ([super respondsToSelector:aSelector] ||
            [tableView respondsToSelector:aSelector]);
}

- (BOOL)isKindOfClass:(Class)aClass
{
    UITableView* tableView = self.aka_proxiedTableView;
    return ([super isKindOfClass:aClass] ||
            [tableView isKindOfClass:aClass]);
}

#pragma mark - Coordinate Mapping

- (NSIndexPath*)aka_tableViewIndexPathFor:(NSIndexPath*)indexPath
{
    AKATVDataSourceSpecification* ds = self.aka_dataSource;
    return [ds  tableViewMappedIndexPath:indexPath];
}

- (NSIndexPath*)aka_dataSourceIndexPathFor:(NSIndexPath*)indexPath
{
    AKATVDataSourceSpecification* ds = self.aka_dataSource;
    return [ds dataSourceIndexPath:indexPath];
}

- (NSArray*)aka_tableViewIndexPaths:(NSArray*)indexPaths
{
    AKATVDataSourceSpecification* ds = self.aka_dataSource;
    return [ds tableViewMappedIndexPaths:indexPaths];
}

- (NSArray*)aka_dataSourceIndexPaths:(NSArray*)indexPaths
{
    AKATVDataSourceSpecification* ds = self.aka_dataSource;
    return [ds dataSourceIndexPaths:indexPaths];
}

- (NSInteger)aka_tableViewSectionFor:(NSInteger)section
{
    AKATVDataSourceSpecification* ds = self.aka_dataSource;
    return [ds tableViewSection:section];
}

- (NSIndexSet*)aka_tableViewSectionIndexSet:(NSIndexSet*)sections
{
    AKATVDataSourceSpecification* ds = self.aka_dataSource;
    return [ds tableViewSectionIndexSet:sections];
}

- (NSArray*)aka_excludeCellsFromOtherDataSources:(NSArray*)cells
{
    AKATVDataSourceSpecification* ds = self.aka_dataSource;
    return [ds filteredCells:cells];
}

#pragma mark - Configuring a Table View

- (NSInteger)numberOfSections
{
    // TODO: Don't know what to do with this one (yet)
    UITableView* tv = self.aka_proxiedTableView;
    return [tv numberOfSections];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    // TODO: Don't know what to do with this one (yet)
    UITableView* tv = self.aka_proxiedTableView;
    return [tv numberOfRowsInSection:section];
}

#pragma mark - Creating Table View Cells

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv dequeueReusableCellWithIdentifier:identifier
                                    forIndexPath:[self aka_tableViewIndexPathFor:indexPath]];
}

#pragma mark - Accessing Header and Footer Views

- (UITableViewHeaderFooterView *)headerViewForSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv headerViewForSection:[self aka_tableViewSectionFor:section]];
}

- (UITableViewHeaderFooterView *)footerViewForSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv footerViewForSection:[self aka_tableViewSectionFor:section]];
}

#pragma mark - Accessing Cells and Sections

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableView* tv = self.aka_proxiedTableView;
    NSIndexPath* mappedIndexPath = [self aka_tableViewIndexPathFor:indexPath];
    return [tv cellForRowAtIndexPath:mappedIndexPath];
}

- (NSIndexPath*)indexPathForCell:(UITableViewCell *)cell
{
    UITableView* tv = self.aka_proxiedTableView;
    NSIndexPath* indexPath = [tv indexPathForCell:cell];
    return [self aka_dataSourceIndexPathFor:indexPath];
}

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point
{
    UITableView* tv = self.aka_proxiedTableView;
    NSIndexPath* indexPath = [tv indexPathForRowAtPoint:point];
    return [self aka_dataSourceIndexPathFor:indexPath];
}

- (NSArray *)indexPathsForRowsInRect:(CGRect)rect
{
    UITableView* tv = self.aka_proxiedTableView;
    NSArray* indexPaths = [tv indexPathsForRowsInRect:rect];
    return [self aka_dataSourceIndexPaths:indexPaths];
}

- (NSArray *)visibleCells
{
    UITableView* tv = self.aka_proxiedTableView;
    NSArray* cells = [tv visibleCells];
    return [self aka_excludeCellsFromOtherDataSources:cells];
}

- (NSArray *)indexPathsForVisibleRows
{
    UITableView* tv = self.aka_proxiedTableView;
    NSArray* indexPaths = [tv indexPathsForVisibleRows];
    return [self aka_dataSourceIndexPaths:indexPaths];
}

#pragma mark - Scrolling the Table View

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
              atScrollPosition:(UITableViewScrollPosition)scrollPosition
                      animated:(BOOL)animated
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv scrollToRowAtIndexPath:[self aka_tableViewIndexPathFor:indexPath]
              atScrollPosition:scrollPosition
                      animated:animated];
}

#pragma mark - Managing Selections

- (NSIndexPath *)indexPathForSelectedRow
{
    UITableView* tv = self.aka_proxiedTableView;
    NSIndexPath* indexPath = [tv indexPathForSelectedRow];
    return [self aka_dataSourceIndexPathFor:indexPath];
}

- (NSArray *)indexPathsForSelectedRows
{
    UITableView* tv = self.aka_proxiedTableView;
    NSArray* indexPaths = [tv indexPathsForSelectedRows];
    return [self aka_dataSourceIndexPaths:indexPaths];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath
                    animated:(BOOL)animated
              scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv selectRowAtIndexPath:[self aka_tableViewIndexPathFor:indexPath]
                    animated:animated
              scrollPosition:scrollPosition];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    UITableView* tv = self.aka_proxiedTableView;
    NSIndexPath* realIndexPath = [self aka_tableViewIndexPathFor:indexPath];
    [tv deselectRowAtIndexPath:realIndexPath
                      animated:animated];
}

#pragma mark - Inserting, Deleting and  Moving Rows and Sections

// To implement this correctly, we would have to track structure changes and map usages
// of data source coordinates in the multiplexer accordingly. Maybe later.

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    NSAssert(NO, @"Table structure manipulation is not (yet) supported.");
    UITableView* tv = self.aka_proxiedTableView;
    [tv insertSections:[self aka_tableViewSectionIndexSet:sections] withRowAnimation:animation];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    NSAssert(NO, @"Table structure manipulation is not (yet) supported.");
    UITableView* tv = self.aka_proxiedTableView;
    [tv deleteSections:[self aka_tableViewSectionIndexSet:sections] withRowAnimation:animation];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    NSAssert(NO, @"Table structure manipulation is not (yet) supported.");
    UITableView* tv = self.aka_proxiedTableView;
    [tv moveSection:[self aka_tableViewSectionFor:section]
          toSection:[self aka_tableViewSectionFor:newSection]];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    NSAssert(NO, @"Table structure manipulation is not (yet) supported.");
    UITableView* tv = self.aka_proxiedTableView;
    [tv insertRowsAtIndexPaths:[self aka_tableViewIndexPaths:indexPaths] withRowAnimation:animation];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    NSAssert(NO, @"Table structure manipulation is not (yet) supported.");
    UITableView* tv = self.aka_proxiedTableView;
    [tv deleteRowsAtIndexPaths:[self aka_tableViewIndexPaths:indexPaths] withRowAnimation:animation];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    NSAssert(NO, @"Table structure manipulation is not (yet) supported.");
    UITableView* tv = self.aka_proxiedTableView;
    [tv moveRowAtIndexPath:[self aka_tableViewIndexPathFor:indexPath]
               toIndexPath:[self aka_tableViewIndexPathFor:newIndexPath]];
}

#pragma mark - Reloading the Table View

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv reloadRowsAtIndexPaths:[self aka_tableViewIndexPaths:indexPaths]
              withRowAnimation:animation];
}

#pragma mark - Accessing Drawing Areas of the Table View

- (CGRect)rectForSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv rectForSection:[self aka_tableViewSectionFor:section]];
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv rectForRowAtIndexPath:[self aka_tableViewIndexPathFor:indexPath]];
}

- (CGRect)rectForFooterInSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv rectForFooterInSection:[self aka_tableViewSectionFor:section]];
}

- (CGRect)rectForHeaderInSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv rectForHeaderInSection:[self aka_tableViewSectionFor:section]];
}

#pragma mark - Managing the Data Source and Delegate

- (id<UITableViewDataSource>)dataSource
{
    // Pretend the tableView is based on the source data source. This will not work
    // in all cases (would need a complete bidrectional mapping -> look at TODO's).
    AKATVDataSourceSpecification* ds = self.aka_dataSource;
    return ds.dataSource;
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    // Setting the dataSource from a delegate could be supported, but then we would have
    // to scan all references to the old dataSource in the multiplexer and update
    // them (number of sections/rows etc).
    (void)dataSource;
    NSString* reason = [NSString stringWithFormat:@"Invalid attempt to change the dataSource of %@",
                        self];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:reason userInfo:nil];
}

- (id<UITableViewDelegate>)delegate
{
    // Pretend the tableView is using source delegate. This will not work
    // in all cases (would need a complete bidrectional mapping -> look at TODO's).
    AKATVDataSourceSpecification* ds = self.aka_dataSource;
    return ds.delegate;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    // TODO: This could actually work out of the box, would need testing -> no time now
    (void)delegate;
    NSString* reason = [NSString stringWithFormat:@"Invalid attempt to change the delegate of %@",
                        self];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:reason userInfo:nil];
}

@end
