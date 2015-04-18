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
    return [NSString stringWithFormat:@"Section %ld Header", section];
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Section %ld Footer", section];
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


@interface AKAMultiplexedTableViewControllerDemoTableViewController ()

@property(nonatomic) ArrayDataSource* additionalDataSource;
@property(nonatomic) id<UITableViewDataSource> originalDataSource;
@property(nonatomic) AKAMultiplexedTableViewDataSource* multiplexedDataSource;

@end

@implementation AKAMultiplexedTableViewControllerDemoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.additionalDataSource =
    [ArrayDataSource dataSourceWithArray:@[ @[ @"A0-0", @"A0-1" ] ] ];

    self.multiplexedDataSource =
    [AKAMultiplexedTableViewDataSource proxyDataSourceAndDelegateInTableView:self.tableView
                                                         andAppendDataSource:self.additionalDataSource
                                                                withDelegate:self.additionalDataSource
                                                                      forKey:@"arrayDS"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@"."];
}

@end
