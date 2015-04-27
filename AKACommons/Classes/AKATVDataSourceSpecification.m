//
//  AKATVDataSource.m
//  AKACommons
//
//  Created by Michael Utech on 22.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATVDataSourceSpecification.h"
#import "AKATVCoordinateMappingProtocol.h"
#import "AKATVMultiplexedDataSource.h"
#import "AKATVProxy.h"
#import "AKAErrors.h"

#pragma mark - AKATVDataSource
#pragma mark -

@interface AKATVDataSourceSpecification()

@property(nonatomic) NSMutableDictionary* tableViewProxies;

@end

@implementation AKATVDataSourceSpecification

+ (instancetype)dataSource:(id<UITableViewDataSource>)dataSource
              withDelegate:(id<UITableViewDelegate>)delegate
                    forKey:(NSString*)key
             inMultiplexer:(AKATVMultiplexedDataSource*)multiplexer
{
    return [[AKATVDataSourceSpecification alloc] initWithDataSource:dataSource
                                              delegate:delegate
                                                forKey:key
                                         inMultiplexer:multiplexer];
}

- (instancetype)initWithDataSource:(id<UITableViewDataSource>)dataSource
                          delegate:(id<UITableViewDelegate>)delegate
                            forKey:(NSString*)key
                     inMultiplexer:(AKATVMultiplexedDataSource*)multiplexer
{
    if (self = [self init])
    {
        //_tableViewProxies = [NSMutableDictionary new];
        _dataSource = dataSource;
        _delegate = delegate;
        _key = key;
        _multiplexer = multiplexer;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    (void)keyPath;
    (void)object;
    (void)change;
    (void)context;
    // TODO: implement change tracking for collections
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - Table View Proxy

- (UITableView *)proxyForTableView:(UITableView *)tableView
{
    //NSValue* key = [NSValue valueWithNonretainedObject:tableView];
    UITableView* result = nil; //self.tableViewProxies[key];
    if (result == nil)
    {
        result = (UITableView*)[[AKATVProxy alloc] initWithTableView:tableView
                                                                 dataSource:self];
        //self.tableViewProxies[key] = result;
    }
    return result;
}

#pragma mark - Coordinate Mapping

#pragma mark Sections

- (NSInteger)dataSourceSection:(NSInteger)section
{
    AKATVMultiplexedDataSource* mds = self.multiplexer;
    NSInteger resolvedSection = NSNotFound;
    [mds resolveAKADataSource:nil
         sourceSectionIndex:&resolvedSection
            forSectionIndex:section];
    return resolvedSection;
}

- (NSIndexSet *)dataSourceSectionIndexSet:(NSIndexSet *)sections
{
    NSMutableIndexSet* result = [NSMutableIndexSet new];
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        (void)stop;
        NSInteger resolvedSection = [self dataSourceSection:(NSInteger)idx];
        if (resolvedSection != NSNotFound)
        {
            [result addIndex:(NSUInteger)resolvedSection];
        }
    }];
    return result;
}

- (NSInteger)tableViewSection:(NSInteger)section
{
    AKATVMultiplexedDataSource* mds = self.multiplexer;
    NSInteger resolvedSection = NSNotFound;
    [mds resolveSection:&resolvedSection
       forSourceSection:section
           inDataSource:self];
    return resolvedSection;
}

- (NSIndexSet *)tableViewSectionIndexSet:(NSIndexSet *)sections
{
    NSMutableIndexSet* result = [NSMutableIndexSet new];
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        (void)stop;
        NSInteger resolvedSection = [self tableViewSection:(NSInteger)idx];
        if (resolvedSection != NSNotFound)
        {
            [result addIndex:(NSUInteger)resolvedSection];
        }
    }];
    return result;
}

#pragma mark Index Paths

- (NSIndexPath *)dataSourceIndexPath:(NSIndexPath *)indexPath
{
    AKATVMultiplexedDataSource* mds = self.multiplexer;
    NSIndexPath* resolvedIndexPath = nil;
    [mds resolveAKADataSource:nil
           sourceIndexPath:&resolvedIndexPath
              forIndexPath:indexPath];
    return resolvedIndexPath;
}

- (NSArray *)dataSourceIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray* result = [NSMutableArray new];
    [indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        (void)idx;
        (void)stop;
        NSIndexPath* resolvedIndexPath = [self dataSourceIndexPath:obj];
        if (resolvedIndexPath != nil)
        {
            [result addObject:resolvedIndexPath];
        }
    }];
    return result;
}

- (NSIndexPath *)tableViewMappedIndexPath:(NSIndexPath *)indexPath
{
    AKATVMultiplexedDataSource* mds = self.multiplexer;
    NSIndexPath* resolvedIndexPath = nil;
    [mds resolveIndexPath:&resolvedIndexPath
       forSourceIndexPath:indexPath
             inDataSource:self];
    return resolvedIndexPath;
}

- (NSArray *)tableViewMappedIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray* result = [NSMutableArray new];
    [indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        (void)idx;
        (void)stop;
        NSIndexPath* resolvedIndexPath = [self tableViewMappedIndexPath:obj];
        if (resolvedIndexPath != nil)
        {
            [result addObject:resolvedIndexPath];
        }
    }];
    return result;
}

- (NSArray *)filteredCells:(NSArray *)cells
{
    (void)cells;
    // TODO: implement
    AKAErrorMethodNotImplemented();
}
@end


