//
//  AKAThemeTests.m
//  AKAControls
//
//  Created by Michael Utech on 25.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <AKAControls/AKATheme.h>
#import <AKAControls/AKATextLabel.h>

@interface AKAThemeTests : XCTestCase

@end

@implementation AKAThemeTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCustomViewCustomization
{
    UIView* view = UIView.new;
    UILabel* label = UILabel.new;

    UITextField* textField = UITextField.new;
    id originalLabelText = label.text;
    id originalTextFieldText = textField.text;

    NSDictionary* views = @{ @"label": label,
                             @"view": view,
                             @"textField": textField };

    NSDictionary* spec = @{ @"view": @"label",
                            @"requirements": @{ @"type": @[[UILabel class], [UITextField class]],
                                                @"notType": [AKATextLabel class] },
                            @"properties": @{ @"text": @"Hello there" },
                            };
    AKAViewCustomization* customization = [[AKAViewCustomization alloc] initWithDictionary:spec];
    XCTAssert(customization != nil);
    XCTAssert(customization.viewKey == spec[@"view"]);

    XCTAssert([customization isApplicableToView:label]);
    XCTAssert([customization isApplicableToView:textField]);
    XCTAssert(![customization isApplicableToView:view]);

    XCTAssert(label.text == originalLabelText);
    [customization applyToView:label withContext:nil delegate:nil];
    XCTAssert([@"Hello there" isEqualToString:label.text]);
    label.text = originalLabelText;

    XCTAssert(textField.text == originalTextFieldText);
    [customization applyToView:textField withContext:nil delegate:nil];
    XCTAssert([@"Hello there" isEqualToString:textField.text]);
    textField.text = originalTextFieldText;

    XCTAssert(label.text == originalLabelText);
    XCTAssert(textField.text == originalTextFieldText);
    [customization applyToViews:views withContext:nil delegate:nil];
    XCTAssert([@"Hello there" isEqualToString:label.text]);
    XCTAssert(textField.text == originalTextFieldText);

}

- (void)testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
