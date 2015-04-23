//
//  AKAMultiplexedTableViewControllerDemoTableViewController.m
//  AKAControlsDemo
//
//  Created by Michael Utech on 16.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAMultiplexedTableViewControllerDemoTableViewController.h"

#import <AKACommons/AKAMultiplexedTableViewDataSource.h>

@interface ArrayDataSource: NSObject<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic) NSArray* data;

@end

@implementation ArrayDataSource
+ (instancetype)dataSourceWithArray:(NSArray*)arrayOfArrayOfRows
{
    ArrayDataSource* result = ArrayDataSource.new;
    result.data = arrayOfArrayOfRows;
    return result;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    (void)tableView;
    return (NSInteger)self.data.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    (void)tableView;
    NSArray* rows = self.data[(NSUInteger)section];
    return (NSInteger)rows.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    (void)tableView;
    NSArray* rows = self.data[(NSUInteger)indexPath.section];
    id row = rows[(NSUInteger)indexPath.row];
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"notused"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", row];
    cell.detailTextLabel.text = @"-";
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Dynamic Section %ld Header", section];
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Dynamic Section %ld Footer", section];
}
#pragma mark - UITAbleViewDelegate Implementation
- (CGFloat)tableView:tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return UITableViewAutomaticDimension;
}
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = @(++(cell.tag)).description;
}
@end

@interface MultiplexDataSource: AKAMultiplexedTableViewDataSource

@property(nonatomic) ArrayDataSource* additionalDataSource;
@property(nonatomic) id<UITableViewDataSource> originalDataSource;
@property(nonatomic) id<UITableViewDelegate> originalDelegate;

@end

@implementation MultiplexDataSource
+ (MultiplexDataSource*)proxyTableView:(UITableView*)tableView
{
    id<UITableViewDataSource> ods = tableView.dataSource;
    id<UITableViewDelegate> od = tableView.delegate;

    ArrayDataSource* arrayDS =
    [ArrayDataSource dataSourceWithArray:@[ @[ @"A0-0", @"A0-1" ] ] ];

    MultiplexDataSource* result =
    [MultiplexDataSource proxyDataSourceAndDelegateForKey:@"default"
                                              inTableView:tableView
                                      andAppendDataSource:arrayDS
                                             withDelegate:arrayDS
                                                   forKey:@"arrayDS"];
    result.originalDelegate = od;
    result.originalDataSource = ods;
    result.additionalDataSource = arrayDS;

    return result;
}
@end

@interface AKAMultiplexedTableViewControllerDemoTableViewController ()

@property(nonatomic) MultiplexDataSource* multiplexedDataSource;

@property(nonatomic)BOOL alternative1Active;

@end

@implementation AKAMultiplexedTableViewControllerDemoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.multiplexedDataSource = [MultiplexDataSource proxyTableView:self.tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@"."];
}

- (IBAction)firstStaticCellTapAction:(id)sender
{
    AKAMultiplexedTableViewDataSource* mds = self.multiplexedDataSource;
    NSIndexPath* indexPath_0_1 = [NSIndexPath indexPathForRow:1 inSection:0];

    NSInteger rowsInSection0 = [mds tableView:self.tableView numberOfRowsInSection:0];
    if (rowsInSection0 == 3)
    {
        [mds removeUpTo:2
      rowsFromIndexPath:indexPath_0_1
              tableView:self.tableView
                 update:YES
       withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (rowsInSection0 == 1)
    {
        [mds insertRowsFromDataSource:@"default"
                      sourceIndexPath:indexPath_0_1
                                count:2
                          atIndexPath:indexPath_0_1
                            tableView:self.tableView
                               update:YES
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (rowsInSection0 == 4)
    {
        [self secondStaticCellTapAction:sender];
        [self firstStaticCellTapAction:sender];
    }
}

- (IBAction)secondStaticCellTapAction:(id)sender
{
    AKAMultiplexedTableViewDataSource* mds = self.multiplexedDataSource;

    self.alternative1Active = !self.alternative1Active;

    if (self.alternative1Active)
    {
        [mds beginUpdatesForTableView:self.tableView];

        [mds        removeUpTo:1
             rowsFromIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                     tableView:self.tableView];

        [mds moveRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                    toIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                  tableView:self.tableView
                     update:YES];


        [mds endUpdatesForTableView:self.tableView];
    }
    else
    {
        [mds beginUpdatesForTableView:self.tableView];

        [mds insertRowsFromDataSource:@"default"
                      sourceIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                count:1
                          atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                            tableView:self.tableView];

        [mds moveRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
                    toIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                      tableView:self.tableView
                         update:YES];

        [mds endUpdatesForTableView:self.tableView];
    }
}

@end
