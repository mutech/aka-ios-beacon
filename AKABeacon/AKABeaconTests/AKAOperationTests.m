//
//  AKAOperationTests.m
//  AKABeacon
//
//  Created by Michael Utech on 11.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

#import <XCTest/XCTest.h>

#import "AKABlockOperation.h"
#import "AKAOperationCondition.h"

@interface AKAOperationTests : XCTestCase

@property(nonatomic) BOOL kvoCondition;

@end

@implementation AKAOperationTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testOperationExecution
{
    XCTestExpectation* executedExpectation = [self expectationWithDescription:@"Executed"];
    NSOperationQueue* queue = [NSOperationQueue new];
    AKABlockOperation* operation = [[AKABlockOperation alloc] initWithBlock:^(void (^ _Nonnull finish)()) {
        XCTAssertTrue(![NSThread isMainThread], @"Expected not to run in main thread");
        [executedExpectation fulfill];
        finish();
    }];
    [operation addToOperationQueue:queue];
    [self waitForExpectationsWithTimeout:0.001 handler:^(NSError * _Nullable error) {
        NSLog(@"Failed to wait for expectations, error: %@", error.localizedDescription);
    }];
}

- (void)testOperationExecutionOnMainQueue
{
    XCTestExpectation* executedExpectation = [self expectationWithDescription:@"Executed"];
    NSOperationQueue* queue = [NSOperationQueue mainQueue];
    AKABlockOperation* operation = [[AKABlockOperation alloc] initWithBlock:^(void (^ _Nonnull finish)()) {
        XCTAssertTrue([NSThread isMainThread], @"Expected to run in main thread");
        [executedExpectation fulfill];
        finish();
    }];
    [operation addToOperationQueue:queue];
    [self waitForExpectationsWithTimeout:0.001 handler:^(NSError * _Nullable error) {
        NSLog(@"Failed to wait for expectations, error: %@", error.localizedDescription);
    }];
}


- (void)testDependencyWithConditionAndConditionDependency
{
    XCTestExpectation* dependencyExpectation = [self expectationWithDescription:@"Dependency Executed"];
    XCTestExpectation* operationExpectation = [self expectationWithDescription:@"Operation Executed"];

    NSOperationQueue* queue = [NSOperationQueue new];

    AKABlockOperation* dependency = [[AKABlockOperation alloc] initWithBlock:^(void (^ _Nonnull finish)()) {
        [dependencyExpectation fulfill];
        finish();
    }];

    AKAKVOOperationCondition* condition =
        [[AKAKVOOperationCondition alloc] initWithTarget:self
                                                 keyPath:@"kvoCondition"
                                          predicateBlock:^BOOL(id value) {
                                              return [value boolValue]; }
                             dependencyForOperationBlock:
         ^NSOperation * _Nullable(NSOperation * _Nonnull op __unused)
         {
             return [[AKABlockOperation alloc] initWithBlock:^(void (^ _Nonnull finish)()) {
                 self.kvoCondition = YES;
                 finish();
             }];
         }];

    _kvoCondition = NO;

    [dependency addCondition:condition];

    AKABlockOperation* operation = [[AKABlockOperation alloc] initWithBlock:^(void (^ _Nonnull finish)()) {
        [operationExpectation fulfill];
        finish();
    }];
    [operation addDependency:dependency];
    
    [operation addToOperationQueue:queue];
    [dependency addToOperationQueue:queue];
    
    [self waitForExpectationsWithTimeout:0.001 handler:^(NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"Failed to wait for expectations (error: %@)", error.localizedDescription);
        }
        else
        {
            NSLog(@"Failed to wait for expectations (no error)");
        }
    }];
}


@end
