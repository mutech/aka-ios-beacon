//
//  AKATVMultiplexedDataSourceTests.m
//  AKACommons
//
//  Created by Michael Utech on 15.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "AKATVMultiplexedDataSource.h"

@interface ArrayDataSource: NSObject<UITableViewDataSource>
@property(nonatomic) NSArray* data;
@end
@implementation ArrayDataSource
+ (instancetype)dataSourceWithArray:(NSArray*)arrayOfArrayOfRows
{
    ArrayDataSource* result = ArrayDataSource.new;
    result.data = arrayOfArrayOfRows;
    return result;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    (void)tableView;
    return (NSInteger)self.data.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    (void)tableView;
    NSArray* rows = self.data[(NSUInteger)section];
    return (NSInteger)rows.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    (void)tableView;
    NSArray* rows = self.data[(NSUInteger)indexPath.section];
    id row = rows[(NSUInteger)indexPath.row];
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"notused"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", row];
    return cell;
}
@end


@interface AKATVMultiplexedDataSourceTests : XCTestCase
@end

@implementation AKATVMultiplexedDataSourceTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)assertDataSource:(id<UITableViewDataSource>)dsTest
          equalsExpected:(id<UITableViewDataSource>)dsExpected
{
    NSInteger expectedNumberOfSections = [dsExpected numberOfSectionsInTableView:nil];
    XCTAssertEqual([dsTest numberOfSectionsInTableView:nil], expectedNumberOfSections);
    for (NSInteger section=0; section < expectedNumberOfSections; ++section)
    {
        NSInteger expectedNumberOfRows = [dsExpected tableView:nil numberOfRowsInSection:section];
        NSInteger actualNumberOfRows = [dsTest tableView:nil numberOfRowsInSection:section];
        XCTAssertEqual(actualNumberOfRows, expectedNumberOfRows);

        for (NSInteger row=0; row < expectedNumberOfRows; ++row)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            NSString* abCell = [dsExpected tableView:nil cellForRowAtIndexPath:indexPath].textLabel.text;
            NSString* testCell = [dsTest tableView:nil cellForRowAtIndexPath:indexPath].textLabel.text;

            XCTAssertEqualObjects(abCell, testCell);
        }
    }
}

- (void)testCombineTwoDataSources
{
    ArrayDataSource* dsA = [ArrayDataSource dataSourceWithArray:
                             @[ @[ @"A0-1", @"A0-2", @"A0-3" ] ]];
    ArrayDataSource* dsB = [ArrayDataSource dataSourceWithArray:
                             @[ @[ @"B0-1", @"B0-2" ] ]];
    ArrayDataSource* dsAB = [ArrayDataSource dataSourceWithArray:
                             @[ @[ @"A0-1", @"A0-2", @"A0-3" ],
                                @[ @"B0-1", @"B0-2" ] ]];
    AKATVMultiplexedDataSource* dsTest = AKATVMultiplexedDataSource.new;

    [dsTest addDataSource:dsA withDelegate:nil forKey:@"dsA"];
    [dsTest addDataSource:dsB withDelegate:nil forKey:@"dsB"];
    [dsTest insertSectionsFromDataSource:@"dsA"
                      sourceSectionIndex:0
                                   count:1
                          atSectionIndex:0
                       useRowsFromSource:YES
                        withRowAnimation:UITableViewRowAnimationAutomatic];
    [dsTest insertSectionsFromDataSource:@"dsB"
                      sourceSectionIndex:0
                                   count:1
                          atSectionIndex:(NSUInteger)[dsTest numberOfSectionsInTableView:nil]
                       useRowsFromSource:YES
                        withRowAnimation:UITableViewRowAnimationAutomatic];

    [self assertDataSource:dsTest equalsExpected:dsAB];
}

- (void)testSectionWithRowsFromTwoDataSourcesAppendSecond
{
    ArrayDataSource* dsA = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"A0-1", @"A0-2", @"A0-3" ] ] ];
    ArrayDataSource* dsB = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"B0-1", @"B0-2" ] ] ];
    ArrayDataSource* dsAB = [ArrayDataSource dataSourceWithArray:
                             @[ @[ @"A0-1", @"A0-2", @"A0-3", @"B0-1", @"B0-2" ] ] ];
    AKATVMultiplexedDataSource* dsTest = AKATVMultiplexedDataSource.new;

    NSInteger numberOfRowsInA0 = [dsA tableView:nil numberOfRowsInSection:0];
    NSInteger numberOfRowsInB0 = [dsB tableView:nil numberOfRowsInSection:0];
    NSIndexPath* indexPath_0_0 = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath* indexPath_0_rowsA0 = [NSIndexPath indexPathForRow:numberOfRowsInA0 inSection:0];

    [dsTest addDataSource:dsA withDelegate:nil forKey:@"dsA"];
    [dsTest addDataSource:dsB withDelegate:nil forKey:@"dsB"];
    [dsTest insertSectionsFromDataSource:@"dsA"
                          sourceSectionIndex:0
                                       count:1
                              atSectionIndex:0
                            useRowsFromSource:NO
                            withRowAnimation:UITableViewRowAnimationAutomatic];
    [dsTest insertRowsFromDataSource:@"dsA"
                         sourceIndexPath:indexPath_0_0
                                   count:(NSUInteger)numberOfRowsInA0
                            atIndexPath:indexPath_0_0
                        withRowAnimation:UITableViewRowAnimationAutomatic];
    [dsTest insertRowsFromDataSource:@"dsB"
                         sourceIndexPath:indexPath_0_0
                                   count:(NSUInteger)numberOfRowsInB0
                            atIndexPath:indexPath_0_rowsA0
                        withRowAnimation:UITableViewRowAnimationAutomatic];

    [self assertDataSource:dsTest equalsExpected:dsAB];
}

- (void)testSectionWithRowsFromTwoDataSourcesPrependSecond
{
    ArrayDataSource* dsA = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"A0-1", @"A0-2", @"A0-3" ] ] ];
    ArrayDataSource* dsB = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"B0-1", @"B0-2" ] ] ];
    ArrayDataSource* dsAB = [ArrayDataSource dataSourceWithArray:
                             @[ @[ @"B0-1", @"B0-2" , @"A0-1", @"A0-2", @"A0-3" ] ] ];
    AKATVMultiplexedDataSource* dsTest = AKATVMultiplexedDataSource.new;

    NSInteger numberOfRowsInA0 = [dsA tableView:nil numberOfRowsInSection:0];
    NSInteger numberOfRowsInB0 = [dsB tableView:nil numberOfRowsInSection:0];
    NSIndexPath* indexPath_0_0 = [NSIndexPath indexPathForRow:0 inSection:0];

    [dsTest addDataSource:dsA withDelegate:nil forKey:@"dsA"];
    [dsTest addDataSource:dsB withDelegate:nil forKey:@"dsB"];
    [dsTest insertSectionsFromDataSource:@"dsA"
                          sourceSectionIndex:0
                                       count:1
                              atSectionIndex:0
                       useRowsFromSource:NO
                        withRowAnimation:UITableViewRowAnimationAutomatic];
    [dsTest insertRowsFromDataSource:@"dsA"
                         sourceIndexPath:indexPath_0_0
                                   count:(NSUInteger)numberOfRowsInA0
                         atIndexPath:indexPath_0_0
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [dsTest insertRowsFromDataSource:@"dsB"
                         sourceIndexPath:indexPath_0_0
                                   count:(NSUInteger)numberOfRowsInB0
                         atIndexPath:indexPath_0_0
                    withRowAnimation:UITableViewRowAnimationAutomatic];

    [self assertDataSource:dsTest equalsExpected:dsAB];
}

- (void)testSectionWithRowsFromTwoDataSourcesInsertSecond
{
    ArrayDataSource* dsA = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"A0-1", @"A0-2", @"A0-3" ] ] ];
    ArrayDataSource* dsB = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"B0-1", @"B0-2" ] ] ];
    ArrayDataSource* dsAB = [ArrayDataSource dataSourceWithArray:
                             @[ @[ @"A0-1", @"B0-1", @"B0-2", @"A0-2", @"A0-3" ] ] ];
    AKATVMultiplexedDataSource* dsTest = AKATVMultiplexedDataSource.new;

    NSInteger numberOfRowsInA0 = [dsA tableView:nil numberOfRowsInSection:0];
    NSInteger numberOfRowsInB0 = [dsB tableView:nil numberOfRowsInSection:0];
    NSIndexPath* indexPath_0_0 = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath* indexPath_0_1 = [NSIndexPath indexPathForRow:1 inSection:0];

    [dsTest addDataSource:dsA withDelegate:nil forKey:@"dsA"];
    [dsTest addDataSource:dsB withDelegate:nil forKey:@"dsB"];
    [dsTest insertSectionsFromDataSource:@"dsA"
                      sourceSectionIndex:0
                                   count:1
                          atSectionIndex:0
                       useRowsFromSource:NO
                        withRowAnimation:UITableViewRowAnimationAutomatic];
    [dsTest insertRowsFromDataSource:@"dsA"
                     sourceIndexPath:indexPath_0_0
                               count:(NSUInteger)numberOfRowsInA0
                         atIndexPath:indexPath_0_0
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [dsTest insertRowsFromDataSource:@"dsB"
                     sourceIndexPath:indexPath_0_0
                               count:(NSUInteger)numberOfRowsInB0
                         atIndexPath:indexPath_0_1
                    withRowAnimation:UITableViewRowAnimationAutomatic];

    [self assertDataSource:dsTest equalsExpected:dsAB];
}

- (void)testRemoveLeadingRows
{
    ArrayDataSource* dsA = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"A0-1", @"A0-2", @"A0-3" ], @[ @"A1-1" ]  ] ];
    ArrayDataSource* dsExpected = [ArrayDataSource dataSourceWithArray:
                                   @[ @[ @"A0-3" ], @[ @"A1-1" ]  ] ];
    AKATVMultiplexedDataSource* dsTest = AKATVMultiplexedDataSource.new;

    [dsTest addDataSource:dsA withDelegate:nil forKey:@"dsA"];
    [dsTest insertSectionsFromDataSource:@"dsA"
                      sourceSectionIndex:0
                                   count:(NSUInteger)[dsA numberOfSectionsInTableView:nil]
                          atSectionIndex:0
                       useRowsFromSource:YES
                        withRowAnimation:UITableViewRowAnimationAutomatic];

    NSUInteger removed = [dsTest removeUpTo:2
                             rowsFromIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    XCTAssertEqual(removed, (NSUInteger)2);
    [self assertDataSource:dsTest equalsExpected:dsExpected];
}

- (void)testRemoveTrailingRows
{
    ArrayDataSource* dsA = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"A0-1", @"A0-2", @"A0-3" ], @[ @"A1-1" ] ] ];
    ArrayDataSource* dsExpected = [ArrayDataSource dataSourceWithArray:
                                   @[ @[ @"A0-1", @"A0-2" ], @[ @"A1-1" ] ] ];
    AKATVMultiplexedDataSource* dsTest = AKATVMultiplexedDataSource.new;

    [dsTest addDataSource:dsA withDelegate:nil forKey:@"dsA"];
    [dsTest insertSectionsFromDataSource:@"dsA"
                      sourceSectionIndex:0
                                   count:(NSUInteger)[dsA numberOfSectionsInTableView:nil]
                          atSectionIndex:0
                       useRowsFromSource:YES
                        withRowAnimation:UITableViewRowAnimationAutomatic];

    NSUInteger removed = [dsTest removeUpTo:1
                             rowsFromIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    XCTAssertEqual(removed, (NSUInteger)1);
    [self assertDataSource:dsTest equalsExpected:dsExpected];
}


- (void)testRemoveInnerRows
{
    ArrayDataSource* dsA = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"A0-1", @"A0-2", @"A0-3" ], @[ @"A1-1" ] ] ];
    ArrayDataSource* dsExpected = [ArrayDataSource dataSourceWithArray:
                                   @[ @[ @"A0-1", @"A0-3" ], @[ @"A1-1" ] ] ];
    AKATVMultiplexedDataSource* dsTest = AKATVMultiplexedDataSource.new;

    [dsTest addDataSource:dsA withDelegate:nil forKey:@"dsA"];
    [dsTest insertSectionsFromDataSource:@"dsA"
                      sourceSectionIndex:0
                                   count:(NSUInteger)[dsA numberOfSectionsInTableView:nil]
                          atSectionIndex:0
                       useRowsFromSource:YES
                        withRowAnimation:UITableViewRowAnimationAutomatic];

    NSUInteger removed = [dsTest removeUpTo:1
                             rowsFromIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    XCTAssertEqual(removed, (NSUInteger)1);
    [self assertDataSource:dsTest equalsExpected:dsExpected];
}

- (void)testRemoveSuffixAndPrefixOfRowsSpanningSegments
{
    ArrayDataSource* dsA = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"A0-1", @"A0-2" ] ] ];
    ArrayDataSource* dsB = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"B0-1", @"B0-2" ] ] ];
    ArrayDataSource* dsAB = [ArrayDataSource dataSourceWithArray:
                             @[ @[ @"A0-1", @"A0-2", @"B0-1", @"B0-2" ] ] ];

    ArrayDataSource* dsExpected = [ArrayDataSource dataSourceWithArray:
                                   @[ @[ @"A0-1", @"B0-2" ] ] ];

    NSInteger numberOfRowsInA0 = [dsA tableView:nil numberOfRowsInSection:0];
    NSInteger numberOfRowsInB0 = [dsB tableView:nil numberOfRowsInSection:0];
    NSIndexPath* indexPath_0_0 = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath* indexPath_0_rA0 = [NSIndexPath indexPathForRow:numberOfRowsInA0 inSection:0];

    AKATVMultiplexedDataSource* dsTest = AKATVMultiplexedDataSource.new;

    [dsTest addDataSource:dsA withDelegate:nil forKey:@"dsA"];
    [dsTest addDataSource:dsB withDelegate:nil forKey:@"dsB"];
    [dsTest insertSectionsFromDataSource:@"dsA"
                      sourceSectionIndex:0
                                   count:(NSUInteger)[dsA numberOfSectionsInTableView:nil]
                          atSectionIndex:0
                       useRowsFromSource:YES
                        withRowAnimation:UITableViewRowAnimationAutomatic];
    [dsTest insertRowsFromDataSource:@"dsB"
                     sourceIndexPath:indexPath_0_0
                               count:(NSUInteger)numberOfRowsInB0
                         atIndexPath:indexPath_0_rA0
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [self assertDataSource:dsTest equalsExpected:dsAB];

    NSUInteger removed = [dsTest removeUpTo:2
                             rowsFromIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    XCTAssertEqual(removed, (unsigned long)2);
    [self assertDataSource:dsTest equalsExpected:dsExpected];
}

- (void)testRemoveFirstAndPrefixOfRowsSpanningSegments
{
    ArrayDataSource* dsA = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"A0-1", @"A0-2" ] ] ];
    ArrayDataSource* dsB = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"B0-1", @"B0-2" ] ] ];
    ArrayDataSource* dsAB = [ArrayDataSource dataSourceWithArray:
                             @[ @[ @"A0-1", @"A0-2", @"B0-1", @"B0-2" ] ] ];

    ArrayDataSource* dsExpected = [ArrayDataSource dataSourceWithArray:
                                   @[ @[ @"B0-2" ] ] ];

    NSInteger numberOfRowsInA0 = [dsA tableView:nil numberOfRowsInSection:0];
    NSInteger numberOfRowsInB0 = [dsB tableView:nil numberOfRowsInSection:0];
    NSIndexPath* indexPath_0_0 = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath* indexPath_0_rA0 = [NSIndexPath indexPathForRow:numberOfRowsInA0 inSection:0];

    AKATVMultiplexedDataSource* dsTest = AKATVMultiplexedDataSource.new;

    [dsTest addDataSource:dsA withDelegate:nil forKey:@"dsA"];
    [dsTest addDataSource:dsB withDelegate:nil forKey:@"dsB"];
    [dsTest insertSectionsFromDataSource:@"dsA"
                      sourceSectionIndex:0
                                   count:(NSUInteger)[dsA numberOfSectionsInTableView:nil]
                          atSectionIndex:0
                       useRowsFromSource:YES
                        withRowAnimation:UITableViewRowAnimationAutomatic];
    [dsTest insertRowsFromDataSource:@"dsB"
                     sourceIndexPath:indexPath_0_0
                               count:(NSUInteger)numberOfRowsInB0
                         atIndexPath:indexPath_0_rA0
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [self assertDataSource:dsTest equalsExpected:dsAB];

    NSUInteger removed = [dsTest removeUpTo:3
                             rowsFromIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    XCTAssertEqual(removed, (unsigned long)3);
    [self assertDataSource:dsTest equalsExpected:dsExpected];
}

- (void)testRemoveSuffixAndSecondOfRowsSpanningSegments
{
    ArrayDataSource* dsA = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"A0-1", @"A0-2" ] ] ];
    ArrayDataSource* dsB = [ArrayDataSource dataSourceWithArray:
                            @[ @[ @"B0-1", @"B0-2" ] ] ];
    ArrayDataSource* dsAB = [ArrayDataSource dataSourceWithArray:
                             @[ @[ @"A0-1", @"A0-2", @"B0-1", @"B0-2" ] ] ];

    ArrayDataSource* dsExpected = [ArrayDataSource dataSourceWithArray:
                                   @[ @[ @"A0-1"] ] ];

    NSInteger numberOfRowsInA0 = [dsA tableView:nil numberOfRowsInSection:0];
    NSInteger numberOfRowsInB0 = [dsB tableView:nil numberOfRowsInSection:0];
    NSIndexPath* indexPath_0_0 = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath* indexPath_0_rA0 = [NSIndexPath indexPathForRow:numberOfRowsInA0 inSection:0];

    AKATVMultiplexedDataSource* dsTest = AKATVMultiplexedDataSource.new;

    [dsTest addDataSource:dsA withDelegate:nil forKey:@"dsA"];
    [dsTest addDataSource:dsB withDelegate:nil forKey:@"dsB"];

    [dsTest insertSectionsFromDataSource:@"dsA"
                      sourceSectionIndex:0
                                   count:(NSUInteger)[dsA numberOfSectionsInTableView:nil]
                          atSectionIndex:0
                       useRowsFromSource:YES
                        withRowAnimation:UITableViewRowAnimationAutomatic];
    [dsTest insertRowsFromDataSource:@"dsB"
                     sourceIndexPath:indexPath_0_0
                               count:(NSUInteger)numberOfRowsInB0
                         atIndexPath:indexPath_0_rA0
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    [self assertDataSource:dsTest equalsExpected:dsAB];

    NSUInteger removed = [dsTest removeUpTo:3
                             rowsFromIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    XCTAssertEqual(removed, (unsigned long)3);
    [self assertDataSource:dsTest equalsExpected:dsExpected];
}

@end
