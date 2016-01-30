//
//  AKAArrayComparerTests.m
//  AKACommons
//
//  Created by Michael Utech on 29.01.16.
//  Copyright © 2016 AKA Sarl. All rights reserved.
//

@import XCTest;
#import "AKAArrayComparer.h"

@interface AKAArrayComparerTests : XCTestCase

@end

@implementation AKAArrayComparerTests

- (void)testReplay
{
    NSArray* old = @[ @"A", @"B", @"B2", @"B3", @"C", @"D", @"E", @"F", @"G" ];
    //             @[ @"A", @"B", @"C", @"E", @"F", @"G" ]; // old w/ deletions
    //             @[ @"C", @"B", @"A", @"F", @"G", @"E" ]; // new w/o insertions
    NSArray* new = @[ @"C", @"B", @"B2", @"B3", @"X", @"A", @"F", @"Y", @"G", @"E" ];

    AKAArrayComparer* comparer = [[AKAArrayComparer alloc] initWithOldArray:old newArray:new];

    XCTAssert(comparer.deletedItemIndexes.count == 1);
    XCTAssert(comparer.deletedItemIndexes.firstIndex == 5);

    XCTAssert(comparer.insertedItemIndexes.count == 2);
    XCTAssert(comparer.insertedItemIndexes.firstIndex == 4);
    XCTAssert([comparer.insertedItemIndexes lastIndex] == 7);

    NSMutableArray* replay = [NSMutableArray arrayWithArray:old];
    [replay removeObjectsAtIndexes:comparer.deletedItemIndexes];

    for (NSUInteger i=0; i < replay.count; ++i)
    {
        NSInteger offset = comparer.permutationAfterDeletionsAndBeforeInsertions[i].integerValue;
        if (offset != 0)
        {
            XCTAssert(offset > 0, @"Invalid negative offset %lu", (NSUInteger)offset);
            NSUInteger sourceIndex = i + (NSUInteger)offset;
            id item = replay[sourceIndex];
            [replay removeObjectAtIndex:sourceIndex];
            [replay insertObject:item atIndex:i];
        }
    }

    [comparer.insertedItemIndexes enumerateIndexesUsingBlock:
     ^(NSUInteger idx, BOOL * _Nonnull stop)
     {
         (void)stop;
         id item = new[idx];
         [replay insertObject:item atIndex:idx];
     }];

    XCTAssert([replay isEqualToArray:new], @"Reapplying changes failed");
}

@end
