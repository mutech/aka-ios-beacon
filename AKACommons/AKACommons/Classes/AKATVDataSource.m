//
//  AKATVDataSource.m
//  AKACommons
//
//  Created by Michael Utech on 22.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATVDataSource.h"
#import "AKATVCoordinateMappingProtocol.h"
#import "AKAMultiplexedTableViewDataSourceBase.h"
#import "AKATableViewProxy.h"
#import "AKAErrors.h"

#pragma mark - AKATVDataSource
#pragma mark -

@interface AKATVDataSource()

@property(nonatomic) NSMutableDictionary* tableViewProxies;

@end

@implementation AKATVDataSource

+ (instancetype)dataSource:(id<UITableViewDataSource>)dataSource
              withDelegate:(id<UITableViewDelegate>)delegate
                    forKey:(NSString*)key
             inMultiplexer:(AKAMultiplexedTableViewDataSourceBase*)multiplexer
{
    return [[AKATVDataSource alloc] initWithDataSource:dataSource
                                              delegate:delegate
                                                forKey:key
                                         inMultiplexer:multiplexer];
}

- (instancetype)initWithDataSource:(id<UITableViewDataSource>)dataSource
                          delegate:(id<UITableViewDelegate>)delegate
                            forKey:(NSString*)key
                     inMultiplexer:(AKAMultiplexedTableViewDataSourceBase*)multiplexer
{
    if (self = [self init])
    {
        _tableViewProxies = [NSMutableDictionary new];
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
    NSValue* key = [NSValue valueWithNonretainedObject:tableView];
    UITableView* result = self.tableViewProxies[key];
    if (result == nil)
    {
        result = (UITableView*)[[AKATableViewProxy alloc] initWithTableView:tableView
                                                                 dataSource:self];
        self.tableViewProxies[key] = result;
    }
    return result;
}

#pragma mark - Coordinate Mapping

#pragma mark Sections

- (NSInteger)mappedSection:(NSInteger)section
{
    AKAMultiplexedTableViewDataSourceBase* mds = self.multiplexer;
    NSInteger resolvedSection = NSNotFound;
    [mds resolveDataSource:nil
                   delegate:nil
         sourceSectionIndex:&resolvedSection
            forSectionIndex:section];
    return resolvedSection;
}

- (NSIndexSet *)mappedSectionIndexSet:(NSIndexSet *)sections
{
    NSMutableIndexSet* result = [NSMutableIndexSet new];
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        (void)stop;
        NSInteger resolvedSection = [self mappedSection:(NSInteger)idx];
        if (resolvedSection != NSNotFound)
        {
            [result addIndex:(NSUInteger)resolvedSection];
        }
    }];
    return result;
}

- (NSInteger)reverseMappedSection:(NSInteger)section
{
    (void)section;
    // TODO: implement
    AKAErrorMethodNotImplemented();
}

- (NSIndexSet *)reverseMappedSectionIndexSet:(NSIndexSet *)sections
{
    NSMutableIndexSet* result = [NSMutableIndexSet new];
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        (void)stop;
        NSInteger resolvedSection = [self reverseMappedSection:(NSInteger)idx];
        if (resolvedSection != NSNotFound)
        {
            [result addIndex:(NSUInteger)resolvedSection];
        }
    }];
    return result;
}

#pragma mark Index Paths

- (NSIndexPath *)mappedIndexPath:(NSIndexPath *)indexPath
{
    AKAMultiplexedTableViewDataSourceBase* mds = self.multiplexer;
    NSIndexPath* resolvedIndexPath = nil;
    [mds resolveDataSource:nil
                  delegate:nil
           sourceIndexPath:&resolvedIndexPath
              forIndexPath:indexPath];
    return resolvedIndexPath;
}

- (NSArray *)mappedIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray* result = [NSMutableArray new];
    [indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        (void)idx;
        (void)stop;
        NSIndexPath* resolvedIndexPath = [self mappedIndexPath:obj];
        if (resolvedIndexPath != nil)
        {
            [result addObject:resolvedIndexPath];
        }
    }];
    return result;
}

- (NSIndexPath *)reverseMappedIndexPath:(NSIndexPath *)indexPath
{
    (void)indexPath;
    // TODO: implement
    AKAErrorMethodNotImplemented();
}

- (NSArray *)reverseMappedIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray* result = [NSMutableArray new];
    [indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        (void)idx;
        (void)stop;
        NSIndexPath* resolvedIndexPath = [self reverseMappedIndexPath:obj];
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


