//
//  AKATVDataSource.h
//  AKACommons
//
//  Created by Michael Utech on 22.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKATVCoordinateMappingProtocol.h"

@class AKAMultiplexedTableViewDataSourceBase;

#pragma mark - AKATVDataSource
#pragma mark -

@interface AKATVDataSource: NSObject<AKATVCoordinateMappingProtocol>

+ (AKATVDataSource*)dataSource:(id<UITableViewDataSource>)dataSource
              withDelegate:(id<UITableViewDelegate>) delegate
                    forKey:(NSString*)key
             inMultiplexer:(AKAMultiplexedTableViewDataSourceBase*)multiplexer;

@property(nonatomic, readonly) NSString* key;
@property(nonatomic, weak, readonly) id<UITableViewDataSource> dataSource;
@property(nonatomic, weak, readonly) id<UITableViewDelegate> delegate;
@property(nonatomic, weak, readonly) AKAMultiplexedTableViewDataSourceBase* multiplexer;

- (UITableView*)proxyForTableView:(UITableView*)tableView;

@end


