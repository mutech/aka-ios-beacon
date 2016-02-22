//
//  AKATableViewDataSourceAndDelegateDispatcher.h
//  AKABeacon
//
//  Created by Michael Utech on 21.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKADelegateDispatcher.h"


#pragma mark - AKATableViewDataSourceAndDelegateDispatcher Interface
#pragma mark -

@interface AKATableViewDataSourceAndDelegateDispatcher: AKADelegateDispatcher<UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableView:(UITableView*)tableView
             dataSourceOverwrites:(id<UITableViewDataSource>)dataSource
               delegateOverwrites:(id<UITableViewDelegate>)delegate;
- (void)restoreOriginalDataSourceAndDelegate;

@property(nonatomic, readonly, weak) UITableView*              tableView;
@property(nonatomic, readonly, weak) id<UITableViewDataSource> originalDataSource;
@property(nonatomic, readonly, weak) id<UITableViewDelegate>   originalDelegate;

@end
