//
//  DynamicPlaceholderCellTableViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 20.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import UIKit;

@import AKACommons.AKALog;
@import AKABeacon.AKAControl;

#import "DynamicPlaceholderCellTableViewController.h"

@interface DynamicPlaceholderCellTableViewController ()

@property(nonatomic) NSArray* itemsForDynamicCells;

@end

@implementation DynamicPlaceholderCellTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View Model

@synthesize itemsForDynamicCells = _itemsForDynamicCells;
- (NSArray *)itemsForDynamicCells
{
    if (_itemsForDynamicCells == nil)
    {
        _itemsForDynamicCells =
        @[ @{ @"title": @"one",
              @"value": @1 },
           @{ @"title": @"two",
              @"value":  @2 },
           @{ @"title": @"three",
              @"value":  @3 },
           @{ @"title": @"four",
              @"value":  @4 },
           @{ @"title": @"five",
              @"value":  @5 },
           @{ @"title": @"six",
              @"value":  @6 },
           @{ @"title": @"seven",
              @"value":  @7 },
           @{ @"title": @"eight",
              @"value":  @8 },
           @{ @"title": @"nine",
              @"value":  @9 },
           @{ @"title": @"ten",
              @"value":  @10 }
           ];
    }
    return _itemsForDynamicCells;
}

- (void)setItemsForDynamicCells:(NSArray *)itemsForDynamicCells
{
    _itemsForDynamicCells = itemsForDynamicCells;
}

#pragma mark - Tableview Delegate

#pragma mark - UITableViewDelegate Implementation

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Override static table view controller implementation for dynamic row height
    (void)tableView;
    (void)indexPath;

    return 44.0;
}

- (CGFloat)             tableView:tableView
          heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Override static table view controller implementation for dynamic row height
    (void)tableView;
    (void)indexPath;

    return UITableViewAutomaticDimension;
}

- (CGFloat)             tableView:(UITableView *)tableView
         heightForHeaderInSection:(NSInteger)section
{
    // Override static table view controller implementation for dynamic row height
    (void)tableView;
    (void)section;

    return UITableViewAutomaticDimension;
}

- (CGFloat)             tableView:(UITableView *)tableView
         heightForFooterInSection:(NSInteger)section
{
    // Override static table view controller implementation for dynamic row height
    (void)tableView;
    (void)section;

    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // [super respondsToSelector:] does not work, good explanation here:
    // http://www.cocoabuilder.com/archive/cocoa/208788-super-respondstoselector.html
    if ([[self.class superclass] instancesRespondToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }

    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    AKAControl* control = cell.aka_boundControl;

    id data = control.dataContext;
    NSUInteger index = [self.itemsForDynamicCells indexOfObject:data];
    if (index != NSNotFound)
    {
        NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.itemsForDynamicCells];
        [newItems removeObjectAtIndex:index];
        self.itemsForDynamicCells = newItems;
    }

    AKALogVerbose(@"row %ld in section %ld selected: %@", (long)indexPath.row, (long)indexPath.section, cell);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
