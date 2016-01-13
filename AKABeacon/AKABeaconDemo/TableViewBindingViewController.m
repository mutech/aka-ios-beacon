//
//  TableViewBindingViewController.m
//  AKABeaconDemo
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "TableViewBindingViewController.h"

@interface TableViewBindingViewController() <UITableViewDelegate>

@property(nonatomic) NSArray* section1Items;
@property(nonatomic) NSArray* section2Items;

@end


@implementation TableViewBindingViewController

- (void)viewDidLoad
{
    _section1Items = @[ @"one", @(2), @"three" ];
    _section2Items = @[ @(1.234), @"two", @(3) ];

    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Will display cell %@", indexPath);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Did end display cell %@", indexPath);
}

@end
