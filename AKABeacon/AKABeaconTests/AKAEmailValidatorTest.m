//
//  AKAEmailValidatorTest.m
//  AKABeacon
//
//  Created by Michael Utech on 04.05.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

#import <XCTest/XCTest.h>
#import <AKABeacon/AKAEmailValidator.h>

@interface AKAEmailValidatorTest : XCTestCase

@property(nonatomic, readonly) AKAEmailValidator* validator;

@end

@implementation AKAEmailValidatorTest

- (void)setUp
{
    [super setUp];
    _validator = [AKAEmailValidator new];
}

- (void)tearDown
{
    _validator = nil;
    [super tearDown];
}

- (void)testValidAddresses
{
    NSArray* validAdresses = @[ @"mailbox@demo.de",
                                @"part.anotherpart@somwhere.com",
                                @"mailbox@[192.168.1.1]",
                                @"abcXYZ012!#$%&'*+/=?^_`{|}~-@example.com"];
    for (NSString* address in validAdresses)
    {
        NSError* error = nil;
        BOOL result = [self.validator validateModelValue:address error:&error];
        XCTAssertTrue(result, @"Valid address %@ failed to validate", address);
        XCTAssertNil(error, @"Unexpected error %@ for valid address %@", error.localizedDescription, address);
    }
}

- (void)testInvalidIPAddresses
{
    NSArray* invalidAdresses = @[ @"mailbox@[256.168.1.1]" ];
    for (NSString* address in invalidAdresses)
    {
        NSError* error = nil;
        BOOL result = [self.validator validateModelValue:address error:&error];
        XCTAssertFalse(result, @"Invalid address %@ did not fail to validate", address);
        XCTAssertNotNil(error, @"No error for invalid address %@", address);
    }
}
@end
