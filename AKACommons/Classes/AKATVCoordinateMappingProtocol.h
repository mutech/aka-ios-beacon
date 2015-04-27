//
//  AKATVCoordinateMappingProtocol.h
//  AKACommons
//
//  Created by Michael Utech on 22.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - AKATVCoordinateMappingProtocol
#pragma mark -

@protocol AKATVCoordinateMappingProtocol <NSObject>

- (NSIndexPath*)dataSourceIndexPath:(NSIndexPath*)indexPath;

- (NSIndexPath*)tableViewMappedIndexPath:(NSIndexPath*)indexPath;

- (NSArray*)dataSourceIndexPaths:(NSArray*)indexPaths;

- (NSArray*)tableViewMappedIndexPaths:(NSArray*)indexPaths;

- (NSInteger)dataSourceSection:(NSInteger)section;

- (NSInteger)tableViewSection:(NSInteger)section;

- (NSIndexSet*)dataSourceSectionIndexSet:(NSIndexSet*)sections;

- (NSIndexSet*)tableViewSectionIndexSet:(NSIndexSet*)sections;

- (NSArray*)filteredCells:(NSArray*)cells;

@end

