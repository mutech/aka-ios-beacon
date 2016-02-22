//
//  AKATableViewDataSourceAndDelegateDispatcher.m
//  AKABeacon
//
//  Created by Michael Utech on 21.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATableViewDataSourceAndDelegateDispatcher.h"


#pragma mark - AKATableViewDataSourceAndDelegateDispatcher Implementation
#pragma mark -

// Ignore warning about missing protocol implementations, these are provided dynamically
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation AKATableViewDataSourceAndDelegateDispatcher

- (instancetype)initWithTableView:(UITableView*)tableView
             dataSourceOverwrites:(id<UITableViewDataSource>)dataSource
               delegateOverwrites:(id<UITableViewDelegate>)delegate
{
    static NSArray<Protocol*>* protocols;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        protocols = @[ @protocol(UITableViewDataSource),
                       @protocol(UITableViewDelegate) ];
    });

    id<UITableViewDataSource> tableViewDataSource = tableView.dataSource;
    id<UITableViewDelegate>   tableViewDelegate = tableView.delegate;
    NSMutableArray* delegates = [NSMutableArray new];

    if (dataSource)
    {
        [delegates addObject:dataSource];
    }

    if (delegate && (id)delegate != (id)dataSource)
    {
        [delegates addObject:delegate];
    }

    if (tableViewDataSource)
    {
        [delegates addObject:tableViewDataSource];
    }

    if (tableViewDelegate && (id)tableViewDelegate != (id)tableViewDataSource)
    {
        [delegates addObject:tableViewDelegate];
    }

    if (self = [super initWithProtocols:protocols
                              delegates:delegates])
    {
        _tableView = tableView;
        tableView.dataSource = self;
        tableView.delegate = self;
        _originalDataSource = tableViewDataSource;
        _originalDelegate = tableViewDelegate;
    }

    return self;
}

- (void)dealloc
{
    [self restoreOriginalDataSourceAndDelegate];
}

- (void)restoreOriginalDataSourceAndDelegate
{
    UITableView* tableView = self.tableView;

    if (tableView)
    {
        tableView.dataSource = self.originalDataSource;
        tableView.delegate = self.originalDelegate;
        _originalDataSource = nil;
        _originalDelegate = nil;
        _tableView = nil;
    }
}

@end
#pragma clang diagnostic pop

