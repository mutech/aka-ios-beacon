//
//  AKATableViewCellCompositeControl.h
//  AKABeacon
//
//  Created by Michael Utech on 26.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKACompositeControl.h"

@class AKAFormTableViewController;

@interface AKATableViewCellCompositeControl : AKACompositeControl

@property(nonatomic, weak) UITableView*                 tableView;
@property(nonatomic, weak) id<UITableViewDataSource>    dataSource;
@property(nonatomic) NSIndexPath*                       indexPath;

// TODO: hack, need a way to reach this in order to exclude cell from table view for excludeBinding
@property(nonatomic, weak) AKAFormTableViewController*  tableViewController;

@end
