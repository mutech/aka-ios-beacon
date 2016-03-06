//
//  AKAObservableCollectionTests.m
//  AKACommons
//
//  Created by Michael Utech on 18.01.16.
//  Copyright © 2016 AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>
@import AKACommons;

@interface AKAObservableCollectionTests : XCTestCase

@property(nonatomic) NSArray* array;
@property(nonatomic) NSMutableArray* mutableArray;

@end

@implementation AKAObservableCollectionTests

- (void)setUp
{
    [super setUp];


}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSArray* testData = @[@"one", @"two", @"three"];
    AKAObservableCollection* oc = [[AKAObservableCollection alloc] initWithArray:testData];
    NSMutableArray<NSDictionary<NSString*, id>*>* changes = [NSMutableArray new];

    [oc addObserver:self
         forKeyPath:@"items"
            options:(NSKeyValueObservingOptions)(NSKeyValueObservingOptionInitial   |
                                                 NSKeyValueObservingOptionPrior     |
                                                 NSKeyValueObservingOptionNew       |
                                                 NSKeyValueObservingOptionOld)
            context:(__bridge void * _Nullable)(changes)];

    NSDictionary<NSString*, id>* change;
    NSKeyValueChange changeKind;

    NSMutableArray* items = [oc mutableArrayValueForKey:@"items"];
    XCTAssert(changes.count == 1);

    change = changes[0];
    changeKind = ((NSNumber*)change[NSKeyValueChangeKindKey]).unsignedIntegerValue;
    XCTAssertEqual(NSKeyValueChangeSetting, changeKind);

    XCTAssert(items.count == 3);
    XCTAssertEqualObjects(testData[0],  items[0]);
    XCTAssertEqualObjects(testData[1],  items[1]);
    XCTAssertEqualObjects(testData[2],  items[2]);


    [items addObject:@"four"];
    XCTAssertEqual(3u, changes.count);

    change = changes[1];
    changeKind = ((NSNumber*)change[NSKeyValueChangeKindKey]).unsignedIntegerValue;
    XCTAssertEqual(NSKeyValueChangeInsertion, changeKind);

    XCTAssert(items.count == 4);
    XCTAssertEqualObjects(testData[0],  items[0]);
    XCTAssertEqualObjects(testData[1],  items[1]);
    XCTAssertEqualObjects(testData[2],  items[2]);
    XCTAssertEqualObjects(@"four",      items[3]);

    [oc removeObserver:self forKeyPath:@"items" context:(__bridge void * _Nullable)(changes)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([object isKindOfClass:[AKAObservableCollection class]] && [@"items" isEqualToString:keyPath])
    {
        id ctx = (__bridge id)(context);
        if ([ctx isKindOfClass:[NSMutableArray class]])
        {
            NSMutableArray* changes = ctx;
            [changes addObject:change];
        }
    }
}

@end
