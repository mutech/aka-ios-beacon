//
//  AKATableViewProxy.h
//  AKACommons
//
//  Created by Michael Utech on 22.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKATVDataSourceSpecification;

@interface AKATVProxy : NSProxy

#pragma mark - Initialization

- (instancetype)initWithTableView:(UITableView*)tableView
                       dataSource:(AKATVDataSourceSpecification*)dataSource;

@end