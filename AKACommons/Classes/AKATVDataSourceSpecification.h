//
//  AKATVDataSource.h
//  AKACommons
//
//  Created by Michael Utech on 22.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKATVCoordinateMappingProtocol.h"

@class AKATVMultiplexedDataSource;
@class AKAObservableCollection;
@class AKATVDataSourceSpecification;

#pragma mark - AKATVDataSourceSpecificationDelegate
#pragma mark -

@protocol AKATVDataSourceSpecificationDelegate <NSObject>

- (BOOL)resolveIndexPath:(out NSIndexPath*__strong __nullable* __nullable)indexPathStorage
      forSourceIndexPath:(NSIndexPath* __nonnull)sourceIndexPath
            inDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource;

- (BOOL)resolveSection:(out NSInteger* __nullable)sectionStorage
      forSourceSection:(NSInteger)sourceSection
          inDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource;

- (BOOL)resolveAKADataSource:(out AKATVDataSourceSpecification*__autoreleasing __nullable* __nullable)dataSourceStorage
             sourceIndexPath:(out NSIndexPath*__autoreleasing __nullable* __nullable)indexPathStorage
                forIndexPath:(NSIndexPath* __nonnull)indexPath;

- (BOOL)resolveAKADataSource:(out AKATVDataSourceSpecification*__autoreleasing __nullable* __nullable)dataSourceStorage
          sourceSectionIndex:(out NSInteger* __nullable)sectionIndexStorage
             forSectionIndex:(NSInteger)sectionIndex;

@end

#pragma mark - AKATVDataSourceSpecification
#pragma mark -

@interface AKATVDataSourceSpecification: NSObject<AKATVCoordinateMappingProtocol>

+ (AKATVDataSourceSpecification* __nonnull)dataSource:(id<UITableViewDataSource> __nonnull)dataSource
                                         withDelegate:(id<UITableViewDelegate> __nullable) delegate
                                               forKey:(NSString* __nonnull)key
                                        inMultiplexer:(AKATVMultiplexedDataSource* __nullable)multiplexer;

@property(nonatomic, readonly, nonnull) NSString* key;
@property(nonatomic, weak, readonly, nullable) id<UITableViewDataSource> dataSource;
@property(nonatomic, weak, readonly, nullable) id<UITableViewDelegate> delegate;
@property(nonatomic, weak, readonly, nullable) NSObject<AKATVDataSourceSpecificationDelegate>* multiplexer;

- (UITableView* __nonnull)proxyForTableView:(UITableView* __nonnull)tableView;

- (NSIndexPath *_Nullable)tableViewMappedIndexPath:(NSIndexPath *_Nonnull)indexPath;

@end
