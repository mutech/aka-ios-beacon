//
// Created by Michael Utech on 26.03.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAThemeLayout.h"
#import "AKATheme.h"
#import "AKALayoutConstraintSpecification.h"
#import "AKAControlsErrors_Internal.h"

#pragma mark - Internal Class Cluster Interfaces
#pragma mark -

@interface AKALayoutConstraintSpecificationVisualFormat : AKALayoutConstraintSpecification

- (instancetype)initWithTarget:(UIView*)target
                  visualFormat:(NSString*)visualFormat
                       options:(NSLayoutFormatOptions)options;

@end

@interface AKALayoutConstraintSpecificationExplicit : AKALayoutConstraintSpecification

- (instancetype)initWithTarget:(UIView*)target
                    firstItems:(NSArray*)firstItems
                firstAttribute:(NSLayoutAttribute)firstAttribute
                     relatedBy:(NSLayoutRelation)relation
                   secondItems:(NSArray*)secondItems
               secondAttribute:(NSLayoutAttribute)secondAttribute
                    multiplier:(CGFloat)multiplier
                      constant:(CGFloat)constant
                      priority:(int)priority;

@end

@interface AKALayoutConstraintSpecificationExisting : AKALayoutConstraintSpecification

- (instancetype)initWithTarget:(UIView*)target
                   constraints:(NSArray*)constraints;

- (instancetype)initWithTarget:(UIView*)target
                    constraint:(NSLayoutConstraint*)constraint;

@end

#pragma mark - AKALayoutConstraintSpecification
#pragma mark -

@interface AKALayoutConstraintSpecification ()

/**
 * Initializes the constraint specification with the specified target.
 *
 * @note The initializer is intended to be used by implementing classes only. Please use the factory methods to create constraint specifications instead.
 *
 * @param target a UIView instance or a name referencing a UIView in a views dictionary.
 *
 * @return a constraints specification with a target reference
 */
- (instancetype)initWithTarget:(id)target;

@property(nonatomic) id target;

@end

@implementation AKALayoutConstraintSpecification

#pragma mark - Initialization

- (instancetype)initWithTarget:(id)target
{
    self = [super init];
    if (self)
    {
        self.target = target;
    }
    return self;
}

+ (AKALayoutConstraintSpecification *)constraintSpecificationWithDictionary:(NSDictionary *)specification
{
    AKALayoutConstraintSpecification* result = nil;

    id target = specification[@"target"];
    if (specification[@"format"] != nil)
    {
        id optionSpec = specification[@"options"];
        NSLayoutFormatOptions options = optionSpec == nil ? 0 : ((NSNumber*)optionSpec).intValue;
        NSString* format = specification[@"format"];
        result = [self constraintSpecificationWithTarget:target
                                            visualFormat:format
                                                 options:options];
    }
    else if (specification[@"firstItem"] != nil || specification[@"firstItems"] != nil)
    {
        NSArray* firstItems = specification[@"firstItems"];
        if (firstItems == nil)
        {
            NSString* item = specification[@"firstItem"];
            if (item)
            {
                firstItems = @[ item ];
            }
        }
        NSNumber* firstAttributeSpec = specification[@"firstAttribute"];
        NSLayoutAttribute firstAttribute = firstAttributeSpec.intValue;

        id relatedBySpec = specification[@"relatedBy"];
        NSLayoutRelation relatedBy = [self resolveConstraintRelation:relatedBySpec];

        NSArray* secondItems = specification[@"secondItems"];
        if (secondItems == nil)
        {
            NSString* item = specification[@"secondItem"];
            if (item)
            {
                secondItems = @[ item ];
            }
        }
        NSNumber* secondAttributeSpec = specification[@"secondAttribute"];
        NSLayoutAttribute secondAttribute = secondAttributeSpec.intValue;

        id multiplierSpec = specification[@"multiplier"];
        CGFloat multiplier = multiplierSpec == nil ? 1.0 : ((NSNumber*)multiplierSpec).doubleValue;

        id constantSpec = specification[@"constant"];
        CGFloat constant = constantSpec == nil ? 0 : ((NSNumber*)constantSpec).integerValue;

        id prioritySpec = specification[@"priority"];
        int priority = prioritySpec == nil ? 1000 : ((NSNumber*)prioritySpec).intValue;

        result = [self constraintSpecificationWithTarget:target
                                              firstItems:firstItems
                                          firstAttribute:firstAttribute
                                               relatedBy:relatedBy
                                             secondItems:secondItems
                                         secondAttribute:secondAttribute
                                              multiplier:multiplier
                                                constant:constant
                                                priority:priority];
    }
    else if (specification[@"constraint"] != nil)
    {
        result = [self constraint:specification[@"constraint"] withTarget:target];
    }
    else if (specification[@"constraints"] != nil)
    {
        result = [self constraints:specification[@"constraints"] withTarget:target];
    }
    return result;
}

+ (AKALayoutConstraintSpecification *)constraintSpecificationWithTarget:(id)target
                                                           visualFormat:(NSString *)visualFormat
                                                                options:(NSLayoutFormatOptions)
                                                                        options
{
    return [[AKALayoutConstraintSpecificationVisualFormat alloc] initWithTarget:target
                                                                   visualFormat:visualFormat
                                                                        options:options];
}

+ (AKALayoutConstraintSpecification *)constraint:(NSLayoutConstraint *)constraint
                                      withTarget:(id)target
{
    return [[AKALayoutConstraintSpecificationExisting alloc] initWithTarget:target
                                                                 constraint:constraint];
}

+ (AKALayoutConstraintSpecification *)constraints:(NSArray *)constraints
                                       withTarget:(id)target
{
    return [[AKALayoutConstraintSpecificationExisting alloc] initWithTarget:target
                                                                constraints:constraints];
}

+ (AKALayoutConstraintSpecification *)constraintSpecificationWithTarget:(id)target
                                                             firstItems:(NSArray *)firstItems
                                                         firstAttribute:(NSLayoutAttribute)firstAttribute
                                                              relatedBy:(NSLayoutRelation)relation
                                                            secondItems:(NSArray *)secondItems
                                                        secondAttribute:(NSLayoutAttribute)secondAttribute
                                                             multiplier:(CGFloat)multiplier
                                                               constant:(CGFloat)constant
                                                               priority:(int)priority
{
    return [[AKALayoutConstraintSpecificationExplicit alloc] initWithTarget:target
                                                                 firstItems:firstItems
                                                             firstAttribute:firstAttribute
                                                                  relatedBy:relation
                                                                secondItems:secondItems
                                                            secondAttribute:secondAttribute
                                                                 multiplier:multiplier
                                                                   constant:constant
                                                                   priority:priority];
}

#pragma mark - Creating and installing constraints

- (NSArray*)constraintsForViews:(NSDictionary*)views
                        metrics:(NSDictionary*)metrics
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSArray *)installConstraintsForViews:(NSDictionary *)views
                                metrics:(NSDictionary *)metrics
                          defaultTarget:(UIView *)defaultTarget
{
    return [self installConstraintsForViews:views
                                    metrics:metrics
                              defaultTarget:defaultTarget
                                   delegate:nil];
}

- (NSArray *)installConstraintsForViews:(NSDictionary *)views
                                metrics:(NSDictionary *)metrics
                          defaultTarget:(UIView *)defaultTarget
                               delegate:(NSObject<AKALayoutConstraintSpecificationDelegate>*)delegate
{
    NSArray* constraints = nil;
    UIView* effectiveTarget = nil;
    if ([self.target isKindOfClass:[UIView class]])
    {
        effectiveTarget = self.target;
    }
    else if ([self.target isKindOfClass:[NSString class]])
    {
        effectiveTarget = views[self.target];
    }

    if (effectiveTarget == nil)
    {
        effectiveTarget = defaultTarget;
    }
    if (effectiveTarget != nil)
    {
        constraints = [self constraintsForViews:views
                                                 metrics:metrics];
        if ([self shouldInstallConstraints:constraints
                                  inTarget:effectiveTarget
                                  delegate:delegate])
        {
            [self willInstallConstraints:constraints
                                inTarget:effectiveTarget
                                delegate:delegate];

            [effectiveTarget addConstraints:constraints];
            
            [self didInstallConstraints:constraints
                               inTarget:effectiveTarget
                               delegate:delegate];

        }
    }
    return constraints;
}

- (void)setTarget:(id)target
{
    NSParameterAssert(target == nil ||
                      [target isKindOfClass:[UIView class]] ||
                      [target isKindOfClass:[NSString class]]);
    _target = target;
}

#pragma mark - AKALayoutConstraintSpecificationDelegate support

/**
 * Determines if the constraint specification should install the specified constraints
 * in the specified target view using the specified delegate and the instance delegate
 * delegate in this order.
 *
 * @param constraints the constraints to be installed
 * @param target the target view
 * @param delegate the primary delegate used to determine the result
 *
 * @return YES if the constraints should be installed.
 */
- (BOOL)shouldInstallConstraints:(NSArray*)constraints
                        inTarget:(UIView*)target
                        delegate:(NSObject<AKALayoutConstraintSpecificationDelegate>*)delegate
{
    BOOL result = constraints.count > 0;
    if (result && [delegate respondsToSelector:@selector(constraintSpecification:shouldInstallConstraints:inTarget:)])
    {
        result &= [delegate constraintSpecification:self
                           shouldInstallConstraints:constraints
                                           inTarget:target];
    }
    if (result && [self.delegate respondsToSelector:@selector(constraintSpecification:shouldInstallConstraints:inTarget:)])
    {
        result &= [self.delegate constraintSpecification:self
                                shouldInstallConstraints:constraints
                                                inTarget:target];
    }
    return result;
}

/**
 * Announces to the specified and the instance delegate that the specified constraints will
 * be installed in the specified target
 *
 * @param constraints the constraints that will be installed
 * @param target the target view
 * @param delegate the delegate
 */
- (void)willInstallConstraints:(NSArray*)constraints
                      inTarget:(UIView*)target
                      delegate:(NSObject<AKALayoutConstraintSpecificationDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(constraintSpecification:willInstallConstraints:inTarget:)])
    {
        [delegate constraintSpecification:self
                   willInstallConstraints:constraints
                                 inTarget:target];
    }
    if ([self.delegate respondsToSelector:@selector(constraintSpecification:willInstallConstraints:inTarget:)])
    {
        [self.delegate constraintSpecification:self
                        willInstallConstraints:constraints
                                      inTarget:target];
    }
}

/**
 * Announces to the specified and the instance delegate that the specified constraints have
 * been installed in the specified target
 *
 * @param constraints the constraints that will be installed
 * @param target the target view
 * @param delegate the delegate
 */
- (void)didInstallConstraints:(NSArray*)constraints
                     inTarget:(UIView*)target
                     delegate:(NSObject<AKALayoutConstraintSpecificationDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(constraintSpecification:didInstallConstraints:inTarget:)])
    {
        [delegate constraintSpecification:self
                    didInstallConstraints:constraints
                                 inTarget:target];
    }
    if ([self.delegate respondsToSelector:@selector(constraintSpecification:didInstallConstraints:inTarget:)])
    {
        [self.delegate constraintSpecification:self
                         didInstallConstraints:constraints
                                      inTarget:target];
    }
}

#pragma mark - Implementation

/**
 * Resolves a layout relation specification to an NSLayoutRelation constant.
 *
 * @param relation nil (defaults to ==), an NSString >=, <=, == or an NSNumber containing a NSLayoutRelation constant.
 *
 * @return the NSLayoutRelation value corresponding to the relation specification
 */
+ (NSLayoutRelation)resolveConstraintRelation:(id)relation
{
    NSLayoutRelation result = NSLayoutRelationEqual;
    if ([relation isKindOfClass:[NSString class]])
    {
        if ([@"<=" isEqualToString:relation])
        {
            result = NSLayoutRelationLessThanOrEqual;
        }
        else if ([@">=" isEqualToString:relation])
        {
            result = NSLayoutRelationGreaterThanOrEqual;
        }
        else if (![@"==" isEqualToString:relation])
        {
            [AKAControlsErrors invalidLayoutRelationSpecification:relation];
        }
    }
    else if ([relation isKindOfClass:[NSNumber class]])
    {
        result = ((NSNumber*)relation).unsignedIntegerValue;
    }
    else if (relation != nil)
    {
        [AKAControlsErrors invalidLayoutRelationSpecification:relation];
    }
    return result;
}

@end

#pragma mark - AKALayoutConstraintSpecificationVisualFormat
#pragma mark -

@interface AKALayoutConstraintSpecificationVisualFormat ()

/**
 * The visual format specifying the constraints (see NSLayoutConstraint)
 */
@property(nonatomic) NSString* format;

/**
 * Options (see NSLayoutConstraint).
 */
@property(nonatomic) NSLayoutFormatOptions options;

@end

@implementation AKALayoutConstraintSpecificationVisualFormat

- (instancetype)initWithTarget:(UIView *)target
                  visualFormat:(NSString *)visualFormat
                       options:(NSLayoutFormatOptions)options
{
    self = [super initWithTarget:target];
    if (self)
    {
        self.format = visualFormat;
        self.options = options;
    }
    return self;
}

- (NSArray *)constraintsForViews:(NSDictionary *)views metrics:(NSDictionary *)metrics
{
    return [NSLayoutConstraint constraintsWithVisualFormat:self.format
                                                   options:self.options
                                                   metrics:metrics
                                                     views:views];
}

@end

#pragma mark - AKALayoutConstraintSpecificationExplicit
#pragma mark -

@interface AKALayoutConstraintSpecificationExplicit ()

@property(nonatomic) NSArray* firstItems;
@property(nonatomic) NSLayoutAttribute firstAttribute;
@property(nonatomic) NSLayoutRelation relatedBy;
@property(nonatomic) NSArray* secondItems;
@property(nonatomic) NSLayoutAttribute secondAttribute;
@property(nonatomic) CGFloat multiplier;
@property(nonatomic) CGFloat constant;
@property(nonatomic) int priority;

@end

@implementation AKALayoutConstraintSpecificationExplicit

- (instancetype)initWithTarget:(UIView *)target
                    firstItems:(NSArray *)firstItems
                firstAttribute:(NSLayoutAttribute)firstAttribute
                     relatedBy:(NSLayoutRelation)relation
                   secondItems:(NSArray *)secondItems
               secondAttribute:(NSLayoutAttribute)secondAttribute
                    multiplier:(CGFloat)multiplier
                      constant:(CGFloat)constant
                      priority:(int)priority
{
    self = [super initWithTarget:target];
    if (self)
    {
        self.firstItems = firstItems;
        self.firstAttribute = firstAttribute;
        self.relatedBy = relation;
        self.secondItems = secondItems;
        self.secondAttribute = secondAttribute;
        self.multiplier = multiplier;
        self.constant = constant;
        self.priority = priority;
    }
    return self;
}

- (NSArray *)constraintsForViews:(NSDictionary *)views
                         metrics:(NSDictionary *)metrics
{
    NSMutableArray* result = NSMutableArray.new;
    for (id firstItem in self.firstItems)
    {
        for (id secondItem in self.secondItems)
        {
            UIView* firstView = [self viewFromItemSpec:firstItem withViews:views];
            UIView* secondView = [self viewFromItemSpec:secondItem withViews:views];
            NSLayoutConstraint* constraint =
                [NSLayoutConstraint constraintWithItem:firstView
                                             attribute:self.firstAttribute
                                             relatedBy:self.relatedBy
                                                toItem:secondView
                                             attribute:self.secondAttribute
                                            multiplier:self.multiplier
                                              constant:self.constant];
            constraint.priority = self.priority;
            [result addObject:constraint];
        }
    }
    return result;
}

- (UIView*)viewFromItemSpec:(id)item withViews:(NSDictionary*)views
{
    UIView* result = nil;
    if ([item isKindOfClass:[NSString class]])
    {
        item = views[item];
    }

    if ([item isKindOfClass:[UIView class]])
    {
        result = (UIView*)item;
    }
    return result;
}

@end

#pragma mark - AKALayoutConstraintSpecificationExisting
#pragma mark -

@interface AKALayoutConstraintSpecificationExisting ()

@property(nonatomic) NSArray* constraints;

@end

@implementation AKALayoutConstraintSpecificationExisting

- (instancetype)initWithTarget:(UIView *)target constraints:(NSArray *)constraints
{
    self = [super initWithTarget:target];
    if (self)
    {
        self.constraints = constraints;
    }
    return self;
}

- (instancetype)initWithTarget:(UIView *)target constraint:(NSLayoutConstraint *)constraint
{
    self = [self initWithTarget:target constraints:@[ constraint ]];
    return self;
}

- (NSArray *)constraintsForViews:(NSDictionary *)views metrics:(NSDictionary *)metrics
{
    return self.constraints;
}

@end