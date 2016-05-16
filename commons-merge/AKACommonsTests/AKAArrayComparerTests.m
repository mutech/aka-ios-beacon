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
            XCTAssert(offset > 0, @"Invalid negative offset %lu", (unsigned long)offset);
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

- (void)testApplyChangesToTransformedArray
{
    id (^transformItem)(id item, NSUInteger index) = ^id(id item, NSUInteger index) {
        NSString* result = [NSString stringWithFormat:@"%@@%@", item, @(index)];
        return result;
    };
    NSMutableArray* (^transformArray)(NSArray* items) = ^NSMutableArray*(NSArray* items) {
        NSMutableArray* result = [NSMutableArray new];
        NSUInteger i=0;
        for (id item in items) {
            [result addObject:transformItem(item , i++)];
        }
        return result;
    };

    AKAArrayComparer* comparer = [[AKAArrayComparer alloc] initWithOldArray:@[ @0, @1, @2 ]
                                                                   newArray:@[ @2, @1, @3 ]];
    NSMutableArray* transformedItems = transformArray(comparer.oldArray);

    [comparer applyChangesToTransformedArray:transformedItems
                     blockBeforeDeletingItem:^(id  _Nonnull deletedItem) {
                         XCTAssertEqualObjects(transformItem(@0ul, 0),deletedItem);
                     } blockMappingMovedItem:^id _Nonnull(id  _Nonnull sourceItem, id  _Nonnull transformedItem, NSUInteger oldIndex, NSUInteger newIndex) {
                         XCTAssertEqual(oldIndex, 2ul);
                         XCTAssertEqual(newIndex, 0ul);
                         XCTAssertEqualObjects(transformItem(@2, 2), transformedItem);
                         return transformItem(sourceItem, 0);
                     } blockMappingInsertedItem:^id _Nonnull(id  _Nonnull newSourceItem, NSUInteger index) {
                         XCTAssertEqualObjects(newSourceItem, @3);
                         XCTAssertEqual(index, 2ul);
                         return transformItem(newSourceItem, index);
                     }];
    XCTAssertEqualObjects(@"2@0", transformedItems[0]);
    XCTAssertEqualObjects(@"1@1", transformedItems[1]);
    XCTAssertEqualObjects(@"3@2", transformedItems[2]);
}

@end
