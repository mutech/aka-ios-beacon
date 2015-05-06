//
//  AKATVDataSource.h
//  AKACommons
//
//  Created by Michael Utech on 22.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKATVCoordinateMappingProtocol.h"

@class AKATVMultiplexedDataSource;
@class AKAObservableCollection;

#pragma mark - AKATVDataSource
#pragma mark -

@interface AKATVDataSourceSpecification: NSObject<AKATVCoordinateMappingProtocol>

+ (AKATVDataSourceSpecification*)dataSource:(id<UITableViewDataSource>)dataSource
                               withDelegate:(id<UITableViewDelegate>) delegate
                                     forKey:(NSString*)key
                              inMultiplexer:(AKATVMultiplexedDataSource*)multiplexer;

@property(nonatomic, readonly) NSString* key;
@property(nonatomic, weak, readonly) id<UITableViewDataSource> dataSource;
@property(nonatomic, weak, readonly) id<UITableViewDelegate> delegate;
@property(nonatomic, weak, readonly) AKATVMultiplexedDataSource* multiplexer;

- (UITableView*)proxyForTableView:(UITableView*)tableView;

@end
