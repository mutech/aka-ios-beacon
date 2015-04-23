//
//  AKATableViewProxy.m
//  AKACommons
//
//  Created by Michael Utech on 22.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATableViewProxy.h"
#import "AKATVDataSource.h"
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
@interface AKATableViewProxy()

@property(nonnull, readonly, weak) UITableView* aka_proxiedTableView;
@property(nonnull, readonly, weak) AKATVDataSource* aka_dataSource;

@end

@implementation AKATableViewProxy

#pragma mark - Initialization

- (instancetype)initWithTableView:(UITableView*)tableView
                       dataSource:(AKATVDataSource*)dataSource
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

- (NSIndexPath*)aka_mappedIndexPath:(NSIndexPath*)indexPath
{
    AKATVDataSource* ds = self.aka_dataSource;
    return [ds mappedIndexPath:indexPath];
}

- (NSIndexPath*)aka_reverseMappedIndexPath:(NSIndexPath*)indexPath
{
    AKATVDataSource* ds = self.aka_dataSource;
    return [ds reverseMappedIndexPath:indexPath];
}

- (NSArray*)aka_mappedIndexPaths:(NSArray*)indexPaths
{
    AKATVDataSource* ds = self.aka_dataSource;
    return [ds mappedIndexPaths:indexPaths];
}

- (NSArray*)aka_reverseMappedIndexPaths:(NSArray*)indexPaths
{
    AKATVDataSource* ds = self.aka_dataSource;
    return [ds reverseMappedIndexPaths:indexPaths];
}

- (NSInteger)aka_mappedSection:(NSInteger)section
{
    AKATVDataSource* ds = self.aka_dataSource;
    return [ds mappedSection:section];
}

- (NSIndexSet*)aka_mappedSectionIndexSet:(NSIndexSet*)sections
{
    AKATVDataSource* ds = self.aka_dataSource;
    return [ds mappedSectionIndexSet:sections];
}

- (NSArray*)aka_filteredCells:(NSArray*)cells
{
    AKATVDataSource* ds = self.aka_dataSource;
    return [ds filteredCells:cells];
}

#pragma mark - Configuring a Table View

- (NSInteger)numberOfSections
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv numberOfSections];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv numberOfRowsInSection:section];
}

#pragma mark - Creating Table View Cells

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv dequeueReusableCellWithIdentifier:identifier
                                    forIndexPath:[self aka_mappedIndexPath:indexPath]];
}

#pragma mark - Accessing Header and Footer Views

- (UITableViewHeaderFooterView *)headerViewForSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv headerViewForSection:[self aka_mappedSection:section]];
}

- (UITableViewHeaderFooterView *)footerViewForSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv footerViewForSection:[self aka_mappedSection:section]];
}

#pragma mark - Accessing Cells and Sections

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv cellForRowAtIndexPath:[self aka_mappedIndexPath:indexPath]];
}

- (NSIndexPath*)indexPathForCell:(UITableViewCell *)cell
{
    UITableView* tv = self.aka_proxiedTableView;
    NSIndexPath* indexPath = [tv indexPathForCell:cell];
    return [self aka_reverseMappedIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point
{
    UITableView* tv = self.aka_proxiedTableView;
    NSIndexPath* indexPath = [tv indexPathForRowAtPoint:point];
    return [self aka_reverseMappedIndexPath:indexPath];
}

- (NSArray *)indexPathsForRowsInRect:(CGRect)rect
{
    UITableView* tv = self.aka_proxiedTableView;
    NSArray* indexPaths = [tv indexPathsForRowsInRect:rect];
    return [self aka_reverseMappedIndexPaths:indexPaths];
}

- (NSArray *)visibleCells
{
    UITableView* tv = self.aka_proxiedTableView;
    NSArray* cells = [tv visibleCells];
    return [self aka_filteredCells:cells];
}

- (NSArray *)indexPathsForVisibleRows
{
    UITableView* tv = self.aka_proxiedTableView;
    NSArray* indexPaths = [tv indexPathsForVisibleRows];
    return [self aka_reverseMappedIndexPaths:indexPaths];
}

#pragma mark - Scrolling the Table View

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
              atScrollPosition:(UITableViewScrollPosition)scrollPosition
                      animated:(BOOL)animated
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv scrollToRowAtIndexPath:[self aka_mappedIndexPath:indexPath]
              atScrollPosition:scrollPosition
                      animated:animated];
}

#pragma mark - Managing Selections

- (NSIndexPath *)indexPathForSelectedRow
{
    UITableView* tv = self.aka_proxiedTableView;
    NSIndexPath* indexPath = [tv indexPathForSelectedRow];
    return [self aka_reverseMappedIndexPath:indexPath];
}

- (NSArray *)indexPathsForSelectedRows
{
    UITableView* tv = self.aka_proxiedTableView;
    NSArray* indexPaths = [tv indexPathsForSelectedRows];
    return [self aka_reverseMappedIndexPaths:indexPaths];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath
                    animated:(BOOL)animated
              scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv selectRowAtIndexPath:[self aka_mappedIndexPath:indexPath]
                    animated:animated
              scrollPosition:scrollPosition];
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv deselectRowAtIndexPath:[self aka_mappedIndexPath:indexPath]
                      animated:animated];
}

#pragma mark - Inserting, Deleting and  Moving Rows and Sections

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv insertSections:[self aka_mappedSectionIndexSet:sections] withRowAnimation:animation];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv deleteSections:[self aka_mappedSectionIndexSet:sections] withRowAnimation:animation];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv moveSection:[self aka_mappedSection:section]
          toSection:[self aka_mappedSection:newSection]];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv insertRowsAtIndexPaths:[self aka_mappedIndexPaths:indexPaths] withRowAnimation:animation];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv deleteRowsAtIndexPaths:[self aka_mappedIndexPaths:indexPaths] withRowAnimation:animation];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv moveRowAtIndexPath:[self aka_mappedIndexPath:indexPath]
               toIndexPath:[self aka_mappedIndexPath:newIndexPath]];
}

#pragma mark - Reloading the Table View

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    UITableView* tv = self.aka_proxiedTableView;
    [tv reloadRowsAtIndexPaths:[self aka_mappedIndexPaths:indexPaths]
              withRowAnimation:animation];
}

#pragma mark - Accessing Drawing Areas of the Table View

- (CGRect)rectForSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv rectForSection:[self aka_mappedSection:section]];
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv rectForRowAtIndexPath:[self aka_mappedIndexPath:indexPath]];
}

- (CGRect)rectForFooterInSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv rectForFooterInSection:[self aka_mappedSection:section]];
}

- (CGRect)rectForHeaderInSection:(NSInteger)section
{
    UITableView* tv = self.aka_proxiedTableView;
    return [tv rectForHeaderInSection:[self aka_mappedSection:section]];
}

#pragma mark - Managing the Data Source and Delegate

- (id<UITableViewDataSource>)dataSource
{
    AKATVDataSource* ds = self.aka_dataSource;
    return ds.dataSource;
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    (void)dataSource;
    NSString* reason = [NSString stringWithFormat:@"Invalid attempt to change the dataSource of %@",
                        self];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:reason userInfo:nil];
}

- (id<UITableViewDelegate>)delegate
{
    AKATVDataSource* ds = self.aka_dataSource;
    return ds.delegate;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    (void)delegate;
    NSString* reason = [NSString stringWithFormat:@"Invalid attempt to change the delegate of %@",
                        self];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:reason userInfo:nil];
}

@end
