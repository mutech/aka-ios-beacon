//
//  AKAConditionalBindingTest.m
//  AKABeacon
//
//  Created by Michael Utech on 11.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AKAChildBindingContext.h"

#import "UILabel+AKAIBBindingProperties.h"
#import "AKABindingExpression+Accessors.h"
#import "AKAViewBinding.h"

@interface AKABindingTestBase : XCTestCase <AKABindingContextProtocol>

@property(nonatomic, readonly) NSMutableDictionary<NSString*, id>* dataContext;

@end

@implementation AKABindingTestBase

#pragma mark - Configuration

- (void)setUp
{
    [super setUp];
    _dataContext = [NSMutableDictionary new];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - View Model Configuration and Access

- (id<AKABindingContextProtocol>)bindingContextForKeyPath:(req_NSString)keyPath
{
    return [AKAChildBindingContext bindingContextWithParent:self keyPath:keyPath];
}

- (id<AKABindingContextProtocol>)bindingContextForNewDataContextAtKeyPath:(NSString*)keyPath
                                                                withValue:(id)value
{
    id<AKABindingContextProtocol> result = nil;

    NSObject* target = self.dataContext;
    NSArray<NSString*>* keys = [keyPath componentsSeparatedByString:@"."];
    if (keys.count > 0)
    {
        for (NSUInteger i=0; i + 1 < keys.count; ++i)
        {
            NSString* key = keys[i];
            id v = [target valueForKey:key];
            if (!v)
            {
                v = [NSMutableDictionary new];
                [target setValue:v forKey:key];
            }
            target = v;
        }

        if (target)
        {
            [target setValue:value forKey:(req_NSString)keys.lastObject];
        }

        result = [self bindingContextForKeyPath:keyPath];
    }
    return result;
}

#pragma mark - Binding Context Protocol

- (id)                  dataContextValueForKeyPath:(NSString *)keyPath
{
    return [self.dataContext valueForKeyPath:keyPath];
}

- (AKAProperty *)    dataContextPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self.dataContext keyPath:keyPath changeObserver:valueDidChange];
}

- (id)              rootDataContextValueForKeyPath:(NSString *)keyPath
{
    return [self dataContextValueForKeyPath:keyPath];
}

- (AKAProperty *)rootDataContextPropertyForKeyPath:(NSString *)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver)valueDidChange
{
    return [self dataContextPropertyForKeyPath:keyPath withChangeObserver:valueDidChange];
}

- (id)                      controlValueForKeyPath:(NSString *__unused)keyPath
{
    return nil;
}

- (AKAProperty *)        controlPropertyForKeyPath:(NSString *__unused)keyPath
                                withChangeObserver:(AKAPropertyChangeObserver __unused)valueDidChange
{
    return nil;
}

@end

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

    AKABinding* binding = [expression.specification.bindingType bindingToView:label
                                                               withExpression:expression
                                                                      context:self
                                                                     delegate:nil
                                                                        error:nil];

    [binding startObservingChanges];

    XCTAssertEqualObjects(label.text, self.dataContext[@"b"]);

    self.dataContext[@"isA"] = @YES;

    XCTAssertEqualObjects(label.text, self.dataContext[@"a"]);

    //[binding stopObservingChanges];
}

@end
