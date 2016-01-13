//
//  AKARuntimeTests.m
//  AKABeacon
//
//  Created by Michael Utech on 11.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import XCTest;
@import AKABeacon;

@interface AKARuntimeTests : XCTestCase

@end

@protocol TestProtocol <UITableViewDelegate>

+ (void)testStatic;
- (void)testInstance;

@optional
+ (void)testStaticOptional;
@optional
+ (void)testInstanceOptional;

@end

@interface AKARuntimeTests()
@end

@implementation AKARuntimeTests

- (void)testProtocolMethods {
    AKAProtocolInfo* protocolInfo = [[AKAProtocolInfo alloc] initWithProtocol:@protocol(UITableViewDelegate)];
    __block NSMutableArray* selectors = [NSMutableArray new];
    __block NSMutableDictionary* selectorsByProtocol = [NSMutableDictionary new];
    [protocolInfo enumerateMethodDescriptionsRecursivelyWithBlock:
     ^(Protocol *protocol, SEL selector, char *types, BOOL isRequired, BOOL isInstanceMethod)
     {
         (void)types;
         (void)isRequired;
         (void)isInstanceMethod;

         [selectors addObject:NSStringFromSelector(selector)];

         NSString* protocolName = NSStringFromProtocol(protocol);
         NSMutableArray* byProtocol = selectorsByProtocol[protocolName];
         if (!byProtocol)
         {
             byProtocol = [NSMutableArray new];
             selectorsByProtocol[protocolName] = byProtocol;
         }
         [byProtocol addObject:NSStringFromSelector(selector)];
     }];
    XCTAssert(selectors.count == 71);
    XCTAssert(selectorsByProtocol.count == 3);
}


@end
