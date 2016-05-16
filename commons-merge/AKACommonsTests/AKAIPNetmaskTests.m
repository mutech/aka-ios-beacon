//
//  AKANetmaskTests.m
//  AKACommons
//
//  Created by Michael Utech on 20.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <AKACommons/AKAIPNetmask.h>

@interface AKAIPNetmaskTests : XCTestCase

@end

@implementation AKAIPNetmaskTests

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

- (void)testNetmaskLengthIsCorrect
{
    AKAIPNetmask* mask1 = [[AKAIPNetmask alloc] initWithString:@"255.255.255.0" error:nil];
    XCTAssertNotNil(mask1);
    XCTAssert(mask1.isValid);
    XCTAssertEqual(24, (int)mask1.length);

    AKAIPNetmask* mask2 = [[AKAIPNetmask alloc] initWithString:@"255.255.0.0" error:nil];
    XCTAssertNotNil(mask2);
    XCTAssert(mask2.isValid);
    XCTAssertEqual(16, (int)mask2.length);

    AKAIPNetmask* mask3 = [[AKAIPNetmask alloc] initWithString:@"255.255.255.240" error:nil];
    XCTAssertNotNil(mask3);
    XCTAssert(mask3.isValid);
    XCTAssertEqual(28, (int)mask3.length);

    AKAIPNetmask* mask4 = [[AKAIPNetmask alloc] initWithString:@"255.255.255.1" error:nil];
    XCTAssertNotNil(mask4);
    XCTAssert(!mask4.isValid);
    XCTAssertEqual(24, (int)mask4.length);
}

- (void)testNetmaskContiguity
{
    AKAIPNetmask* mask1 = [[AKAIPNetmask alloc] initWithString:@"255.255.253.0" error:nil];
    XCTAssertNotNil(mask1);
    XCTAssertFalse(mask1.isValid);

    AKAIPNetmask* mask2 = [[AKAIPNetmask alloc] initWithString:@"255.254.255.0" error:nil];
    XCTAssertNotNil(mask2);
    XCTAssertFalse(mask2.isValid);

    AKAIPNetmask* mask3 = [[AKAIPNetmask alloc] initWithString:@"254.255.255.0" error:nil];
    XCTAssertNotNil(mask3);
    XCTAssertFalse(mask3.isValid);

    AKAIPNetmask* mask4 = [[AKAIPNetmask alloc] initWithString:@"127.255.255.0" error:nil];
    XCTAssertNotNil(mask4);
    XCTAssertFalse(mask4.isValid);
}
@end
