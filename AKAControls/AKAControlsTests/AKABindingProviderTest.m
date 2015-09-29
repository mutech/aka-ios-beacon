//
//  AKABindingProviderTest.m
//  AKAControls
//
//  Created by Michael Utech on 22.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <XCTest/XCTest.h>

@import AKACommons.AKANullability;
@import AKAControls.AKABindingProvider;
@import AKAControls.AKABindingExpression;

@interface AKABindingProviderTest : XCTestCase

@end


@interface AKATestBindingProvider: AKABindingProvider

- (instancetype)initWithSpecification:(NSDictionary*)specification;

@property(nonatomic) NSDictionary<NSString*, id>* attributeValidationSpecification;

@end


@implementation AKABindingProviderTest

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

- (void)testAttributeValidation
{
    __block NSUInteger attributeValidationCount = 0;
    NSDictionary* spec =
    @{ @"%attributeValidation": ^BOOL(NSDictionary* arguments)
       {
           ++attributeValidationCount;
           BOOL finalResult = ((NSNumber*)arguments[@"finalResult"]).boolValue;
           return finalResult;
       },
       @"a": @{ @"result": @YES },
       @"b": @{ @"result": @NO }
       };

    AKATestBindingProvider* bp = [[AKATestBindingProvider alloc] initWithSpecification:spec];

    NSError* error = nil;
    AKABindingExpression* exp;

    exp = [AKABindingExpression bindingExpressionWithString:@"$true { a: $false }"
                                            bindingProvider:bp
                                                      error:&error];
    /* TODO: Fix unit test (once validation is finished)
    XCTAssertNotNil(exp);
    XCTAssertNil(error);
    XCTAssert(attributeValidationCount == 1);

    error = nil;
    attributeValidationCount = 0;
    exp = [AKABindingExpression bindingExpressionWithString:@"$true { b: $false }"
                                            bindingProvider:bp
                                                      error:&error];
    XCTAssertNil(exp);
    XCTAssertNotNil(error);
    XCTAssert(error.code == 123 && [error.domain isEqualToString:@"test"]);
    XCTAssert(attributeValidationCount == 1);
     */
}

@end


@implementation AKATestBindingProvider

- (instancetype)initWithSpecification:(NSDictionary*)specification
{
    if (self = [self init])
    {
        _attributeValidationSpecification = specification;
    }
    return self;
}

- (BOOL)validateBindingExpression:(req_AKABindingExpression)bindingExpression
            forAttributeAtKeyPath:(req_NSString)attributeKeyPath
                      validatedBy:(opt_AKABindingProvider)targetBindingProvider
               atAttributeKeyPath:(opt_NSString)targetBindingProviderKeyPath
                       withResult:(BOOL)result
                            error:(out_NSError)error
{
    NSDictionary<NSString*, id>* spec = self.attributeValidationSpecification[attributeKeyPath];
    NSAssert(spec != nil, @"Erroneous test case, attribute validation specification missing for %@", attributeKeyPath);

    BOOL finalResult = ((NSNumber*)spec[@"result"]).boolValue;
    BOOL(^report)(NSDictionary* arguments) = self.attributeValidationSpecification[@"%attributeValidation"];
    if (report)
    {
        NSError* e = error ? *error : nil;
        e = e ? e : (id)[NSNull null];
        finalResult = report(@{ @"bindingExpression": (bindingExpression),
                                @"attributeKeyPath": (attributeKeyPath),
                                @"targetBindingProvider": (targetBindingProvider ? targetBindingProvider : [NSNull null]),
                                @"targetBindingProviderKeyPath": (targetBindingProviderKeyPath ? targetBindingProviderKeyPath : [NSNull null]),
                                @"result": @(result),
                                @"error": e,
                                @"finalResult": @(finalResult)
                                });
    }
    if (error && !finalResult)
    {
        *error = [NSError errorWithDomain:@"test" code:123 userInfo:@{ NSLocalizedDescriptionKey: @"unit-test" }];
    }
    return finalResult;
}

@end
