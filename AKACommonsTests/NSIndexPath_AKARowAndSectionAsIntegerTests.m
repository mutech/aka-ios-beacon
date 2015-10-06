//
//  NSIndexPath_AKARowAndSectionAsIntegerTests.m
//  AKACommons
//
//  Created by Michael Utech on 15.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

//#import "NSIndexPath+AKARowAndSectionAsInteger.h"
@import AKACommons;

@interface NSIndexPath_AKARowAndSectionAsIntegerTests : XCTestCase

@end

@implementation NSIndexPath_AKARowAndSectionAsIntegerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEncodeDecodeCycleForValuesIn32BitRange
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1000000 inSection:1234];
    NSUInteger encoded = indexPath.aka_unsignedIntegerValue;
    NSIndexPath* decoded = [NSIndexPath aka_indexPathFromUnsignedIntegerValue:encoded];

    XCTAssertEqual(indexPath.section, decoded.section);
    XCTAssertEqual(indexPath.row, decoded.row);

#ifdef __LP64__
    XCTAssertEqual((NSUInteger)indexPath.section, encoded >> 32);
    XCTAssertEqual((NSUInteger)indexPath.row, encoded & 0xffffffff);
#else
    XCTAssertEqual(indexPath.section, (int)(encoded >> 20));
    XCTAssertEqual(indexPath.row, (int)(encoded & 0xfffff));
#endif
}

- (void)testEncodeDecodeCycleForNSNotFoundValues
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:NSNotFound
                                                inSection:NSNotFound];
    NSUInteger encoded = indexPath.aka_unsignedIntegerValue;
    NSIndexPath* decoded = [NSIndexPath aka_indexPathFromUnsignedIntegerValue:encoded];

    XCTAssertEqual(indexPath.section, decoded.section);
    XCTAssertEqual(indexPath.row, decoded.row);

#ifdef __LP64__
    XCTAssertEqual(0xffffffffffffffff, encoded);
#else
    XCTAssertEqual(0xffffffff, encoded);
#endif
}

- (void)testEncodeDecodeCycleForValuesIn64BitRange
{
    NSException* caught = nil;

    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:10000000 inSection:12340];
    NSUInteger encoded = NSNotFound;
    NSIndexPath* decoded = nil;

    @try {
        encoded = indexPath.aka_unsignedIntegerValue;
        decoded = [NSIndexPath aka_indexPathFromUnsignedIntegerValue:encoded];
    }
    @catch (NSException *exception) {
        caught = exception;
    }
#ifdef __LP64__
    XCTAssertEqual(indexPath.section, decoded.section);
    XCTAssertEqual(indexPath.row, decoded.row);
#else
    XCTAssertNotEqual(indexPath.section, decoded.section);
    XCTAssertNotEqual(indexPath.row, decoded.row);
    XCTAssertNotNil(caught);
#endif

#ifdef __LP64__
    XCTAssertEqual((NSUInteger)indexPath.section, encoded >> 32);
    XCTAssertEqual((NSUInteger)indexPath.row, encoded & 0xffffffff);
#else
    XCTAssertNotEqual(indexPath.section, (int)(encoded >> 20));
    XCTAssertNotEqual(indexPath.row, (int)(encoded & 0xfffff));
    XCTAssertNotNil(caught);
#endif
}

- (void)testEncodeDecodeCycleForValuesOutOfRange
{
    NSException* caught = nil;

#ifdef __LP64__
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:((NSInteger)1) << 33
                                                inSection:((NSInteger)1) << 33];
#else
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 << 21
                                                inSection:1 << 13];
#endif

    NSUInteger encoded = NSNotFound;
    NSIndexPath* decoded = nil;

    @try {
        encoded = indexPath.aka_unsignedIntegerValue;
        decoded = [NSIndexPath aka_indexPathFromUnsignedIntegerValue:encoded];
    }
    @catch (NSException *exception) {
        caught = exception;
    }

    XCTAssertNotEqual(indexPath.section, decoded.section);
    XCTAssertNotEqual(indexPath.row, decoded.row);
    XCTAssertNotNil(caught);
}

@end
