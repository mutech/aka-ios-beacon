//
//  AKABindingExpressionTest.m
//  AKABeacon
//
//  Created by Michael Utech on 19.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>
#include <stdio.h>

#import "AKABindingExpression.h"
#import "AKABindingExpressionParser.h"
#import "AKABindingExpression_Internal.h"
#import "AKABinding.h"

#import "AKAClassConstantBindingExpression.h"
#import "AKAIntegerConstantBindingExpression.h"
#import "AKADoubleConstantBindingExpression.h"
#import "AKABooleanConstantBindingExpression.h"
#import "AKAEnumConstantBindingExpression.h"
#import "AKAOptionsConstantBindingExpression.h"
#import "AKAArrayBindingExpression.h"
#import "AKAColorConstantBindingExpression.h"
#import "AKACGPointConstantBindingExpression.h"
#import "AKACGSizeConstantBindingExpression.h"
#import "AKACGRectConstantBindingExpression.h"
#import "AKAConditionalBindingExpression.h"

@interface AKABindingExpressionTest: XCTestCase

@end


@interface UIColor (AKAComparison)
- (BOOL)isEqualToColor:(UIColor*)otherColor;
@end

@implementation UIColor (AKAComparison)
// http://stackoverflow.com/questions/970475/how-to-compare-uicolors
- (BOOL)isEqualToColor:(UIColor*)otherColor
{
    CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();

    UIColor*(^convertColorToRGBSpace)(UIColor*) = ^(UIColor* color) {
        if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome)
        {
            const CGFloat* oldComponents = CGColorGetComponents(color.CGColor);
            CGFloat components[4] = { oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1] };
            CGColorRef colorRef = CGColorCreate(colorSpaceRGB, components);

            UIColor* result = [UIColor colorWithCGColor:colorRef];
            CGColorRelease(colorRef);

            return result;
        }
        else
        {
            return color;
        }
    };

    UIColor* selfColor = convertColorToRGBSpace(self);

    otherColor = convertColorToRGBSpace(otherColor);
    CGColorSpaceRelease(colorSpaceRGB);

    BOOL result = [selfColor isEqual:otherColor];

    return result;
}

@end

@implementation AKABindingExpressionTest

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

#pragma mark - Conditional Tests


- (void)testConditionalExpression
{
    NSString* text = @"$when($true) 1 $when($false { a: $false }) 2 { b: $true } $else 3";
    AKABindingExpressionParser* parser = [AKABindingExpressionParser parserWithString:text];

    AKABindingExpression* expression = nil;
    AKABindingSpecification* specification =
    [[AKABindingSpecification alloc] initWithDictionary:@{ @"expressionType": @(AKABindingExpressionTypeIntegerConstant) }
                                                basedOn:nil];
    NSError* error;
    BOOL result = [parser parseBindingExpression:&expression
                               withSpecification:specification
                                           error:&error];

    XCTAssert(result,
              @"Failed to parse valid conditional expression %@: %@",
              text, error.localizedDescription);

    XCTAssert([expression isKindOfClass:[AKAConditionalBindingExpression class]],
              @"Parser failed to deliver a conditional binding expression for '%@', got: %@",
              text, NSStringFromClass(expression.class));

    AKAConditionalBindingExpression* conditional = (id)expression;

    // Serialization & Formatting
    XCTAssertEqualObjects(text, conditional.text);
    XCTAssertEqualObjects(@"$when($true)\n\t\t1\n\t$when($false { a: $false })\n\t\t2 {\n\t\t\tb: $true\n\t\t}\n\t$else\n\t\t3", [conditional textWithNestingLevel:1 indent:@"\t"]);

    // Check that everything is there:
    XCTAssertEqual(conditional.clauses.count, 3);
    XCTAssertEqual(conditional.clauses[0].conditionBindingExpression.expressionType,
                   AKABindingExpressionTypeBooleanConstant);
    XCTAssertEqual(conditional.clauses[1].conditionBindingExpression.expressionType,
                   AKABindingExpressionTypeBooleanConstant);
    XCTAssertNil(conditional.clauses[2].conditionBindingExpression);

    XCTAssertEqual(conditional.clauses[0].resultBindingExpression.expressionType,
                   AKABindingExpressionTypeIntegerConstant);
    XCTAssertEqual(conditional.clauses[0].resultBindingExpression.attributes.count,
                   0);
    XCTAssertEqual(conditional.clauses[1].resultBindingExpression.expressionType,
                   AKABindingExpressionTypeIntegerConstant);
    XCTAssertEqual(conditional.clauses[1].resultBindingExpression.attributes.count,
                   1);
    XCTAssertEqual(conditional.clauses[2].resultBindingExpression.expressionType,
                   AKABindingExpressionTypeIntegerConstant);
    XCTAssertEqual(conditional.clauses[2].resultBindingExpression.attributes.count,
                   0);
}

#pragma mark - Key Path Parser Tests

- (void)testBindingExpressionPerformance
{
    // All of these expressions should produce identical results
    NSString* text =
        @"$data.selectedCraft {"
        @"      picker: {"
        @"          items: $root.crafts,"
        @"          itemTitle: text,"
        @"          titleForUndefinedItem: $\"(keine Auswahl)\","
        @"          titleForOtherItem: $\"(manuelle Eingabe)\""
        @"      },"
        @"      picker2: {"
        @"          items: $root.crafts,"
        @"          itemTitle: text,"
        @"          titleForUndefinedItem: $\"(keine Auswahl)\","
        @"          titleForOtherItem: $\"(manuelle Eingabe)\""
        @"      }"
        @"}";

    // On the simulator, 250 runs take about 100ms, so parsing one relatively complex
    // binding expression takes about 2.5ms.
    [self measureBlock:^{
         for (int i = 0; i < 250; ++i)
         {
             AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
             AKABindingExpression* expression = nil;
             NSError* error = nil;
             BOOL result = [scanner parseBindingExpression:&expression
                                         withSpecification:nil
                                                     error:&error];
             XCTAssert(result, @"%@", [error localizedDescription]);
         }
     }];
}

- (void)testSimplifiedConstantSyntax
{
    NSString* text =
        @"modelValue {\n"
        @"\tsource: {\n"
        @"\t\ttype: <NSString>,\n"
        @"\t},\n"
        @"\tinput: {maxLength:(10){msg:\"Text is too long\",rule: \"max. 10 characters\"},minLength: $1 {\n"
        @"\t\t\tmsg: \"Text is too short\",\n"
        @"\t\t\trule: \"min. 1 character\"\n"
        @"\t\t},\n"
        @"\t\tpattern : \"[a-zA-z ]*\" { \n"
        @"\t\t\tmsg \n\t : \"Invalid characters\" \t\n,\n"
        @"\t\t\trule  : $\"letters and spaces allowed\" \n"
        @"\t\t},\n"
        @"\t}\n"
        @"}";
    NSString* expectedDescription =
        @"modelValue {\n"
        @"\tsource: {\n"
        @"\t\ttype: <NSString>\n"
        @"\t},\n"
        @"\tinput: {\n"
        @"\t\tmaxLength: 10 {\n"
        @"\t\t\tmsg: \"Text is too long\",\n"
        @"\t\t\trule: \"max. 10 characters\"\n"
        @"\t\t},\n"
        @"\t\tminLength: 1 {\n"
        @"\t\t\tmsg: \"Text is too short\",\n"
        @"\t\t\trule: \"min. 1 character\"\n"
        @"\t\t},\n"
        @"\t\tpattern: \"[a-zA-z ]*\" {\n"
        @"\t\t\tmsg: \"Invalid characters\",\n"
        @"\t\t\trule: \"letters and spaces allowed\"\n"
        @"\t\t}\n"
        @"\t}\n"
        @"}";
    NSString* expectedText =
        @"modelValue { source: { type: <NSString> }, input: { maxLength: 10 { msg: \"Text is too long\", rule: \"max. 10 characters\" }, minLength: 1 { msg: \"Text is too short\", rule: \"min. 1 character\" }, pattern: \"[a-zA-z ]*\" { msg: \"Invalid characters\", rule: \"letters and spaces allowed\" } } }";
    AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
    AKABindingExpression* expression = nil;
    NSError* error = nil;
    BOOL result = [scanner parseBindingExpression:&expression
                                withSpecification:nil
                                            error:&error];

    XCTAssertTrue(result, @"Failed to parse simplified constant syntax: %@", error.localizedDescription);
    XCTAssertEqualObjects(expectedDescription, expression.description);
    XCTAssertEqualObjects(expectedText, expression.text);
}

- (void)testBindingExpressionDescriptionForScopes
{
    // All of these expressions should produce identical results
    NSArray* expressions = @[ @"a.b.c",
                              @"$data.person.name {\n\treadOnly: $true,\n\ttest: $data.mac.osx\n}",
                              @"$data",
                              @"$root",
                              @"$control",
                              @"$true",
                              @"$false",
                              @"1",
                              @"-1",
                              @"a",
                              @"$data.b",
                              @"$root.c",
                              @"$control.owner",
                              @"a.b"
    ];

    for (NSString* text in expressions)
    {
        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
        AKABindingExpression* expression = nil;
        NSError* error = nil;
        BOOL result = [scanner parseBindingExpression:&expression
                                    withSpecification:nil
                                                error:&error];
        XCTAssert(result, @"%@ failed to parse: %@", text, error.localizedDescription);
        XCTAssertEqualObjects(text, expression.description);
        XCTAssertNil(error);
    }
}

- (void)testParseInvalidTopLevelPrimaryExpressionList
{
    NSArray* invalidArrayExpressions =
        @[ @"[ ], $true",
           @"1, 2",
           @"1, 2 { a: 1 }"
    ];

    for (NSString* text in invalidArrayExpressions)
    {
        AKABindingExpression* bindingExpression = nil;
        NSError* error;

        bindingExpression = [AKABindingExpression bindingExpressionWithString:text
                                                                  bindingType:AKABinding.class
                                                                        error:&error];

        XCTAssertNil(bindingExpression);
        XCTAssertNotNil(error);
        XCTAssertEqual(AKAParseErrorInvalidPrimaryExpressionExpectedAttributesOrEnd, error.code);
    }
}

- (void)testParseClassConstant
{
    NSArray* validClassNames = @[ @"$<NSString>",
                                  @"<NSString>"
    ];

    for (NSString* text in validClassNames)
    {
        Class type = nil;
        id constant = nil;
        NSError* error = nil;

        BOOL result = [[AKABindingExpressionParser parserWithString:text] parseConstantOrScope:&constant
                                                                             withSpecification:nil
                                                                                          type:&type
                                                                                         error:&error];
        XCTAssert(result);
        XCTAssert(type == [AKAClassConstantBindingExpression class]);
        XCTAssertEqual([NSString class], constant);
        XCTAssertNil(error);
    }
}

- (void)testParseClassConstantNonexistingClasses
{
    NSArray* validClassNames = @[ @"$<NopeString>",
                                  @"<NopeString>"
    ];

    for (NSString* text in validClassNames)
    {
        Class type = nil;
        id constant = nil;
        NSError* error = nil;

        BOOL result = [[AKABindingExpressionParser parserWithString:text] parseConstantOrScope:&constant
                                                                             withSpecification:nil
                                                                                          type:&type
                                                                                         error:&error];
        XCTAssert(!result);
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, AKAParseErrorUnknownClass);
    }
}

- (void)testParseClassConstantInvalidClassNamesFirstCharacter
{
    NSArray* invalidClassNames = @[ @"<_NSString>",
                                    @"<0NSString>",
                                    @"<ÄNSString>",
                                    @"<&NSSting>"
    ];

    for (NSString* text in invalidClassNames)
    {
        Class type = nil;
        id constant = nil;
        NSError* error = nil;

        BOOL result = [[AKABindingExpressionParser parserWithString:text] parseConstantOrScope:&constant
                                                                             withSpecification:nil
                                                                                          type:&type
                                                                                         error:&error];
        XCTAssert(!result);
        XCTAssertNotNil(error);
        XCTAssertEqual(AKAParseErrorInvalidIdentifierCharacter, error.code);
    }
}

- (void)testParseClassConstantInvalidClassNamesCharacter
{
    NSArray* invalidClassNames = @[ @"<NSString<>",
                                    @"<NSStringÄ>",
                                    @"<NSString&>"
    ];

    for (NSString* text in invalidClassNames)
    {
        Class type = nil;
        id constant = nil;
        NSError* error = nil;

        BOOL result = [[AKABindingExpressionParser parserWithString:text] parseConstantOrScope:&constant
                                                                             withSpecification:nil
                                                                                          type:&type
                                                                                         error:&error];
        XCTAssert(!result);
        XCTAssertNotNil(error);
        XCTAssertEqual(AKAParseErrorUnterminatedClassReference, error.code);
    }
}

- (void)testParseScopeInteger
{
    NSArray* validIntegers = @[ @"$0",
                                @"$1",
                                @"$-1",
                                @"$1000000000000",
                                @"$-1000000000000",
                                [NSString stringWithFormat:@"$%lld", LONG_LONG_MAX],
                                [NSString stringWithFormat:@"$%lld", LONG_LONG_MIN]
    ];

    for (NSString* text in validIntegers)
    {
        Class type = nil;
        NSNumber* constant = nil;
        NSError* error = nil;

        BOOL result = [[AKABindingExpressionParser parserWithString:text] parseConstantOrScope:&constant
                                                                             withSpecification:nil
                                                                                          type:&type
                                                                                         error:&error];
        XCTAssert(result);
        XCTAssert(type == [AKAIntegerConstantBindingExpression class]);
        XCTAssertEqual(constant.longLongValue, [text substringFromIndex:1].longLongValue);
        XCTAssertNil(error);
    }
}

- (void)testParseScopeDouble
{
    NSArray* validDoubles = @[ @"$(.1)",
                               @"$(1000000000000.)",
                               @"$(-1000000000000.)",
                               [NSString stringWithFormat:@"$(%f)", DBL_MAX],
                               [NSString stringWithFormat:@"$(%f)", DBL_MIN],
                               [NSString stringWithFormat:@"$(%f)", M_PI],
                               [NSString stringWithFormat:@"$(%f)", M_E]
    ];

    for (NSString* text in validDoubles)
    {
        Class type = nil;
        NSNumber* constant = nil;
        NSError* error = nil;

        BOOL result = [[AKABindingExpressionParser parserWithString:text] parseConstantOrScope:&constant
                                                                             withSpecification:nil
                                                                                          type:&type
                                                                                         error:&error];
        XCTAssert(result, @"Failed to parse %@", text);
        XCTAssert(type == [AKADoubleConstantBindingExpression class]);
        XCTAssertEqual(constant.doubleValue, [[text substringFromIndex:2] substringToIndex:text.length - 2].doubleValue);
        XCTAssertNil(error);
    }
}

- (void)testParseScopeTrue
{
    Class type = nil;
    NSNumber* constant = nil;
    NSError* error = nil;
    BOOL result = [[AKABindingExpressionParser parserWithString:@"$true"] parseConstantOrScope:&constant
                                                                             withSpecification:nil
                                                                                          type:&type
                                                                                         error:&error];

    XCTAssert(result);
    XCTAssert(type == [AKABooleanConstantBindingExpression class]);
    XCTAssertEqual(constant.boolValue, YES);
    XCTAssertNil(error);
}

- (void)testParseScopeFalse
{
    Class type = nil;
    NSNumber* constant = nil;
    NSError* error = nil;
    BOOL result = [[AKABindingExpressionParser parserWithString:@"$false"] parseConstantOrScope:&constant
                                                                              withSpecification:nil
                                                                                           type:&type
                                                                                          error:&error];

    XCTAssert(result);
    XCTAssert(type == [AKABooleanConstantBindingExpression class]);
    XCTAssertEqual(constant.boolValue, NO);
    XCTAssertNil(error);
}

- (void)testParseKeyPathValid
{
    NSArray* validKeyPaths = @[ @"a",
                                @"a.b",
                                @"a.b.c",
                                @"a.@count",
                                @"a.@count.b",
                                @"a.@avg.b",
                                @"a.@min.b",
                                @"a.@max.b",
                                @"a.@sum.b",
                                @"a.@distinctUnionOfObjects.b",
                                @"a.@unionOfObjects.b",
                                @"a.@distinctUnionOfArrays.b",
                                @"a.@unionOfArrays.b",
                                @"a.@distinctUnionOfSets.b",
                                @"a.@unionOfSets.b",
                                @"a.@count.@count", // valid even if nonsense
    ];

    for (NSString* keyPath in validKeyPaths)
    {
        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:keyPath];
        NSString* resultKeyPath = nil;
        NSError* error = nil;
        BOOL result = [scanner parseKeyPath:&resultKeyPath error:&error];

        XCTAssert(result == YES, @"valid key path %@ not recognized, error=%@", keyPath, error.localizedDescription);
        XCTAssert([keyPath isEqualToString:resultKeyPath], @"%@ != %@", keyPath, resultKeyPath);
        XCTAssertNil(error);
    }
}

- (void)testParseKeyPathInvalid
{
    NSArray* invalidKeyPathsScope = @[ @"$1.integerValue",
                                       @"$(1).doubleValue",
                                       @"$\"test\".length",
                                       @"$data.description",
                                       @"$root.description",
                                       @"$control.description"
    ];

    for (NSString* keyPath in invalidKeyPathsScope)
    {
        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:keyPath];
        NSString* resultKeyPath = nil;
        NSError* error = nil;
        BOOL result = [scanner parseKeyPath:&resultKeyPath error:&error];

        XCTAssert(result == NO, @"invalid key path %@ recognized", keyPath);
        XCTAssert(![keyPath isEqualToString:resultKeyPath], @"%@ == %@", keyPath, resultKeyPath);
        XCTAssertNotNil(error);
        XCTAssert(error.code == AKAParseErrorInvalidKeyPathComponent);
    }

    NSArray* invalidKeyPathsMissingKey = @[ @"a.@avg",
                                            @"a.@min",
                                            @"a.@max",
                                            @"a.@sum",
                                            @"a.@distinctUnionOfObjects",
                                            @"a.@unionOfObjects",
                                            @"a.@distinctUnionOfArrays",
                                            @"a.@unionOfArrays",
                                            @"a.@distinctUnionOfSets",
                                            @"a.@unionOfSets"
    ];
    for (NSString* keyPath in invalidKeyPathsMissingKey)
    {
        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:keyPath];
        NSString* resultKeyPath = nil;
        NSError* error = nil;
        BOOL result = [scanner parseKeyPath:&resultKeyPath error:&error];

        XCTAssert(result == NO, @"invalid key path %@ recognized", keyPath);
        XCTAssert(![keyPath isEqualToString:resultKeyPath], @"%@ == %@", keyPath, resultKeyPath);
        XCTAssertNotNil(error);
        XCTAssert(error.code == AKAParseErrorKeyPathOperatorRequiresSubsequentKey);
    }

    NSArray* invalidKeyPathsOperatorFollowing = @[ @"a.@avg.@count",
                                                   @"a.@min.@count",
                                                   @"a.@max.@count",
                                                   @"a.@sum.@count",
                                                   @"a.@distinctUnionOfObjects.@count",
                                                   @"a.@unionOfObjects.@count",
                                                   @"a.@distinctUnionOfArrays.@count",
                                                   @"a.@unionOfArrays.@count",
                                                   @"a.@distinctUnionOfSets.@count",
                                                   @"a.@unionOfSets.@count"
    ];

    for (NSString* keyPath in invalidKeyPathsOperatorFollowing)
    {
        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:keyPath];
        NSString* resultKeyPath = nil;
        NSError* error = nil;
        BOOL result = [scanner parseKeyPath:&resultKeyPath error:&error];

        XCTAssert(result == NO, @"invalid key path %@ recognized", keyPath);
        XCTAssert(![keyPath isEqualToString:resultKeyPath], @"%@ == %@", keyPath, resultKeyPath);
        XCTAssertNotNil(error);
        XCTAssert(error.code == AKAParseErrorKeyPathOperatorRequiresSubsequentKey);
    }
}

#pragma mark - Constant Expression Types

- (void)testEnums
{
    // TODO: elaborate

    [AKABindingExpressionSpecification registerEnumerationType:@"TestType"
                                              withValuesByName:@{ @"One": @(1),
                                                                  @"Two": @"Zwei",
                                                                  @"Three": self }];
    [AKABindingExpressionSpecification registerOptionsType:@"OptionsType"
                                          withValuesByName:@{ @"One": @(1),
                                                              @"Two": @(2),
                                                              @"Three": @(4) }];
    NSArray* texts = @[ @"$enum.TestType.One",
                        @"$enum.Two",
                        @"$enum.TestType.Three.description",
                        @"$enum"];
    NSArray* textsNewSyntax = @[ @"$TestType.One",
                                 @".Two",
                                 @"$TestType.Three.description" ];
    NSArray* values = @[ @(1),
                         [NSNull null],
                         self.description,
                         [NSNull null] ];
    NSArray* valuesWithType = @[ @(1),
                                 @"Zwei",
                                 self.description,
                                 [NSNull null] ];

    void (^performTest)(NSString*, NSUInteger, BOOL*_Nonnull) =
    ^(NSString* text, NSUInteger idx, BOOL* _Nonnull stop) {
        (void)stop;

        id expectedValue = values[idx];

        if (expectedValue == [NSNull null])
        {
            expectedValue = nil;
        }

        id expectedValueWithType = valuesWithType[idx];

        if (expectedValueWithType == [NSNull null])
        {
            expectedValueWithType = nil;
        }

        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
        AKABindingExpression* expression = nil;
        NSError* error = nil;
        BOOL result = [scanner parseBindingExpression:&expression
                                    withSpecification:nil
                                                error:&error];
        XCTAssertTrue(result, @"%@", error.localizedDescription);

        XCTAssertEqualObjects(expression.class, [AKAEnumConstantBindingExpression class]);
        AKAEnumConstantBindingExpression* enumExpression = (id)expression;

        id value = enumExpression.constant;
        XCTAssert(value == expectedValue || [expectedValue isEqual:value], @"Expected value %@ is not equal to %@", expectedValue, value);

        if (value == nil)
        {
            value = [AKABindingExpressionSpecification resolveEnumeratedValue:enumExpression.symbolicValue
                                                                      forType:@"TestType"
                                                                        error:&error];
            XCTAssertNil(error, @"%@", error.localizedDescription);
            XCTAssert(value == expectedValueWithType || [expectedValueWithType isEqual:value], @"Expected value %@ is not equal to %@", expectedValueWithType, value);
        }
    };

    [textsNewSyntax enumerateObjectsUsingBlock:performTest];
    [texts enumerateObjectsUsingBlock:performTest];
}

- (void)testOptions
{
    [AKABindingExpressionSpecification registerOptionsType:@"TestOptionsType"
                                          withValuesByName:@{ @"One": @(1),
                                                              @"Two": @(2),
                                                              @"Three": @(4) }];
    NSArray* texts = @[ @"$options.TestOptionsType { One }",
                        @"$options { Two }",
                        @"$options.TestOptionsType { Three }",
                        @"$options.TestOptionsType { One, Two, Three }",
                        @"$options { Two, Three }",
                        @"$options"];
    NSArray* textsNewSyntax = @[ @"$TestOptionsType.One", // Enumeration constant syntax
                                 @"{ .Two }", // Anonymous option syntax with options value syntax
                                 @"$TestOptionsType { Three }", // Option constant syntax with boolean attribute
                                 @"$TestOptionsType { .One, .Two, Three }", // Mixed boolean attribute and option value syntax
                                 @"{ .Two, .Three }" ];
    NSArray* values = @[ @(1),
                         [NSNull null],
                         @(4),
                         @(7),
                         [NSNull null],
                         [NSNull null] ];
    NSArray* valuesWithType = @[ @(1),
                                 @(2),
                                 @(4),
                                 @(7),
                                 @(6),
                                 @(0)];

    void (^performTest)(NSString*, NSUInteger, BOOL*_Nonnull) =
    ^(NSString* text, NSUInteger idx, BOOL* _Nonnull stop) {
        (void)stop;

        id expectedValue = values[idx];

        if (expectedValue == [NSNull null])
        {
            expectedValue = nil;
        }

        id expectedValueWithType = valuesWithType[idx];

        if (expectedValueWithType == [NSNull null])
        {
            expectedValueWithType = nil;
        }

        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
        AKABindingExpression* expression = nil;
        NSError* error = nil;
        BOOL result = [scanner parseBindingExpression:&expression
                                    withSpecification:nil
                                                error:&error];
        XCTAssertTrue(result, @"%@", error.localizedDescription);

        XCTAssertTrue([expression isKindOfClass:[AKAOptionsConstantBindingExpression class]] ||
                      [expression isKindOfClass:[AKAEnumConstantBindingExpression class]]);
        AKAOptionsConstantBindingExpression* optionsExpression = (id)expression;

        id value = optionsExpression.constant;
        XCTAssert(value == expectedValue || [expectedValue isEqual:value], @"Expected value %@ is not equal to %@", expectedValue, value);

        if (value == nil)
        {
            XCTAssert(optionsExpression.optionsType == nil);
            value = [AKABindingExpressionSpecification resolveOptionsValue:expression.attributes
                                                                   forType:@"TestOptionsType"
                                                                     error:&error];
            XCTAssertNil(error, @"%@", error.localizedDescription);
            XCTAssert(value == expectedValueWithType || [expectedValueWithType isEqual:value], @"Expected value %@ is not equal to %@", expectedValueWithType, value);
        }
    };

    [textsNewSyntax enumerateObjectsUsingBlock:performTest];
    [texts enumerateObjectsUsingBlock:performTest];
}

- (void)testValidColors
{
    CGFloat component = 127 / 255.0f; // Test fails for 127/255.0 (no f) because of different precision and exact floating point comparison in [UIColor isEqual]

    UIColor* referenceColor = [UIColor colorWithRed:component green:0 blue:0 alpha:1.0];
    NSString* text = (@"[ $color   { red:127,        g:0,     b:0               },"
                      @"  $UIColor { r:0.498039216,   green:0, b:0,    alpha:255 },"
                      @"  $CGColor { r:127,          g:0.0,   blue:0, a:1.0     } ]");
    AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
    AKABindingExpression* expression = nil;
    NSError* error = nil;
    BOOL result = [scanner parseBindingExpression:&expression
                                withSpecification:nil
                                            error:&error];

    XCTAssertTrue(result);
    XCTAssertTrue(expression.class == [AKAArrayBindingExpression class]);
    NSArray* array = ((AKAArrayBindingExpression*)expression).array;
    for (AKAColorConstantBindingExpression* colorExpression in array)
    {
        UIColor* color = nil;
        XCTAssert([colorExpression.class isSubclassOfClass:[AKAColorConstantBindingExpression class]]);

        if ([colorExpression isKindOfClass:[AKAUIColorConstantBindingExpression class]])
        {
            color = colorExpression.constant;
            XCTAssertEqualObjects(@"$UIColor { r:127, g:0, b:0, a:255 }", colorExpression.description);
        }
        else if ([colorExpression isKindOfClass:[AKACGColorConstantBindingExpression class]])
        {
            color = [UIColor colorWithCGColor:((__bridge CGColorRef)colorExpression.constant)];
            XCTAssertEqualObjects(@"$CGColor { r:127, g:0, b:0, a:255 }", colorExpression.description);
        }
        XCTAssert([color isEqualToColor:referenceColor], @"%@ != %@", color, referenceColor);
    }
}

- (void)testColorComponentRendering
{
    for (int component = 0; component <= 255; ++component)
    {
        NSString* text = [NSString stringWithFormat:@"$UIColor { r:%d, g:0, b:0, a:255 }", component];

        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
        AKABindingExpression* expression = nil;
        NSError* error = nil;
        BOOL result = [scanner parseBindingExpression:&expression withSpecification:nil error:&error];

        XCTAssertTrue(result);
        XCTAssertNil(error);

        XCTAssert([AKAUIColorConstantBindingExpression class] == expression.class);
        AKAColorConstantBindingExpression* colorExpression = (id)expression;

        XCTAssertEqualObjects(text, colorExpression.description);
    }
}

- (void)testInvalidColors
{
    NSArray<NSString*>* texts = @[ @"$UIColor { r:255 }",
                                   @"$UIColor { r:-1, g:0, b:0 }",
                                   @"$UIColor { r:256, g:0, b:0 }",
                                   @"$UIColor { r:-1.0, g:0, b:0 }",
                                   @"$UIColor { r:1.0001, g:0, b:0 }",
                                   @"$UIColor { r:255.0, g:0, b:0 }",
                                   @"$UIColor { r:1, g:2, b:3, red:1 }",
                                   @"$UIColor { r:1, g:2, b:3, other:1 }"
    ];
    for (NSString* text in texts)
    {
        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
        AKABindingExpression* expression = nil;
        NSError* error = nil;
        NSException* exception;
        @try
        {
            (void) [scanner parseBindingExpression:&expression
                                 withSpecification:nil
                                             error:&error];
        }
        @catch(NSException* e)
        {
            exception = e;
        }
        XCTAssertNotNil(exception);
    }
}

- (void)testValidCGPoints
{
    CGPoint referencePoint = CGPointMake(1.0, 2.0);

    NSArray<NSString*>* texts = @[ @"$CGPoint { x:1, y:2.0 }",
                                   @"$point { x:1.0, y:2 }"
    ];
    for (NSString* text in texts)
    {
        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
        AKABindingExpression* expression = nil;
        NSError* error = nil;
        BOOL result = [scanner parseBindingExpression:&expression
                                    withSpecification:nil
                                                error:&error];
        XCTAssertTrue(result);
        XCTAssertTrue([expression isKindOfClass:[AKACGPointConstantBindingExpression class]]);

        NSValue* value = ((AKACGPointConstantBindingExpression*)expression).constant;
        XCTAssertNotNil(value);
        XCTAssertTrue(strcmp(@encode(CGPoint), [value objCType]) == 0);

        CGPoint point = value.CGPointValue;
        XCTAssertEqual(point.x, referencePoint.x);
        XCTAssertEqual(point.y, referencePoint.y);
    }
}

- (void)testValidCGSizes
{
    CGSize referenceSize = CGSizeMake(1.0, 2.0);

    NSArray<NSString*>* texts = @[ @"$CGSize { width:1, h:2.0 }",
                                   @"$size { w:1.0, height:2 }"
    ];
    for (NSString* text in texts)
    {
        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
        AKABindingExpression* expression = nil;
        NSError* error = nil;
        BOOL result = [scanner parseBindingExpression:&expression
                                    withSpecification:nil
                                                error:&error];
        XCTAssertTrue(result);
        XCTAssertTrue([expression isKindOfClass:[AKACGSizeConstantBindingExpression class]]);

        NSValue* value = ((AKACGSizeConstantBindingExpression*)expression).constant;
        XCTAssertNotNil(value);
        XCTAssertTrue(strcmp(@encode(CGSize), [value objCType]) == 0);

        CGSize size = value.CGSizeValue;
        XCTAssertEqual(size.width, referenceSize.width);
        XCTAssertEqual(size.height, referenceSize.height);
        XCTAssertEqualObjects(@"$CGSize { w:1, h:2 }", expression.description);
    }
}

- (void)testValidCGRect
{
    CGRect referenceRect = CGRectMake(1.0, 2.0, 3.0, 4.0);

    NSArray<NSString*>* texts = @[ @"$CGRect { x:1.0, y:2, width:3, h:4.0 }",
                                   @"$rect { x:1, y:2, w:3.0, height:4 }"
    ];
    for (NSString* text in texts)
    {
        AKABindingExpressionParser* scanner = [AKABindingExpressionParser parserWithString:text];
        AKABindingExpression* expression = nil;
        NSError* error = nil;
        BOOL result = [scanner parseBindingExpression:&expression
                                    withSpecification:nil
                                                error:&error];
        XCTAssertTrue(result);
        XCTAssertTrue([expression isKindOfClass:[AKACGRectConstantBindingExpression class]]);

        NSValue* value = ((AKACGRectConstantBindingExpression*)expression).constant;
        XCTAssertNotNil(value);
        XCTAssertTrue(strcmp(@encode(CGRect), [value objCType]) == 0);

        CGRect rect = value.CGRectValue;
        XCTAssertEqual(rect.origin.x, referenceRect.origin.x);
        XCTAssertEqual(rect.origin.y, referenceRect.origin.y);
        XCTAssertEqual(rect.size.width, referenceRect.size.width);
        XCTAssertEqual(rect.size.height, referenceRect.size.height);
        XCTAssertEqualObjects(@"$CGRect { x:1, y:2, w:3, h:4 }", expression.description);
    }
}

#pragma mark - Scanner Helper Tests

- (void)testIsAtCharacterAndSkip
{
    AKABindingExpressionParser* parser = [AKABindingExpressionParser parserWithString:@"a Ä"];
    unichar ae = [@"Ä" characterAtIndex:0];
    BOOL result;

    XCTAssert(parser.scanner.scanLocation == 0);

    result = [parser isAtCharacter:'a'];
    XCTAssert(result);
    XCTAssert(parser.scanner.scanLocation == 0);

    result = [parser skipCharacter:'a'];
    XCTAssert(result);
    XCTAssert(parser.scanner.scanLocation == 1);

    result = [parser skipCharacter:'X'];
    XCTAssert(!result);
    XCTAssert(parser.scanner.scanLocation == 1);

    result = [parser isAtCharacter:' '];
    XCTAssert(result);
    XCTAssert(parser.scanner.scanLocation == 1);

    result = [parser skipCurrentCharacter];
    XCTAssert(result);
    XCTAssert(parser.scanner.scanLocation == 2);

    result = [parser isAtCharacter:ae];
    XCTAssert(result);
    XCTAssert(parser.scanner.scanLocation == 2);

    result = [parser skipCharacter:ae];
    XCTAssert(result);
    XCTAssert(parser.scanner.scanLocation == 3);
    XCTAssert(parser.scanner.isAtEnd);
    XCTAssert(![parser skipCurrentCharacter]);
    XCTAssert(![parser isAtCharacter:'\0']);
}

- (void)testIsValidIdentifierCharacter
{
    NSString* validIdentifierCharacters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";
    AKABindingExpressionParser* parser = [AKABindingExpressionParser parserWithString:validIdentifierCharacters];

    for (NSUInteger i = 0; i < parser.scanner.string.length; ++i)
    {
        XCTAssert(parser.scanner.scanLocation == i);
        BOOL result = [parser isAtValidIdentifierCharacter];
        XCTAssert(result, @"valid '%C' at %lu not recognized as valid identifier character", [parser.scanner.string characterAtIndex:parser.scanner.scanLocation], (unsigned long)parser.scanner.scanLocation);
        XCTAssert(parser.scanner.scanLocation == i);

        result = [parser skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(parser.scanner.scanLocation == i + 1);
    }

    NSString* invalidIdentifierCharacters = @" ~`,./<>?;'\\:\"|[]{}-=+)(*&^%$#@!±§¡™£¢∞§¶•ªº–≠“‘…æ≤≥÷`œåΩ≈ß∑´∂ç√ƒ®†©∫˜˙¥¨ˆ∆µ˚ˆøπ˚";
    parser = [AKABindingExpressionParser parserWithString:invalidIdentifierCharacters];

    for (NSUInteger i = 0; i < parser.scanner.string.length; ++i)
    {
        XCTAssert(parser.scanner.scanLocation == i);
        BOOL result = [parser isAtValidIdentifierCharacter];
        XCTAssert(!result, @"invalid '%C' at %lu recognized as valid identifier character", [parser.scanner.string characterAtIndex:parser.scanner.scanLocation], (unsigned long)parser.scanner.scanLocation);
        XCTAssert(parser.scanner.scanLocation == i);

        result = [parser skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(parser.scanner.scanLocation == i + 1);
    }

    NSString* validFirstIdentifierCharacters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    parser = [AKABindingExpressionParser parserWithString:validFirstIdentifierCharacters];

    for (NSUInteger i = 0; i < parser.scanner.string.length; ++i)
    {
        XCTAssert(parser.scanner.scanLocation == i);
        BOOL result = [parser isAtValidFirstIdentifierCharacter];
        XCTAssert(result, @"valid '%C' at %lu not recognized as valid first identifier character", [parser.scanner.string characterAtIndex:parser.scanner.scanLocation], (unsigned long)parser.scanner.scanLocation);
        XCTAssert(parser.scanner.scanLocation == i);

        result = [parser skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(parser.scanner.scanLocation == i + 1);
    }

    NSString* invalidFirstIdentifierCharacters = @" _0123456789~`,./<>?;'\\:\"|[]{}-=+)(*&^%$#@!±§¡™£¢∞§¶•ªº–≠“‘…æ≤≥÷`œåΩ≈ß∑´∂ç√ƒ®†©∫˜˙¥¨ˆ∆µ˚ˆøπ˚";
    parser = [AKABindingExpressionParser parserWithString:invalidFirstIdentifierCharacters];

    for (NSUInteger i = 0; i < parser.scanner.string.length; ++i)
    {
        XCTAssert(parser.scanner.scanLocation == i);
        BOOL result = [parser isAtValidFirstIdentifierCharacter];
        XCTAssert(!result, @"invalid '%C' at %lu recognized as valid first identifier character", [parser.scanner.string characterAtIndex:parser.scanner.scanLocation], (unsigned long)parser.scanner.scanLocation);
        XCTAssert(parser.scanner.scanLocation == i);

        result = [parser skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(parser.scanner.scanLocation == i + 1);
    }
}

- (void)testIsValidKeyPathComponentFirstCharacter
{
    NSString* validFirstIdentifierCharacters = @"@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    AKABindingExpressionParser* parser = [AKABindingExpressionParser parserWithString:validFirstIdentifierCharacters];

    for (NSUInteger i = 0; i < parser.scanner.string.length; ++i)
    {
        XCTAssert(parser.scanner.scanLocation == i);
        BOOL result = [parser isAtValidKeyPathComponentFirstCharacter];
        XCTAssert(result, @"valid '%C' at %lu not recognized as valid first KP character", [parser.scanner.string characterAtIndex:parser.scanner.scanLocation], (unsigned long)parser.scanner.scanLocation);
        XCTAssert(parser.scanner.scanLocation == i);

        result = [parser skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(parser.scanner.scanLocation == i + 1);
    }

    NSString* invalidFirstIdentifierCharacters = @" _0123456789~`,./<>?;'\\:\"|[]{}-=+)(*&^%$#!±§¡™£¢∞§¶•ªº–≠“‘…æ≤≥÷`œåΩ≈ß∑´∂ç√ƒ®†©∫˜˙¥¨ˆ∆µ˚ˆøπ˚";
    parser = [AKABindingExpressionParser parserWithString:invalidFirstIdentifierCharacters];

    for (NSUInteger i = 0; i < parser.scanner.string.length; ++i)
    {
        XCTAssert(parser.scanner.scanLocation == i);
        BOOL result = [parser isAtValidKeyPathComponentFirstCharacter];
        XCTAssert(!result, @"invalid '%C' at %lu recognized as valid first KP character", [parser.scanner.string characterAtIndex:parser.scanner.scanLocation], (unsigned long)parser.scanner.scanLocation);
        XCTAssert(parser.scanner.scanLocation == i);

        result = [parser skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(parser.scanner.scanLocation == i + 1);
    }
}

- (void)testIsValidFirstIntegerCharacter
{
    NSString* validFirstIntegerCharacters = @"0123456789-";
    AKABindingExpressionParser* parser = [AKABindingExpressionParser parserWithString:validFirstIntegerCharacters];

    for (NSUInteger i = 0; i < parser.scanner.string.length; ++i)
    {
        XCTAssert(parser.scanner.scanLocation == i);
        BOOL result = [parser isAtValidFirstIntegerCharacter];
        XCTAssert(result, @"valid '%C' at %lu not recognized as valid first integer character", [parser.scanner.string characterAtIndex:parser.scanner.scanLocation], (unsigned long)parser.scanner.scanLocation);
        XCTAssert(parser.scanner.scanLocation == i);

        result = [parser skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(parser.scanner.scanLocation == i + 1);
    }

    NSString* invalidFirstIntegerCharacters = @" +abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_~`,./<>?;'\\:\"|[]{}=)(*&^%$#@!±§¡™£¢∞§¶•ªº–≠“‘…æ≤≥÷`œåΩ≈ß∑´∂ç√ƒ®†©∫˜˙¥¨ˆ∆µ˚ˆøπ˚";
    parser = [AKABindingExpressionParser parserWithString:invalidFirstIntegerCharacters];

    for (NSUInteger i = 0; i < parser.scanner.string.length; ++i)
    {
        XCTAssert(parser.scanner.scanLocation == i);
        BOOL result = [parser isAtValidFirstIntegerCharacter];
        XCTAssert(!result, @"invalid '%C' at %lu recognized as valid first integer character", [parser.scanner.string characterAtIndex:parser.scanner.scanLocation], (unsigned long)parser.scanner.scanLocation);
        XCTAssert(parser.scanner.scanLocation == i);

        result = [parser skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(parser.scanner.scanLocation == i + 1);
    }
}

- (void)testLocationAndContextMessage
{
    AKABindingExpressionParser* parser = [AKABindingExpressionParser parserWithString:@"0123456789"];
    NSArray* expectedResults = @[ @"“»0«1234…”",
                                  @"“0»1«2345…”",
                                  @"“01»2«3456…”",
                                  @"“012»3«4567…”",
                                  @"“…123»4«5678…”",
                                  @"“…234»5«6789”",
                                  @"“…345»6«789”",
                                  @"“…456»7«89”",
                                  @"“…567»8«9”",
                                  @"“…678»9«”",
                                  @"“…789»«”"];

    for (NSUInteger i = 0; i < expectedResults.count; ++i)
    {
        parser.scanner.scanLocation = i;
        NSString* result = [parser contextMessageWithMaxLeading:3
                                                    maxTrailing:4];
        XCTAssertEqualObjects(expectedResults[i], result);
    }
}

@end
