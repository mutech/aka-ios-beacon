//
//  AKAConditionalBindingTest.m
//  AKABeacon
//
//  Created by Michael Utech on 11.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AKAChildBindingContext.h"

#import "UILabel+AKAIBBindingProperties_textBinding.h"
#import "AKABindingExpression+Accessors.h"
#import "AKAViewBinding.h"

#import "AKABindingTestBase.h"

@interface AKAConditionalBindingTest : AKABindingTestBase


@end


@implementation AKAConditionalBindingTest

#pragma mark - Configuration

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

#pragma mark Tests

- (void)testConditionalBinding
{
    self.dataContext[@"isA"] = @NO;
    self.dataContext[@"a"] = @"A";
    self.dataContext[@"b"] = @"B";

    UILabel* label = [UILabel new];
    label.textBinding_aka = @"$when(isA) a $else b";

    AKABindingExpression* expression =
        [AKABindingExpression bindingExpressionForTarget:label property:@selector(textBinding_aka)];

    AKABinding* binding = [expression.specification.bindingType bindingToTarget:label
                                                                 withExpression:expression
                                                                        context:self
                                                                          owner:nil
                                                                       delegate:nil
                                                                          error:nil];

    [binding startObservingChanges];

    XCTAssertEqualObjects(label.text, self.dataContext[@"b"]);

    self.dataContext[@"isA"] = @YES;

    XCTAssertEqualObjects(label.text, self.dataContext[@"a"]);

    //[binding stopObservingChanges];
}

@end
