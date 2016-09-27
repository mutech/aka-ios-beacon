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
    self.dataContext[@"predicate"] = [NSPredicate predicateWithFormat:@"predicateActive = 1 AND key = 1"];
    self.dataContext[@"predicateActive"] = @YES;
    self.dataContext[@"predicate2"] = [NSPredicate predicateWithFormat:@"predicateActive = 1 AND $extra = 1" ];
    self.dataContext[@"extra"] = @YES;
    self.dataContext[@"key"] = @1;

    self.dataContext[@"a"] = @"A";
    self.dataContext[@"b"] = @"B";
    self.dataContext[@"c"] = @"C";

    UILabel* label = [UILabel new];

    // $when("key = 1") a ... would evaluate correctly once but would not trigger updates, because
    // [NSPredicate predicateWithFormat:"key = 1"] does not setup any KVO. Using "$key = 1" { key: key }
    // however will setup KVO for key and re-evaluate the predicate whenever the value of key changes.
    // Using NSPredicate is not really intuitive...
    label.textBinding_aka = (@"$when(predicate) \"predicate\""
                             @"$when(predicate2 { extra: extra }) \"predicate2\""
                             @"$when(\"key = 1\") a "
                             @"$when(\"key = 2\" { key: key }) b " // unused subst variable
                             @"$else c");

    AKABindingExpression* expression =
        [AKABindingExpression bindingExpressionForTarget:label property:@selector(textBinding_aka)];

    AKABinding* binding = [expression.specification.bindingType bindingToTarget:label
                                                                 withExpression:expression
                                                                        context:self
                                                                          owner:nil
                                                                       delegate:nil
                                                                          error:nil];

    [binding startObservingChanges];

    XCTAssertEqualObjects(label.text, @"predicate");

    self.dataContext[@"predicateActive"] = @NO;
    XCTAssertEqualObjects(label.text, self.dataContext[@"a"]);

    self.dataContext[@"key"] = @2;
    XCTAssertEqualObjects(label.text, self.dataContext[@"b"]);

    self.dataContext[@"predicateActive"] = @YES;
    XCTAssertEqualObjects(label.text, @"predicate2");

    self.dataContext[@"extra"] = @NO;
    XCTAssertEqualObjects(label.text, self.dataContext[@"b"]);

    self.dataContext[@"predicateActive"] = @NO;
    XCTAssertEqualObjects(label.text, self.dataContext[@"b"]);

    self.dataContext[@"key"] = @3;
    XCTAssertEqualObjects(label.text, self.dataContext[@"c"]);

    self.dataContext[@"key"] = @4;
    XCTAssertEqualObjects(label.text, self.dataContext[@"c"]);

    self.dataContext[@"c"] = @"_C_";
    XCTAssertEqualObjects(label.text, self.dataContext[@"c"]);

    self.dataContext[@"predicateActive"] = @YES;
    XCTAssertEqualObjects(label.text, self.dataContext[@"c"]);

    self.dataContext[@"key"] = @1;
    XCTAssertEqualObjects(label.text, @"predicate");

    self.dataContext[@"key"] = @2;
    XCTAssertEqualObjects(label.text, self.dataContext[@"b"]);

    [binding stopObservingChanges];
}

@end
