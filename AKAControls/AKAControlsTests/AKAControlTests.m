//
//  AKAControlTests.m
//  AKABeacon
//
//  Created by Michael Utech on 17.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import XCTest;
@import AKAControls;

@interface AKAControl(Testable)
- (instancetype _Nonnull)             initWithConfiguration:(opt_AKAControlConfiguration)configuration;
- (instancetype _Nonnull)                     initWithOwner:(req_AKACompositeControl)owner
                                              configuration:(opt_AKAControlConfiguration)configuration;
- (instancetype _Nonnull)               initWithDataContext:(opt_id)dataContext
                                              configuration:(opt_AKAControlConfiguration)configuration;
- (void)                                          setOwner:(opt_AKACompositeControl)owner;
- (void)                                           setView:(opt_UIView)view;
@property(nonatomic, readonly)AKAProperty* dataContextProperty;
@end


@class AssertionHandler;
@interface AKAControlTests : XCTestCase

@property(nonatomic) AssertionHandler* assertionHandler;
@property(nonatomic) NSUInteger        failedAssertionCount;

@end


@interface AssertionHandler: NSAssertionHandler

@property(nonatomic, readonly)  AKAControlTests* testCase;
@property(nonatomic, readonly)  NSAssertionHandler* originalHandler;

@end

@implementation AssertionHandler

- (instancetype)initWithTestCase:(AKAControlTests*)testCase
{
    if (self = [self init])
    {
        _testCase = testCase;
    }
    return self;
}

- (BOOL)install
{
    BOOL result = self.originalHandler == nil;
    if (result)
    {
        _originalHandler = [[[NSThread currentThread] threadDictionary] valueForKey:NSAssertionHandlerKey];
        [[[NSThread currentThread] threadDictionary] setValue:self
                                                       forKey:NSAssertionHandlerKey];
    }
    return result;
}

- (BOOL)uninstall
{
    BOOL result = YES;
    if (result)
    {
        [[[NSThread currentThread] threadDictionary] setValue:self.originalHandler
                                                       forKey:NSAssertionHandlerKey];
    }
    return result;
}

- (void)handleFailureInMethod:(SEL)selector
                       object:(id)object
                         file:(NSString *)fileName
                   lineNumber:(NSInteger)line
                  description:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"NSAssert Failure: %@ (line %ld): [%@ %@]: %@",
          fileName, (long)line,
          object, NSStringFromSelector(selector),
          message);
    ++self.testCase.failedAssertionCount;
}

@end

@implementation AKAControlTests

- (void)setUp
{
    [super setUp];
    self.assertionHandler = [[AssertionHandler alloc] initWithTestCase:self];
}

- (void)tearDown
{
    [super tearDown];
}

/**
 * Verifies that initializing a control with a conforming controlType configuration succeeds.
 */
- (void)testControlInitWithConfiguration_validControlType
{
    AKAMutableControlConfiguration* configuration = [AKAMutableControlConfiguration new];
    configuration[kAKAControlTypeKey] = [AKAControl class];

    AKAControl* control = [[AKAControl alloc] initWithConfiguration:configuration];

    XCTAssertNotNil(control);
    XCTAssertNil(control.name);
    XCTAssertNil(control.role);
    XCTAssertNil(control.tags);
}

/**
 * Verifies that initializing a control with a non-conforming controlType fails with an exception.
 */
- (void)testControlInitWithConfiguration_invalidControlType
{
    AKAMutableControlConfiguration* configuration = [AKAMutableControlConfiguration new];
    configuration[kAKAControlTypeKey] = [AKACompositeControl class];

    XCTAssertThrows([[AKAControl alloc] initWithConfiguration:configuration], @"Expected AKAControl initialization to fail with an exception due to non-conformance with expected control type (AKAControl is not a subclass of AKACompositeControl");
}

/**
 * Verifies that initializing a control with an undefined configuration succeeds.
 */
- (void)testControlInitWithConfiguration_configurationIsOptional
{
    AKAMutableControlConfiguration* configuration = nil;

    AKAControl* control = [[AKAControl alloc] initWithConfiguration:configuration];

    XCTAssertNotNil(control);
    XCTAssertNil(control.name);
    XCTAssertNil(control.role);
    XCTAssertNil(control.tags);
}

/**
 * Verifies that configuration properties name, role and tags are used to setup corresponding
 * control properties.
 */
- (void)testControlInitWithConfiguration_configPropertiesUsed
{
    AKAMutableControlConfiguration* configuration = [AKAMutableControlConfiguration new];
    configuration[kAKAControlTypeKey] = [AKAControl class];
    configuration[kAKAControlNameKey] = @"aName";
    configuration[kAKAControlRoleKey] = @"someRole";
    configuration[kAKAControlTagsKey] = @"tag1 tag2";

    AKAControl* control = [[AKAControl alloc] initWithConfiguration:configuration];

    XCTAssertNotNil(control);
    XCTAssertEqualObjects(configuration[kAKAControlNameKey], control.name);
    XCTAssertEqualObjects(configuration[kAKAControlRoleKey], control.role);
    XCTAssertEqual(2, control.tags.count);
    XCTAssert([control.tags containsObject:@"tag1"]);
    XCTAssert([control.tags containsObject:@"tag2"]);
}

/**
 * Verifies that a control initialized with a data context references the specified data context,
 * that controls inherit their data context from their owner and that the data context is weakly referenced.
 */
- (void)testControl_dataContext
{
    NSMutableDictionary* dataContext;
    AKACompositeControl* owner;
    AKAControl* control;

    @autoreleasepool {
        dataContext = [NSMutableDictionary dictionaryWithDictionary:@{ @"one": @(1) }];
        owner = [[AKACompositeControl alloc] initWithDataContext:dataContext configuration:nil];
        XCTAssertNotNil(owner.dataContextProperty);
        XCTAssertEqualObjects(dataContext, owner.dataContextProperty.value);

        control = [[AKAControl alloc] initWithOwner:owner configuration:nil];
        XCTAssertNotNil(control);
        XCTAssertEqualObjects(owner, control.owner);
        XCTAssertNotNil(control.dataContextProperty);
        XCTAssertEqualObjects(dataContext, control.dataContextProperty.value);

        dataContext = nil;
    }
    XCTAssertNotNil(control.dataContextProperty);
    XCTAssertNil(control.dataContextProperty.value);
}

/**
 * Verifies that setOwner sets a controls owner, that changing a controls owner to another defined
 * composite control fails with an exception and that the owner is weakly referenced.
 */
- (void)testControl_setOwner
{
    AKACompositeControl* owner;
    AKACompositeControl* owner2;
    AKAControl* control;

    @autoreleasepool {
        owner = [[AKACompositeControl alloc] initWithConfiguration:nil];
        owner2 = [[AKACompositeControl alloc] initWithConfiguration:nil];
        control = [[AKAControl alloc] initWithConfiguration:nil];
        [control setOwner:owner];
        XCTAssertEqualObjects(owner, control.owner);

        [control setOwner:owner]; // No problem to set owner to old owner
        XCTAssertEqualObjects(owner, control.owner);

        owner = nil; // control holds weak ref to owner, owner -> nil
    }
    XCTAssertEqualObjects(nil, (id)control.owner);

    [control setOwner:owner2];
    XCTAssertEqualObjects(owner2, control.owner);

    owner = [[AKACompositeControl alloc] initWithConfiguration:nil];
    XCTAssertThrows([control setOwner:owner], @"Expected exception for invalid attempt to change owner of a control which is already owned");
}

/**
 * Verifies that setView set a controls view, that changing a controls view to another defined view
 * fails with an exception and that the view is weakly referenced.
 */
- (void)testControl_setView
{
    AKAControl* control;
    UIView* view1;
    UIView* view2;

    @autoreleasepool {
        control = [[AKAControl alloc] initWithConfiguration:nil];
        view1 = [UIView new];
        view2 = [UIView new];

        [control setView:view1];
        XCTAssertEqualObjects(view1, control.view);

        // Prevet assert to throw exception
        NSUInteger failedAssertionCount = self.failedAssertionCount;
        [self.assertionHandler install];
        [control setView:view2];
        [self.assertionHandler uninstall];
        XCTAssert(self.failedAssertionCount > failedAssertionCount, @"Expected assertion failure for invalid attempt to change view of a control which is already attached to a view");
        //[control setView:view1];
        //XCTAssertEqualObjects(view1, control.view);

        view1 = nil; // control holds weak ref to view1, view1 -> nil
    }
    XCTAssert(control.view == nil, @"Retain cycle between control and view1");
}

@end
