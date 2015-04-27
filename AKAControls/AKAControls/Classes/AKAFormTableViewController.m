//
//  AKAFormTableViewController.m
//  AKAControls
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAFormTableViewController.h"
#import "AKAEditorControlView.h"
#import <AKAControls/AKATableViewCellCompositeControl.h>
#import <AKACommons/AKATVDataSourceSpecification.h>

@interface AKAFormTableViewController ()

@property(nonatomic, readonly) NSMutableDictionary* hiddenControlCellsInfo;

@end

@implementation AKAFormTableViewController

static NSString* const defaultDataSourceKey = @"default";

- (void)viewDidLoad
{
    [super viewDidLoad];

    _hiddenControlCellsInfo = [NSMutableDictionary new];

    // Initialize formControl with the original tableView/dataSource to capture all static cells
    // containing control views.
    _formControl = [AKAFormControl controlWithDataContext:self configuration:nil];

    // Setup theme name before adding controls for subviews (TODO: order should not matter)
    [self.formControl setThemeName:@"tableview" forClass:[AKAEditorControlView class]];

    // Create controls for control views in tableview cells
    [self.formControl addControlsForControlViewsInStaticTableView:self.tableView
                                                       dataSource:self.tableView.dataSource];

    _multiplexedDataSource =
    [AKATVMultiplexedDataSource proxyDataSourceAndDelegateForKey:defaultDataSourceKey
                                                     inTableView:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.formControl startObservingChanges];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.formControl stopObservingChanges];
    [super viewWillDisappear:animated];
}

#pragma mark - 

- (NSArray*)rowControlsTaggedWith:(NSString*)tag
{
    NSMutableArray* result = [NSMutableArray new];
    [self.formControl enumerateControlsUsingBlock:^(AKAControl *control, NSUInteger index, BOOL *stop) {
        if ([control isKindOfClass:[AKATableViewCellCompositeControl class]])
        {
            if ([control.tags containsObject:tag])
            {
                [result addObject:control];
            }
        }
    }];
    return result;
}

- (void)hideRowControls:(NSArray*)rowControls
       withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    AKATVDataSourceSpecification* dsSpec = [self.multiplexedDataSource dataSourceForKey:@"default"];
    NSArray* sortedByIndexPath = [rowControls sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        AKATableViewCellCompositeControl* cell1 = obj1;
        AKATableViewCellCompositeControl* cell2 = obj2;
        NSIndexPath* i1 = [dsSpec tableViewMappedIndexPath:cell1.indexPath];
        NSIndexPath* i2 = [dsSpec tableViewMappedIndexPath:cell2.indexPath];
        NSComparisonResult result = [i1 compare:i2];
        if (result == NSOrderedAscending)
        {
            result = NSOrderedDescending;
        }
        else if (result == NSOrderedDescending)
        {
            result = NSOrderedAscending;
        }
        return result;
    }];
    [self.multiplexedDataSource beginUpdatesForTableView:self.tableView];
    for (AKATableViewCellCompositeControl* controlCell in sortedByIndexPath)
    {
        NSIndexPath* tableViewIndexPath = [dsSpec tableViewMappedIndexPath:controlCell.indexPath];
        if (tableViewIndexPath)
        {
            [self.multiplexedDataSource removeUpTo:1
                                 rowsFromIndexPath:tableViewIndexPath
                                         tableView:self.tableView
                                            update:YES
                                  withRowAnimation:rowAnimation];
            self.hiddenControlCellsInfo[controlCell.indexPath] = tableViewIndexPath;
        }
    }
    [self.multiplexedDataSource endUpdatesForTableView:self.tableView];
}

- (void)unhideRowControls:(NSArray*)rowControls
         withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSArray* sortedByIndexPath = [rowControls sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        AKATableViewCellCompositeControl* cell1 = obj1;
        AKATableViewCellCompositeControl* cell2 = obj2;
        NSIndexPath* i1 = self.hiddenControlCellsInfo[cell1.indexPath];
        NSIndexPath* i2 = self.hiddenControlCellsInfo[cell2.indexPath];
        NSComparisonResult result = [i1 compare:i2];
        return result;
    }];
    [self.multiplexedDataSource beginUpdatesForTableView:self.tableView];
    for (AKATableViewCellCompositeControl* controlCell in sortedByIndexPath)
    {
        NSIndexPath* tableViewIndexPath = self.hiddenControlCellsInfo[controlCell.indexPath];
        if (tableViewIndexPath)
        {
            [self.multiplexedDataSource insertRowsFromDataSource:@"default"
                                                 sourceIndexPath:controlCell.indexPath
                                                           count:1
                                                     atIndexPath:tableViewIndexPath
                                                       tableView:self.tableView
                                                          update:YES
                                                withRowAnimation:rowAnimation];
            [self.hiddenControlCellsInfo removeObjectForKey:controlCell.indexPath];
        }
    }
    [self.multiplexedDataSource endUpdatesForTableView:self.tableView];
}

@end
