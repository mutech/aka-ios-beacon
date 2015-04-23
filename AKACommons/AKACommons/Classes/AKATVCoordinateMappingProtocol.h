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

- (NSIndexPath*)mappedIndexPath:(NSIndexPath*)indexPath;

- (NSIndexPath*)reverseMappedIndexPath:(NSIndexPath*)indexPath;

- (NSArray*)mappedIndexPaths:(NSArray*)indexPaths;

- (NSArray*)reverseMappedIndexPaths:(NSArray*)indexPaths;

- (NSInteger)mappedSection:(NSInteger)section;

- (NSInteger)reverseMappedSection:(NSInteger)section;

- (NSIndexSet*)mappedSectionIndexSet:(NSIndexSet*)sections;

- (NSIndexSet*)reverseMappedSectionIndexSet:(NSIndexSet*)sections;

- (NSArray*)filteredCells:(NSArray*)cells;

@end

