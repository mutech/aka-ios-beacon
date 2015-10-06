//
//  AKAReferenceTests.m
//  AKACommons
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>

@import AKACommons;

@interface AKAReferenceTests : XCTestCase

@end

@implementation AKAReferenceTests

- (void)testWeakReferenceProxy
{
    NSString* item = @"I'm alive";
    NSString* proxy = [AKAWeakReferenceProxy weakReferenceProxyFor:item];

    XCTAssert([item isEqualToString:[NSString stringWithString:proxy]]);
    XCTAssert([proxy isKindOfClass:[NSString class]]);
    XCTAssert([proxy class] == [item class]);
}

@end
