//
//  AKAPredicatePropertyBindingTest.m
//  AKABeacon
//
//  Created by Michael Utech on 26/09/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingTestBase.h"

#import "AKAPredicatePropertyBinding.h"


@interface AKAPredicatePropertyBindingTest: AKABindingTestBase

@property(nonatomic) NSPredicate* targetPredicate;

@end


@implementation AKAPredicatePropertyBindingTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testPredicateRewriting
{
    self.dataContext[@"booleanValue"] = @YES;

    self.dataContext[@"sourcePredicate"] = [NSPredicate predicateWithFormat:@"booleanValue = YES"];

    __block NSNumber* evaluationResult = nil;
    __block NSUInteger evaluationCount = 0;

    AKAProperty* bindingTarget = [AKAProperty propertyOfWeakKeyValueTarget:self
                                                                   keyPath:@"targetPredicate"
                                                            changeObserver:
                                  ^(id  _Nullable oldValue, id  _Nullable newValue)
                                  {
                                      XCTAssertTrue(oldValue == nil ||
                                                    [oldValue isKindOfClass:[NSPredicate class]]);
                                      XCTAssertTrue(newValue == nil ||
                                                    [newValue isKindOfClass:[NSPredicate class]]);
                                      NSPredicate* predicate = newValue;
                                      if (predicate)
                                      {
                                          evaluationResult = @([predicate evaluateWithObject:self.dataContext]);
                                          ++evaluationCount;
                                      }
                                  }];
    NSError* error = nil;
    AKABindingExpression* bindingExpression =
        [AKABindingExpression bindingExpressionWithString:@"sourcePredicate"
                                              bindingType:[AKAPredicatePropertyBinding class]
                                                    error:&error];
    XCTAssertNotNil(bindingExpression);
    XCTAssertNil(error);

    AKAPredicatePropertyBinding* binding = (id)
        [AKAPredicatePropertyBinding bindingToTarget:self
                                 targetValueProperty:bindingTarget
                                      withExpression:bindingExpression
                                             context:self
                                               owner:nil
                                            delegate:nil
                                               error:&error];
    XCTAssertNotNil(binding);
    XCTAssertNil(error);

    [binding startObservingChanges];
    [binding stopObservingChanges];
}

@end
