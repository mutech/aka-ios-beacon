//
//  AKAMultiplexedTableViewDataSource.h
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAMultiplexedTableViewDataSourceBase.h"

@class AKAReference;

@interface AKAMultiplexedTableViewDataSource : AKAMultiplexedTableViewDataSourceBase

#pragma mark - Batch Table View Updates

- (void)beginUpdatesForTableView:(UITableView*)tableView;

- (void)endUpdatesForTableView:(UITableView*)tableView;

@end
