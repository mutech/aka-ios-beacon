//
//  AKABindingExpressionTest.m
//  AKAControls
//
//  Created by Michael Utech on 19.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>

@import AKAControls.AKABindingExpression;
@import AKAControls.NSScanner_AKABindingExpressionParser;
#import "AKABindingExpression_Internal.h"

@interface AKABindingExpressionTest : XCTestCase

@end

@implementation AKABindingExpressionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Provider Validation Tests

- (void)testBindingProviderValidation
{
    NSString* text = @"\"test\" { unknownAttribute: $true { nestedAttribute: $true } }";

    AKABindingProvider* provider = [AKABindingProvider new];
    NSError* error = nil;
    AKABindingExpression* expression = [AKABindingExpression bindingExpressionWithString:text
                                                                         bindingProvider:provider error:&error];
    // TODO: fix test (once attribute validation via specs is finished)
    //XCTAssertNil(expression);
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

    [self measureBlock:^{
        for (int i=0; i < 250; ++i)
        {
            NSScanner* scanner = [NSScanner scannerWithString:text];
            AKABindingExpression* expression = nil;
            NSError* error = nil;
            BOOL result = [scanner parseBindingExpression:&expression
                                             withProvider:nil
                                                    error:&error];
            XCTAssert(result, @"%@", [error localizedDescription]);
        }
    }];
}

- (void)testSimplifiedConstantSyntax
{
    NSString* text =
    @"modelValue {\n"
    @"	source: {\n"
    @"		type: <NSString>,\n"
    @"	},\n"
    @"	input: {maxLength:(10){msg:\"Text is too long\",rule: \"max. 10 characters\"},minLength: $1 {\n"
    @"			msg: \"Text is too short\",\n"
    @"			rule: \"min. 1 character\"\n"
    @"		},\n"
    @"		pattern : \"[a-zA-z ]*\" { \n"
    @"			msg \n\t : \"Invalid characters\" \t\n,\n"
    @"			rule  : $\"letters and spaces allowed\" \n"
    @"		},\n"
    @"	}\n"
    @"}";
    NSString* expectedDescription =
    @"modelValue {\n"
    @"	source: {\n"
    @"		type: <NSString>\n"
    @"	},\n"
    @"	input: {\n"
    @"		maxLength: 10 {\n"
    @"			msg: \"Text is too long\",\n"
    @"			rule: \"max. 10 characters\"\n"
    @"		},\n"
    @"		minLength: 1 {\n"
    @"			msg: \"Text is too short\",\n"
    @"			rule: \"min. 1 character\"\n"
    @"		},\n"
    @"		pattern: \"[a-zA-z ]*\" {\n"
    @"			msg: \"Invalid characters\",\n"
    @"			rule: \"letters and spaces allowed\"\n"
    @"		}\n"
    @"	}\n"
    @"}";
    NSString* expectedText =
    @"modelValue { source: { type: <NSString> }, input: { maxLength: 10 { msg: \"Text is too long\", rule: \"max. 10 characters\" }, minLength: 1 { msg: \"Text is too short\", rule: \"min. 1 character\" }, pattern: \"[a-zA-z ]*\" { msg: \"Invalid characters\", rule: \"letters and spaces allowed\" } } }";
    NSScanner* scanner = [NSScanner scannerWithString:text];
    AKABindingExpression* expression = nil;
    NSError* error = nil;
    BOOL result = [scanner parseBindingExpression:&expression
                                     withProvider:nil
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
        NSScanner* scanner = [NSScanner scannerWithString:text];
        AKABindingExpression* expression = nil;
        NSError* error = nil;
        BOOL result = [scanner parseBindingExpression:&expression
                                         withProvider:nil
                                                error:&error];
        XCTAssert(result, @"%@ failed to parse: %@", text, error.localizedDescription);
        XCTAssertEqualObjects(text, expression.description);
        XCTAssertNil(error);
    }
}

- (void)testParseArrayValidItems
{
    NSArray* validArrayExpressions =
    @[ @"[ [ ], $true ]",
       @"[ 0.1, 1, \"zwei\", <NSNumber>, [ \"another array\" ], [ ], $true, $data.model.name ]"
       ];

    for (NSString* text in validArrayExpressions)
    {
        AKABindingExpression* bindingExpression = nil;
        AKABindingProvider* provider = nil;
        NSError* error;

        bindingExpression = [AKABindingExpression bindingExpressionWithString:text
                                                              bindingProvider:provider
                                                                        error:&error];

        XCTAssertNotNil(bindingExpression);
        XCTAssertNil(error);
        XCTAssertEqual([AKAArrayBindingExpression class], bindingExpression.class);
        XCTAssertEqualObjects(text, bindingExpression.text);
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
        AKABindingProvider* provider = nil;
        NSError* error;

        bindingExpression = [AKABindingExpression bindingExpressionWithString:text
                                                              bindingProvider:provider
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

        BOOL result = [[NSScanner scannerWithString:text] parseConstantOrScope:&constant
                                                                  withProvider:nil
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

        BOOL result = [[NSScanner scannerWithString:text] parseConstantOrScope:&constant
                                                                  withProvider:nil
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

        BOOL result = [[NSScanner scannerWithString:text] parseConstantOrScope:&constant
                                                                  withProvider:nil
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

        BOOL result = [[NSScanner scannerWithString:text] parseConstantOrScope:&constant
                                                                  withProvider:nil
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

        BOOL result = [[NSScanner scannerWithString:text] parseConstantOrScope:&constant
                                                                  withProvider:nil
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

        BOOL result = [[NSScanner scannerWithString:text] parseConstantOrScope:&constant
                                                                  withProvider:nil
                                                                          type:&type
                                                                         error:&error];
        XCTAssert(result, @"Failed to parse %@", text);
        XCTAssert(type == [AKADoubleConstantBindingExpression class]);
        XCTAssertEqual(constant.doubleValue, [[text substringFromIndex:2] substringToIndex:text.length-2].doubleValue);
        XCTAssertNil(error);
    }
}

- (void)testParseScopeTrue
{
    Class type = nil;
    NSNumber* constant = nil;
    NSError* error = nil;
    BOOL result = [[NSScanner scannerWithString:@"$true"] parseConstantOrScope:&constant
                                                                  withProvider:nil
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
    BOOL result = [[NSScanner scannerWithString:@"$false"] parseConstantOrScope:&constant
                                                                   withProvider:nil
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
        NSScanner* scanner = [NSScanner scannerWithString:keyPath];
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
        NSScanner* scanner = [NSScanner scannerWithString:keyPath];
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
        NSScanner* scanner = [NSScanner scannerWithString:keyPath];
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
        NSScanner* scanner = [NSScanner scannerWithString:keyPath];
        NSString* resultKeyPath = nil;
        NSError* error = nil;
        BOOL result = [scanner parseKeyPath:&resultKeyPath error:&error];

        XCTAssert(result == NO, @"invalid key path %@ recognized", keyPath);
        XCTAssert(![keyPath isEqualToString:resultKeyPath], @"%@ == %@", keyPath, resultKeyPath);
        XCTAssertNotNil(error);
        XCTAssert(error.code == AKAParseErrorKeyPathOperatorRequiresSubsequentKey);
    }
}

#pragma mark - Scanner Helper Tests

- (void)testIsAtCharacterAndSkip
{
    NSScanner* scanner = [NSScanner scannerWithString:@"a Ä"];
    unichar ae = [@"Ä" characterAtIndex:0];
    BOOL result;

    XCTAssert(scanner.scanLocation == 0);

    result = [scanner isAtCharacter:'a'];
    XCTAssert(result);
    XCTAssert(scanner.scanLocation == 0);

    result = [scanner skipCharacter:'a'];
    XCTAssert(result);
    XCTAssert(scanner.scanLocation == 1);

    result = [scanner skipCharacter:'X'];
    XCTAssert(!result);
    XCTAssert(scanner.scanLocation == 1);

    result = [scanner isAtCharacter:' '];
    XCTAssert(result);
    XCTAssert(scanner.scanLocation == 1);

    result = [scanner skipCurrentCharacter];
    XCTAssert(result);
    XCTAssert(scanner.scanLocation == 2);

    result = [scanner isAtCharacter:ae];
    XCTAssert(result);
    XCTAssert(scanner.scanLocation == 2);

    result = [scanner skipCharacter:ae];
    XCTAssert(result);
    XCTAssert(scanner.scanLocation == 3);
    XCTAssert(scanner.isAtEnd);
    XCTAssert(![scanner skipCurrentCharacter]);
    XCTAssert(![scanner isAtCharacter:'\0']);
}

- (void)testIsValidIdentifierCharacter
{
    NSString* validIdentifierCharacters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";
    NSScanner* scanner = [NSScanner scannerWithString:validIdentifierCharacters];

    for (NSUInteger i=0; i < scanner.string.length; ++i)
    {
        XCTAssert(scanner.scanLocation == i);
        BOOL result = [scanner isAtValidIdentifierCharacter];
        XCTAssert(result, @"valid '%C' at %lu not recognized as valid identifier character", [scanner.string characterAtIndex:scanner.scanLocation], (unsigned long)scanner.scanLocation);
        XCTAssert(scanner.scanLocation == i);

        result = [scanner skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(scanner.scanLocation == i+1);
    }

    NSString* invalidIdentifierCharacters = @" ~`,./<>?;'\\:\"|[]{}-=+)(*&^%$#@!±§¡™£¢∞§¶•ªº–≠“‘…æ≤≥÷`œåΩ≈ß∑´∂ç√ƒ®†©∫˜˙¥¨ˆ∆µ˚ˆøπ˚";
    scanner = [NSScanner scannerWithString:invalidIdentifierCharacters];

    for (NSUInteger i=0; i < scanner.string.length; ++i)
    {
        XCTAssert(scanner.scanLocation == i);
        BOOL result = [scanner isAtValidIdentifierCharacter];
        XCTAssert(!result, @"invalid '%C' at %lu recognized as valid identifier character", [scanner.string characterAtIndex:scanner.scanLocation], (unsigned long)scanner.scanLocation);
        XCTAssert(scanner.scanLocation == i);

        result = [scanner skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(scanner.scanLocation == i+1);
    }

    NSString* validFirstIdentifierCharacters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    scanner = [NSScanner scannerWithString:validFirstIdentifierCharacters];

    for (NSUInteger i=0; i < scanner.string.length; ++i)
    {
        XCTAssert(scanner.scanLocation == i);
        BOOL result = [scanner isAtValidFirstIdentifierCharacter];
        XCTAssert(result, @"valid '%C' at %lu not recognized as valid first identifier character", [scanner.string characterAtIndex:scanner.scanLocation], (unsigned long)scanner.scanLocation);
        XCTAssert(scanner.scanLocation == i);

        result = [scanner skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(scanner.scanLocation == i+1);
    }

    NSString* invalidFirstIdentifierCharacters = @" _0123456789~`,./<>?;'\\:\"|[]{}-=+)(*&^%$#@!±§¡™£¢∞§¶•ªº–≠“‘…æ≤≥÷`œåΩ≈ß∑´∂ç√ƒ®†©∫˜˙¥¨ˆ∆µ˚ˆøπ˚";
    scanner = [NSScanner scannerWithString:invalidFirstIdentifierCharacters];

    for (NSUInteger i=0; i < scanner.string.length; ++i)
    {
        XCTAssert(scanner.scanLocation == i);
        BOOL result = [scanner isAtValidFirstIdentifierCharacter];
        XCTAssert(!result, @"invalid '%C' at %lu recognized as valid first identifier character", [scanner.string characterAtIndex:scanner.scanLocation], (unsigned long)scanner.scanLocation);
        XCTAssert(scanner.scanLocation == i);

        result = [scanner skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(scanner.scanLocation == i+1);
    }
}

- (void)testIsValidKeyPathComponentFirstCharacter
{

    NSString* validFirstIdentifierCharacters = @"@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSScanner* scanner = [NSScanner scannerWithString:validFirstIdentifierCharacters];

    for (NSUInteger i=0; i < scanner.string.length; ++i)
    {
        XCTAssert(scanner.scanLocation == i);
        BOOL result = [scanner isAtValidKeyPathComponentFirstCharacter];
        XCTAssert(result, @"valid '%C' at %lu not recognized as valid first KP character", [scanner.string characterAtIndex:scanner.scanLocation], (unsigned long)scanner.scanLocation);
        XCTAssert(scanner.scanLocation == i);

        result = [scanner skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(scanner.scanLocation == i+1);
    }

    NSString* invalidFirstIdentifierCharacters = @" _0123456789~`,./<>?;'\\:\"|[]{}-=+)(*&^%$#!±§¡™£¢∞§¶•ªº–≠“‘…æ≤≥÷`œåΩ≈ß∑´∂ç√ƒ®†©∫˜˙¥¨ˆ∆µ˚ˆøπ˚";
    scanner = [NSScanner scannerWithString:invalidFirstIdentifierCharacters];

    for (NSUInteger i=0; i < scanner.string.length; ++i)
    {
        XCTAssert(scanner.scanLocation == i);
        BOOL result = [scanner isAtValidKeyPathComponentFirstCharacter];
        XCTAssert(!result, @"invalid '%C' at %lu recognized as valid first KP character", [scanner.string characterAtIndex:scanner.scanLocation], (unsigned long)scanner.scanLocation);
        XCTAssert(scanner.scanLocation == i);

        result = [scanner skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(scanner.scanLocation == i+1);
    }
}

- (void)testIsValidFirstIntegerCharacter
{
    NSString* validFirstIntegerCharacters = @"0123456789-";
    NSScanner* scanner = [NSScanner scannerWithString:validFirstIntegerCharacters];

    for (NSUInteger i=0; i < scanner.string.length; ++i)
    {
        XCTAssert(scanner.scanLocation == i);
        BOOL result = [scanner isAtValidFirstIntegerCharacter];
        XCTAssert(result, @"valid '%C' at %lu not recognized as valid first integer character", [scanner.string characterAtIndex:scanner.scanLocation], (unsigned long)scanner.scanLocation);
        XCTAssert(scanner.scanLocation == i);

        result = [scanner skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(scanner.scanLocation == i+1);
    }

    NSString* invalidFirstIntegerCharacters = @" +abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_~`,./<>?;'\\:\"|[]{}=)(*&^%$#@!±§¡™£¢∞§¶•ªº–≠“‘…æ≤≥÷`œåΩ≈ß∑´∂ç√ƒ®†©∫˜˙¥¨ˆ∆µ˚ˆøπ˚";
    scanner = [NSScanner scannerWithString:invalidFirstIntegerCharacters];

    for (NSUInteger i=0; i < scanner.string.length; ++i)
    {
        XCTAssert(scanner.scanLocation == i);
        BOOL result = [scanner isAtValidFirstIntegerCharacter];
        XCTAssert(!result, @"invalid '%C' at %lu recognized as valid first integer character", [scanner.string characterAtIndex:scanner.scanLocation], (unsigned long)scanner.scanLocation);
        XCTAssert(scanner.scanLocation == i);

        result = [scanner skipCurrentCharacter];
        XCTAssert(result);
        XCTAssert(scanner.scanLocation == i+1);
    }
}

- (void)testLocationAndContextMessage
{
    NSScanner* scanner = [NSScanner scannerWithString:@"0123456789"];
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
    for (NSUInteger i=0; i<expectedResults.count; ++i)
    {
        scanner.scanLocation = i;
        NSString* result = [scanner contextMessageWithMaxLeading:3
                                                     maxTrailing:4];
        XCTAssertEqualObjects(expectedResults[i], result);
    }
}

@end
