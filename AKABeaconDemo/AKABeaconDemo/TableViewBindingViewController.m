//
//  TableViewBindingViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "TableViewBindingViewController.h"
@import AKABeacon;


@interface TableViewBindingViewController() <UITableViewDelegate, UITableViewDataSource>
@end


@implementation TableViewBindingViewController

#pragma mark - Life Cycle

- (void)                      viewDidLoad
{
    [super viewDidLoad];

    [AKABindingBehavior addToViewController:self];

    _tvTitle = @"Hello";
    _section1Items = @[ @"one", @(2), @"three", @(-5), [NSDate date] ];
    _section2Items = @[ @(1.234), @"two", @(-2.34), [NSDate date] ];
}

#pragma mark - Table View Data Source

// Data source methods are used by the binding as fallback, if the cell mapping defined in the binding expression does not provide a match. In this example, there is no cell mapping for NSDate objects, so we can handle them the traditional way:

- (UITableViewCell *)           tableView:(UITableView *)tableView
                    cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:@"default"];
    id item = nil;
    switch (indexPath.section)
    {
        case 0:
            item = self.section1Items[indexPath.row];
            break;
        case 1:
            item = self.section2Items[indexPath.row];
            break;
        default:
            break;
    }
    cell.textLabel.text = [item description];
    cell.detailTextLabel.text = @"Default cell not managed by bindings";
    return cell;
}

// Other required data source methods are never called by the binding, but they may be called if the binding is not observing changes (this typically is the case before viewWillAppear and after viewDidDisappear, when these life cycle events are used to manage bindings (directly or via AKAFormControl instances).

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)                   tableView:(UITableView *)tableView
                    numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - Table View Delegate

// These delegate methods are used to demonstrate that even though the binding takes over the role of delegate and data source for the table view, delegate methods defined here will still be called (the original table view delegate is proxied by the binding):

- (void)                        tableView:(UITableView *)tableView
                          willDisplayCell:(UITableViewCell *)cell
                        forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Will display cell %@", indexPath);
}

- (void)                        tableView:(UITableView *)tableView
                     didEndDisplayingCell:(UITableViewCell *)cell
                        forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Did end display cell %@", indexPath);
}

@end
