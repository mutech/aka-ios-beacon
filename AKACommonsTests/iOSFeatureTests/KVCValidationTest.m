//
//  KVCValidationTest.m
//  AKACommons
//
//  Created by Michael Utech on 14.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface TestModel1: NSObject
@property(nonatomic) NSString* textValue;
@property(nonatomic) BOOL boolValue;
@end
@implementation TestModel1
@end

@interface TestModel2: NSObject
@property(nonatomic) NSString* textValue;
@end
@implementation TestModel2
- (BOOL)validateTextValue:(inout id __autoreleasing*)value error:(out NSError*__autoreleasing*)error
{
    BOOL result = YES;
    if (value != nil && *value != nil && ![*value isKindOfClass:[NSString class]])
    {
        result = NO;
        if (error)
        {
            *error = [NSError errorWithDomain:@"test" code:31401 userInfo:@{}];
        }
    }
    return result;
}
@end


@interface KVCValidationTest : XCTestCase
@property(nonatomic)TestModel1* testModel1;
@property(nonatomic)TestModel2* testModel2;
@end

@implementation KVCValidationTest

- (void)setUp
{
    [super setUp];
    self.testModel1 = [[TestModel1 alloc] init];
    self.testModel2 = [[TestModel2 alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testValidateWithoutImplementationDoesntFindWrongType
{
    NSError* error = nil;
    id value = @(123);
    BOOL result = [self.testModel1 validateValue:&value forKey:@"textValue" error:&error];
    XCTAssert(result == YES, @"Expected validation to succeed");
    XCTAssert(error == nil, @"Expected error to be unmodified");
}

- (void)testValidateWithImplementationFindsWrongType
{
    NSError* error = nil;
    id value = @(123);
    BOOL result = [self.testModel2 validateValue:&value forKey:@"textValue" error:&error];
    XCTAssert(result == NO, @"Expected validation to succeed");
    XCTAssert(error.code == 31401, @"Expected error.code == 31401");
}

- (void)testSetReferenceValueOfWrongTypeSuceedsWithInvalidState
{
    id oldValue = [self.testModel1 valueForKey:@"textValue"];
    [self.testModel1 setValue:@(123) forKey:@"textValue"];
    id newValue = [self.testModel1 valueForKey:@"textValue"];
    XCTAssert(oldValue != newValue, @"Expected value to change");
    XCTAssert([newValue isKindOfClass:[NSNumber class]], @"Expected number to be stored in string property");
}

- (void)testSetBoolValueOfWrongTypeFailsWithException
{
    self.testModel1.boolValue = YES;
    id oldValue = [self.testModel1 valueForKey:@"boolValue"];
    NSException* exception = nil;
    @try {
        [self.testModel1 setValue:self forKey:@"boolValue"];
    }
    @catch (NSException *e) {
        exception = e;
    }
    id newValue = [self.testModel1 valueForKey:@"boolValue"];
    XCTAssert(exception != nil);
    XCTAssert(newValue == oldValue);
}

@end
