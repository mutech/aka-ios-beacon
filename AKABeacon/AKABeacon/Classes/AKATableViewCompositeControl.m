//
//  AKATableViewCompositeControl.m
//  AKABeacon
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKALog.h"
#import "UIView+AKAHierarchyVisitor.h"

#import "AKATableViewCompositeControl.h"
#import "AKAControl_Internal.h"
#import "AKABinding_UITableView_dataSourceBinding.h"

@interface AKATableViewDynamicSectionInfo: NSObject

/**
   The data context used by cell bindings. Uses a strong reference to ensure that the data context is retained while the binding is active (which in turn corresponds to the life time of the associated control.
 */
@property(nonatomic) id dataContext;

/**
   The section index.

   @note Please note that this value might not be up to date, especially during and short after table view update operations resulting from inserting/deleting/reordering sections.
 */
@property(nonatomic) NSInteger section;

/**
   The view displayed for the header of footer.
 */
@property(nonatomic, weak) UIView* headerOrFooter;

/**
   Determines if the view is used as header or footer of the table view section.
 */
@property(nonatomic) BOOL isHeader;

/**
   The control owning bindings and representing this row.
 */
@property(nonatomic, weak) AKACompositeControl* control;

@end

@implementation AKATableViewDynamicSectionInfo

- (instancetype)initWithHeaderView:(UIView*)view
                        forSection:(NSInteger)section
                           control:(AKACompositeControl*)control
                       dataContext:(id)dataContext
{
    if (self = [super init])
    {
        self.isHeader = YES;
        self.section = section;
        self.headerOrFooter = view;
        self.control = control;
        self.dataContext = dataContext;
    }

    return self;
}

- (instancetype)initWithFooterView:(UIView*)view
                        forSection:(NSInteger)section
                           control:(AKACompositeControl*)control
                       dataContext:(id)dataContext
{
    if (self = [super init])
    {
        self.isHeader = NO;
        self.section = section;
        self.headerOrFooter = view;
        self.control = control;
        self.dataContext = dataContext;
    }

    return self;
}

@end


/**
   Contains information about currently displayed table view rows. The primary use is to ensure that data contexts for cells are kept alive while bindings are observing them.
 */
@interface AKATableViewDynamicRowInfo: NSObject

/**
   The data context used by cell bindings. Uses a strong reference to ensure that the data context is retained while the binding is active (which in turn corresponds to the life time of the associated control.
 */
@property(nonatomic) id dataContext;

/**
   The index path of the row.

   @note Please note that this value might not be up to date, especially during and short after table view update operations resulting from inserting/deleting/reordering rows.
 */
@property(nonatomic) NSIndexPath* indexPath;

/**
   The cell displayed for the row.
 */
@property(nonatomic, weak) UITableViewCell* cell;

/**
   The control owning bindings and representing this row.
 */
@property(nonatomic, weak) AKACompositeControl* control;

@end


@implementation AKATableViewDynamicRowInfo

- (instancetype)initWithCell:(UITableViewCell*)cell
           forRowAtIndexPath:(NSIndexPath*)indexPath
                     control:(AKACompositeControl*)control
                 dataContext:(id)dataContext
{
    if (self = [super init])
    {
        self.indexPath = indexPath;
        self.cell = cell;
        self.control = control;
        self.dataContext = dataContext;
    }

    return self;
}

@end


@interface AKATableViewCompositeControl () <AKABindingDelegate_UITableView_dataSourceBinding>

/**
   Provides information about visible rows. Most importantly, row infos keep strong references to data contexts used in bindings of rows to ensure that they are kept alive while the bindings are observing changes.
 */
@property(nonatomic, readonly) NSMutableSet<AKATableViewDynamicRowInfo*>*       dynamicRowInfos;

/**
 Indicates whether an update for dynamic row infos is dispatched. If so, further updates to rows will not dispatch another update.
 */
@property(nonatomic)           BOOL                                             dynamicRowInfoUpdateDispatched;

/**
 Provides information about visible sections. Most importantly, section infos keep strong references to data contexts used in bindings of section headers and footers to ensure that they are kept alive while the bindings are observing changes.
 */
@property(nonatomic, readonly) NSMutableSet<AKATableViewDynamicSectionInfo*>*   dynamicSectionInfos;

/**
 Indicates whether an update for dynamic section infos is dispatched. If so, further updates to sections will not dispatch another update.
 */
@property(nonatomic)           BOOL                                             dynamicSectionInfoUpdateDispatched;

@end


@implementation AKATableViewCompositeControl

#pragma mark - Initialization

- (instancetype)                                        init
{
    if (self = [super init])
    {
        _dynamicRowInfos = [NSMutableSet new];
    }

    return self;
}

#pragma mark - Managing Controls and Bindings for Visible Rows

- (AKATableViewDynamicRowInfo*)        dynamicRowInfoForCell:(UITableViewCell*)cell
                                                   indexPath:(NSIndexPath*)indexPath
                                         requireMatchingCell:(BOOL)requireMatchingCell
                                    requireMatchingIndexPath:(BOOL)requireMatchingIndexPath
{
    __block AKATableViewDynamicRowInfo* result = nil;
    __block AKATableViewDynamicRowInfo* resultMatchingCell = nil;
    __block AKATableViewDynamicRowInfo* resultMatchingIndexPath = nil;

    [self.dynamicRowInfos enumerateObjectsUsingBlock:
     ^(AKATableViewDynamicRowInfo* _Nonnull rowInfo, BOOL* _Nonnull stop) {
         if (cell == rowInfo.cell)
         {
             resultMatchingCell = rowInfo;

             if ([indexPath isEqual:rowInfo.indexPath])
             {
                 result = rowInfo;
                 *stop = YES;
             }
         }
         else if ([indexPath isEqual:rowInfo.indexPath])
         {
             resultMatchingIndexPath = rowInfo;
         }
     }];

    // Fallback if no exact match is found
    if (!result && !requireMatchingIndexPath)
    {
        result = resultMatchingCell;
    }

    if (!result && !requireMatchingCell)
    {
        result = resultMatchingIndexPath;
    }

    return result;
}

- (void)                                             binding:(AKABinding_UITableView_dataSourceBinding*)binding
                                   addDynamicBindingsForCell:(UITableViewCell*)cell
                                                   indexPath:(NSIndexPath*)indexPath
                                                 dataContext:(id)dataContext
{
    (void)binding;

    AKATableViewDynamicRowInfo* previousRowInfo = [self dynamicRowInfoForCell:cell
                                                                    indexPath:indexPath
                                                          requireMatchingCell:NO
                                                     requireMatchingIndexPath:NO];
    AKATableViewDynamicRowInfo* rowInfo = nil;

    if (previousRowInfo)
    {
        if (previousRowInfo.cell == cell)
        {
            // Cell matches, in this case the old row info will be reused or replaced

            AKAControl* previousRowInfoControl = previousRowInfo.control;

            if (previousRowInfoControl && previousRowInfo.dataContext == dataContext)
            {
                // cell, control and dataContext are equal, we're going to reuse the cell
                rowInfo = previousRowInfo;

                if (![indexPath isEqual:rowInfo.indexPath])
                {
                    // update index path if it changed.
                    rowInfo.indexPath = indexPath;
                }
            }
            else
            {
                // data context changed or control is undefined, we're going to replace the rowinfo
                if (previousRowInfoControl)
                {
                    [self removeControl:previousRowInfoControl];
                }
                [self.dynamicRowInfos removeObject:previousRowInfo];
            }
        }
        else
        {
            // If the cell is different, we'll keep the previous rowinfo, it might be removed later
            // or change it's position due to other TV operations (we might not see these changes, so
            // the indexPath is not reliable).
        }
    }

    AKACompositeControl* control = rowInfo.control;

    if (!control)
    {
        control = [[AKACompositeControl alloc] initWithDataContext:dataContext
                                                     configuration:nil];
        [control setView:cell];
        [self addControl:control];
    }

    if (!rowInfo)
    {
        rowInfo = [[AKATableViewDynamicRowInfo alloc] initWithCell:cell
                                                 forRowAtIndexPath:indexPath
                                                           control:control
                                                       dataContext:dataContext];
        [self.dynamicRowInfos addObject:rowInfo];
    }

    // TODO: get the exclusion views (for embedded view controllers) from delegate?
    [control addControlsForControlViewsInViewHierarchy:cell.contentView
                                          excludeViews:nil];
}

- (void)                                             binding:(AKABinding_UITableView_dataSourceBinding*)binding
                                removeDynamicBindingsForCell:(UITableViewCell*)cell
                                                   indexPath:(NSIndexPath*)indexPath
{
    (void)binding;

    AKATableViewDynamicRowInfo* rowInfo = [self dynamicRowInfoForCell:cell
                                                            indexPath:indexPath
                                                  requireMatchingCell:YES
                                             requireMatchingIndexPath:NO];

    if (rowInfo)
    {
        AKAControl* rowInfoControl = rowInfo.control;

        if (rowInfoControl)
        {
            [self removeControl:rowInfoControl];
        }
        [self.dynamicRowInfos removeObject:rowInfo];

        // Other rows might change their position as result of this removal. The information in dynamicRowInfos will be updated in a separate dispatch job to ensure that it's only done once per TV update batch:
        [self dispatchUpdateRowInfos];
    }
}

/**
   Dispatches a call to performUpdateRowInfos to the main queue in order to do this once for all changes triggered in the current main queue job.
 */
- (void)                              dispatchUpdateRowInfos
{
    NSAssert([NSThread isMainThread], @"Has to be called from main thread only");

    if (!self.dynamicRowInfoUpdateDispatched)
    {
        self.dynamicRowInfoUpdateDispatched = YES;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf performUpdateRowInfos];
        });
    }
}

/**
   Iterates through all dynamicRowInfos to correct indexPaths that might have changed during the last tableView update.
 */
- (void)                               performUpdateRowInfos
{
    if (self.dynamicRowInfoUpdateDispatched)
    {
        self.dynamicRowInfoUpdateDispatched = NO;

        UITableView* tableView = (UITableView*)self.view;

        if (tableView)
        {
            [self.dynamicRowInfos enumerateObjectsUsingBlock:
             ^(AKATableViewDynamicRowInfo* _Nonnull obj, BOOL* _Nonnull __unused stop)
             {
                 UITableViewCell* cell = obj.cell;

                 if (cell)
                 {
                     NSIndexPath* indexPath = [tableView indexPathForCell:cell];

                     if (indexPath)
                     {
                         if (![indexPath isEqual:obj.indexPath])
                         {
                             obj.indexPath = indexPath;
                         }
                     }
                     else
                     {
                         // TODO: We might want to delete rowInfos for cells which are no longer visible, even though that doesn't seem to be necessary, at least not in all cases -> investigate if and in which cases this happens.
                         NSLog(@"Strange: rowInfo refers to a cell which is not visible: investigate this");
                     }
                 }
             }];
        }
    }
}

#pragma mark - Managing Controls and Bindings for Visible Section Headers and Footers

- (AKATableViewDynamicSectionInfo*)dynamicSectionInfoForView:(UIView*)view
                                                    asHeader:(BOOL)isHeaderView
                                                   inSection:(NSInteger)section
                                         requireMatchingView:(BOOL)requireMatchingView
                                      requireMatchingSection:(BOOL)requireMatchingSection
{
    __block AKATableViewDynamicSectionInfo* result = nil;
    __block AKATableViewDynamicSectionInfo* resultMatchingView = nil;
    __block AKATableViewDynamicSectionInfo* resultMatchingSection = nil;

    [self.dynamicSectionInfos enumerateObjectsUsingBlock:
     ^(AKATableViewDynamicSectionInfo* _Nonnull sectionInfo, BOOL* _Nonnull stop) {
         if (isHeaderView == sectionInfo.isHeader)
         {
             if (view == sectionInfo.headerOrFooter)
             {
                 resultMatchingView = sectionInfo;

                 if (section == sectionInfo.section)
                 {
                     result = sectionInfo;
                     *stop = YES;
                 }
             }
             else if (section == sectionInfo.section)
             {
                 resultMatchingSection = sectionInfo;
             }
         }
     }];

    // Fallback if no exact match is found
    if (!result && !requireMatchingSection)
    {
        result = resultMatchingView;
    }

    if (!result && !requireMatchingView)
    {
        result = resultMatchingSection;
    }

    return result;
}

- (void)                                             binding:(AKABinding_UITableView_dataSourceBinding*)binding
                                addDynamicBindingsForSection:(NSInteger)section
                                                        view:(UIView*)headerOrFooterView
                                                    asHeader:(BOOL)isHeader
                                                 dataContext:(id)dataContext
{
    (void)binding;

    AKATableViewDynamicSectionInfo* previousSectionInfo =
        [self dynamicSectionInfoForView:headerOrFooterView
                               asHeader:isHeader
                              inSection:section
                    requireMatchingView:NO
                 requireMatchingSection:NO];

    AKATableViewDynamicSectionInfo* sectionInfo = nil;

    if (previousSectionInfo)
    {
        if (previousSectionInfo.headerOrFooter == headerOrFooterView)
        {
            // View matches, in this case the old section info will be reused or replaced

            AKAControl* previousSectionInfoControl = previousSectionInfo.control;

            if (previousSectionInfoControl && previousSectionInfo.dataContext == dataContext)
            {
                // view, control and dataContext are equal, we're going to reuse the view
                sectionInfo = previousSectionInfo;

                if (section != sectionInfo.section)
                {
                    // update section if it changed.
                    sectionInfo.section = section;
                }
            }
            else
            {
                // data context changed or control is undefined, we're going to replace the sectionInfo
                if (previousSectionInfoControl)
                {
                    [self removeControl:previousSectionInfoControl];
                }
                [self.dynamicSectionInfos removeObject:previousSectionInfo];
            }
        }
        else
        {
            // If the cell is different, we'll keep the previous rowinfo, it might be removed later
            // or change it's position due to other TV operations (we might not see these changes, so
            // the indexPath is not reliable).
        }
    }

    AKACompositeControl* control = sectionInfo.control;

    if (!control)
    {
        control = [[AKACompositeControl alloc] initWithDataContext:dataContext
                                                     configuration:nil];
        [control setView:headerOrFooterView];
        [self addControl:control];
    }

    if (!sectionInfo)
    {
        if (isHeader)
        {
            sectionInfo = [[AKATableViewDynamicSectionInfo alloc] initWithHeaderView:headerOrFooterView
                                                                          forSection:section
                                                                             control:control
                                                                         dataContext:dataContext];
        }
        else
        {
            sectionInfo = [[AKATableViewDynamicSectionInfo alloc] initWithFooterView:headerOrFooterView
                                                                          forSection:section
                                                                             control:control
                                                                         dataContext:dataContext];
        }
        [self.dynamicSectionInfos addObject:sectionInfo];
    }

    // TODO: get the exclusion views (for embedded view controllers) from delegate?
    [control addControlsForControlViewsInViewHierarchy:headerOrFooterView
                                          excludeViews:nil];
}

- (void)                                             binding:(AKABinding_UITableView_dataSourceBinding*)binding
                             removeDynamicBindingsForSection:(NSInteger)section
                                                        view:(UIView*)headerOrFooterView
                                                    asHeader:(BOOL)isHeader
                                                 dataContext:(id __unused)dataContext
{
    (void)binding;

    AKATableViewDynamicSectionInfo* sectionInfo =
        [self dynamicSectionInfoForView:headerOrFooterView
                               asHeader:isHeader
                              inSection:section
                    requireMatchingView:YES
                 requireMatchingSection:NO];

    if (sectionInfo)
    {
        AKAControl* sectionInfoControl = sectionInfo.control;

        if (sectionInfoControl)
        {
            [self removeControl:sectionInfoControl];
        }
        [self.dynamicSectionInfos removeObject:sectionInfo];

        // Other sections might change their position as result of this removal. The information in dynamicSectionInfos will be updated in a separate dispatch job to ensure that it's only done once per TV update batch:
        [self dispatchUpdateSectionInfos];
    }
}

/**
   Dispatches a call to performUpdateSectionInfos to the main queue in order to do this once for all changes triggered in the current main queue job.
 */
- (void)                          dispatchUpdateSectionInfos
{
    // TODO: implement analog to rows (don't know how to do that yet)
}

/**
   Iterates through all dynamicSectionInfos to correct section indexes that might have changed during the last tableView update.
 */
- (void)                           performUpdateSectionInfos
{
    // TODO: How to implement that for sections?
}

- (void)                                             binding:(AKABinding_UITableView_dataSourceBinding*)binding
                                addDynamicBindingsForSection:(NSInteger)section
                                                  headerView:(UIView*)headerView
                                                 dataContext:(id)dataContext
{
    [self binding:binding addDynamicBindingsForSection:section view:headerView asHeader:YES dataContext:dataContext];
}

- (void)                                             binding:(AKABinding_UITableView_dataSourceBinding*)binding
                             removeDynamicBindingsForSection:(NSInteger)section
                                                  headerView:(UIView*)headerView
                                                 dataContext:(id)dataContext
{
    [self binding:binding removeDynamicBindingsForSection:section view:headerView asHeader:YES dataContext:dataContext];
}

- (void)                                             binding:(AKABinding_UITableView_dataSourceBinding*)binding
                                addDynamicBindingsForSection:(NSInteger)section
                                                  footerView:(UIView*)footerView
                                                 dataContext:(id)dataContext
{
    [self binding:binding addDynamicBindingsForSection:section view:footerView asHeader:NO dataContext:dataContext];
}

- (void)                                             binding:(AKABinding_UITableView_dataSourceBinding*)binding
                             removeDynamicBindingsForSection:(NSInteger)section
                                                  footerView:(UIView*)footerView
                                                 dataContext:(id)dataContext
{
    [self binding:binding removeDynamicBindingsForSection:section view:footerView asHeader:NO dataContext:dataContext];
}

@end
