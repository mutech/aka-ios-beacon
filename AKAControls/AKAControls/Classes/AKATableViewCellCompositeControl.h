//
//  AKATableViewCellCompositeControl.h
//  AKABeacon
//
//  Created by Michael Utech on 26.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKACompositeControl.h"


@interface AKATableViewCellCompositeControl : AKACompositeControl

@property(nonatomic, weak) UITableView*                 tableView;
@property(nonatomic, weak) id<UITableViewDataSource>    dataSource;
@property(nonatomic) NSIndexPath*                       indexPath;

@end
