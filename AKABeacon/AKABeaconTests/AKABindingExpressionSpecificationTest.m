//
//  AKABindingExpressionSpecificationTest.m
//  AKABeacon
//
//  Created by Michael Utech on 25.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface AKABindingExpressionSpecificationTest : XCTestCase

@property(nonatomic, readonly) NSDictionary* specification;
@end

@implementation AKABindingExpressionSpecificationTest

- (void)setUp
{
    [super setUp];

    id booleanType = @{ @"allow": [NSNumber class], @"allowValue": @"c" };

    _specification =
    @{ @"type": @{ @"reject": [NSArray class] },
       @"attributes":
           @{ @"liveModelUpdates":
                  @{ @"required":        @NO,
                     @"type":            booleanType,
                     @"observe":         @NO,
                     @"default":         @YES,
                     @"bindingProperty": @YES,
                     @"provider":        @NO, // can be a type or an instance or @NO or not there
                     @"attributes":      @NO
                     },
              @"autoActivate":
                  @{ @"required":        @NO,
                     @"type":            booleanType,
                     @"observe":         @NO,
                     @"default":         @YES,
                     @"bindingProperty": @"autoActivate",
                     @"attributes":      @NO
                     },
              @"KBActivationSequence":
                  @{ @"required":        @NO,
                     @"type":            booleanType,
                     @"observe":         @NO,
                     @"default":         @YES,
                     @"bindingProperty": @YES,
                     @"attributes":      @NO
                     }
              },
       @"allowUnspecifiedAttributes": @NO
       };
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTypeConformanceSpecification
{
    NSArray<NSDictionary<NSString*, id>*>* testSpecs =
    @[ @{ @"spec": @{},
          @"type": [NSString class],
          @"result": @YES },
       @{ @"spec": @{ @"type": [NSNumber class] },
          @"type": [NSDecimalNumber class],
          @"result": @YES },
       @{ @"spec": @{ @"type": [NSNumber class] },
          @"type": [NSString class],
          @"result": @NO },
       @{ @"spec": @{ @"type": @[ [NSValue class], [NSString class] ] },
          @"type": [NSNumber class],
          @"result": @YES },
       @{ @"spec": @{ @"type": @[ [NSValue class], [NSString class] ] },
          @"type": [NSString class],
          @"result": @YES },
       @{ @"spec": @{ @"type": @{ @"accept":  @[ [NSValue class], [NSString class] ],
                                  @"reject":  @[ [NSNumber class], [NSMutableString class] ] } },
          @"type": [NSString class],
          @"result": @YES },
       @{ @"spec": @{ @"type": @{ @"accept":  @[ [NSValue class], [NSString class] ],
                                  @"reject":  @[ [NSNumber class], [NSMutableString class] ] } },
          @"type": [NSMutableString class],
          @"result": @NO },
       ];

    /* TODO: fix test (use AKATypePattern)
    for (NSDictionary* testSpec in testSpecs)
    {
        BOOL result = [testSpec[@"spec"] aka_typeConformsToSpecification:testSpec[@"type"]];
        NSNumber* expected = testSpec[@"result"];

        XCTAssert(expected.boolValue == result, @"Spec %@ does not match %@ as expected", testSpec, NSStringFromClass(testSpec[@"type"]));
    }*/
}

- (void)testAcceptsUnspecifiedAttributes
{
    NSArray<NSDictionary<NSString*, id>*>* testSpecs =
    @[ @{ @"spec": @{},
          @"result": @NO },
       @{ @"spec": @{ @"acceptUnspecifiedAttributes": @YES },
          @"type": [NSDecimalNumber class],
          @"result": @YES },
       @{ @"spec": @{ @"acceptUnspecifiedAttributes": @NO },
          @"type": [NSDecimalNumber class],
          @"result": @NO }
       ];

    /* TODO: fix test (use AKATypePattern)
    for (NSDictionary* testSpec in testSpecs)
    {
        BOOL result = [testSpec[@"spec"] aka_acceptsUnspecifiedAttributes];
        NSNumber* expected = testSpec[@"result"];

        XCTAssert(expected.boolValue == result, @"Spec %@ not interpreted correctly", testSpec);
    }*/
}
@end
