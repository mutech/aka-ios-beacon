//
//  FormattingTests.m
//  AKACommons
//
//  Created by Michael Utech on 25.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface FormattingTests : XCTestCase

@end

@implementation FormattingTests

- (void)testExtendedFormatting
{
    NSString* format = @"%@";

    [[NSString alloc] initWithFormat:<#(nonnull NSString *)#> arguments:<#(__va_list_tag *)#>]
}

@end
