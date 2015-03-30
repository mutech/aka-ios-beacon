//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATheme.h"
#import "AKAThemeLayout.h"


@interface AKAThemeLayout()<AKALayoutConstraintSpecificationDelegate>

@property(nonatomic)NSMutableDictionary* applicabilitiesByView;
@property(nonatomic)NSMutableArray* constraintSpecifications;

@end

@implementation AKAThemeLayout

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.constraintSpecifications = NSMutableArray.new;
        self.applicabilitiesByView = NSMutableDictionary.new;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([@"viewRequirements" isEqualToString:key])
            {
                NSDictionary* viewRequirements = obj;
                [viewRequirements enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    AKAThemeViewApplicability* applicability = [[AKAThemeViewApplicability alloc] initWithSpecification:obj];
                    [self requireView:key withApplicability:applicability];
                }];
            }
            else if ([@"constraints" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSArray class]])
                {
                    NSArray* constraintSpecifications = obj;
                    for (NSDictionary* specification in constraintSpecifications)
                    {
                        [self addConstraintSpecificationWithDictionary:specification];
                    }
                }
            }
        }];
    }
    return self;
}

#pragma mark - Application

- (BOOL)isApplicableToViews:(NSDictionary*)views
{
    __block BOOL result = YES;
    [self.applicabilitiesByView enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        AKAThemeViewApplicability* applicability = obj;
        UIView* view = views[key];
        result = [applicability isApplicableToView:view];
        if (!result)
        {
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)applyToViews:(NSDictionary*)views
  withDefaultMetrics:(NSDictionary*)defaultMetrics
       defaultTarget:(UIView*)target
{
    return [self applyToViews:views
           withDefaultMetrics:defaultMetrics
                defaultTarget:target
                 withDelegate:nil];
}

- (BOOL)applyToViews:(NSDictionary*)views
  withDefaultMetrics:(NSDictionary*)defaultMetrics
       defaultTarget:(UIView*)target
        withDelegate:(NSObject<AKAThemeLayoutDelegate>*)delegate
{
    BOOL result = [self isApplicableToViews:views];

    [self didCheckApplicabilityToViews:views
                            withResult:result
                              delegate:delegate];

    if (result)
    {
        NSDictionary* metrics = nil; //self.metrics;
        if (metrics == nil)
        {
            metrics = defaultMetrics;
        }
        else
        {
            NSMutableDictionary* tmp = [NSMutableDictionary dictionaryWithDictionary:defaultMetrics];
            for (NSString* key in metrics)
            {
                tmp[key] = metrics[key];
            }
            metrics = tmp;
        }

        [self willApplyToViews:views
                       metrics:metrics
                 defaultTarget:target
                      delegate:delegate];
        for (AKALayoutConstraintSpecification* constraintSpecification in self.constraintSpecifications)
        {
            [constraintSpecification installConstraintsForViews:views
                                                        metrics:metrics
                                                  defaultTarget:target
                                                       delegate:delegate];
        }
        [self didApplyToViews:views
                      metrics:metrics
                defaultTarget:target
                     delegate:delegate];
    }

    return result;
}

#pragma mark - Adding requirements

- (void)requireView:(NSString *)key
  withApplicability:(AKAThemeViewApplicability *)applicability
{
    self.applicabilitiesByView[key] = applicability;
}

- (void)requireView:(NSString *)key
         withTypeIn:(NSArray *)validTypes
       andTypeNotIn:(NSArray *)invalidTypes
{
    AKAThemeViewApplicability* applicability = [[AKAThemeViewApplicability alloc] initWithValidTypes:validTypes invalidTypes:invalidTypes requirePresent:YES];
    [self requireView:key withApplicability:applicability];
}

- (void)requireViewIsAbsent:(NSString *)key
{
    [self requireView:key withApplicability:[[AKAThemeViewApplicability alloc] initRequireAbsent]];
}

#pragma mark - Adding constraints

- (void)addConstraintSpecification:(AKALayoutConstraintSpecification*)constraintSpecification
{
    if (constraintSpecification.delegate != nil)
    {
        // TODO: error handling
    }
    [self.constraintSpecifications addObject:constraintSpecification];
    constraintSpecification.delegate = self;
}

- (void)addConstraintSpecificationWithDictionary:(NSDictionary *)dictionary
{
    AKALayoutConstraintSpecification* constraintSpecification =
            [AKALayoutConstraintSpecification constraintSpecificationWithDictionary:dictionary];
    [self addConstraintSpecification:constraintSpecification];
}

- (void)addConstraintSpecificationWithConstraint:(NSLayoutConstraint *)constraint
                                       forTarget:(id)target
{
    AKALayoutConstraintSpecification* constraintSpecification =
            [AKALayoutConstraintSpecification constraint:constraint
                                              withTarget:target];
    [self addConstraintSpecification:constraintSpecification];
}

- (void)addConstraintSpecificationWithConstraints:(NSArray *)constraints
                                        forTarget:(id)target
{
    AKALayoutConstraintSpecification* constraintSpecification =
            [AKALayoutConstraintSpecification constraints:constraints
                                               withTarget:target];
    [self addConstraintSpecification:constraintSpecification];
}

- (void)addConstraintSpecificationWithVisualFormat:(NSString *)visualFormat options:(NSLayoutFormatOptions)options
{
    return [self addConstraintSpecificationWithVisualFormat:visualFormat
                                                    options:options
                                                  forTarget:nil];
}

- (void)addConstraintSpecificationWithVisualFormat:(NSString *)visualFormat
                                           options:(NSLayoutFormatOptions)options
                                         forTarget:(id)target
{
    AKALayoutConstraintSpecification* constraintSpecification =
            [AKALayoutConstraintSpecification constraintSpecificationWithTarget:target
                                                                   visualFormat:visualFormat
                                                                        options:options];
    [self addConstraintSpecification:constraintSpecification];
}

- (void)addConstraintSpecificationWithFirstItems:(NSArray *)firstItems
                                  firstAttribute:(NSLayoutAttribute)firstAttribute
                                       relatedBy:(NSLayoutRelation)relation
                                     secondItems:(NSArray *)secondItems
                                 secondAttribute:(NSLayoutAttribute)secondAttribute
                                      multiplier:(CGFloat)multiplier
                                        constant:(CGFloat)constant
                                        priority:(int)priority
                                       forTarget:(id)target
{
    AKALayoutConstraintSpecification *constraintSpecification =
            [AKALayoutConstraintSpecification constraintSpecificationWithTarget:target
                                                                     firstItems:firstItems
                                                                 firstAttribute:firstAttribute
                                                                      relatedBy:relation
                                                                    secondItems:secondItems
                                                                secondAttribute:secondAttribute
                                                                     multiplier:multiplier
                                                                       constant:constant
                                                                       priority:priority];
    [self addConstraintSpecification:constraintSpecification];
}

#pragma mark - AKAThemeLayoutDelegate support

- (void)didCheckApplicabilityToViews:(NSDictionary*)views
                          withResult:(BOOL)result
                            delegate:(NSObject<AKAThemeLayoutDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(layout:didCheckApplicabilityToViews:withResult:)])
    {
        [delegate layout:self didCheckApplicabilityToViews:views withResult:result];
    }
    if ([self.delegate respondsToSelector:@selector(layout:didCheckApplicabilityToViews:withResult:)])
    {
        [self.delegate layout:self didCheckApplicabilityToViews:views withResult:result];
    }
}

- (void)willApplyToViews:(NSDictionary*)views
                 metrics:(NSDictionary*)metrics
           defaultTarget:(UIView*)defaultTarget
                delegate:(NSObject<AKAThemeLayoutDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(layout:willBeAppliedToViews:metrics:defaultTarget:)])
    {
        [delegate layout:self willBeAppliedToViews:views metrics:metrics defaultTarget:defaultTarget];
    }
    if ([self.delegate respondsToSelector:@selector(layout:willBeAppliedToViews:metrics:defaultTarget:)])
    {
        [self.delegate layout:self willBeAppliedToViews:views metrics:metrics defaultTarget:defaultTarget];
    }
}

- (void)didApplyToViews:(NSDictionary*)views
                metrics:(NSDictionary*)metrics
          defaultTarget:(UIView*)defaultTarget
               delegate:(NSObject<AKAThemeLayoutDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(layout:hasBeenAppliedToViews:metrics:defaultTarget:)])
    {
        [delegate layout:self hasBeenAppliedToViews:views metrics:metrics defaultTarget:defaultTarget];
    }
    if ([self.delegate respondsToSelector:@selector(layout:hasBeenAppliedToViews:metrics:defaultTarget:)])
    {
        [self.delegate layout:self hasBeenAppliedToViews:views metrics:metrics defaultTarget:defaultTarget];
    }
}

#pragma mark - AKALayoutConstraintDelegate

- (BOOL)constraintSpecification:(AKALayoutConstraintSpecification *)constraintSpecification
       shouldInstallConstraints:(NSArray *)nsLayoutConstraints
                       inTarget:(UIView *)target
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(constraintSpecification:shouldInstallConstraints:inTarget:)])
    {
        result &= [self.delegate constraintSpecification:constraintSpecification
                                shouldInstallConstraints:nsLayoutConstraints
                                                inTarget:target];
    }
    return result;
}

- (void)constraintSpecification:(AKALayoutConstraintSpecification *)constraintSpecification
         willInstallConstraints:(NSArray *)nsLayoutConstraints
                       inTarget:(UIView *)target
{
    if ([self.delegate respondsToSelector:@selector(constraintSpecification:willInstallConstraints:inTarget:)])
    {
        [self.delegate constraintSpecification:constraintSpecification
                        willInstallConstraints:nsLayoutConstraints
                                      inTarget:target];
    }
}

- (void)constraintSpecification:(AKALayoutConstraintSpecification *)constraintSpecification
          didInstallConstraints:(NSArray *)nsLayoutConstraints
                       inTarget:(UIView *)target
{
    if ([self.delegate respondsToSelector:@selector(constraintSpecification:didInstallConstraints:inTarget:)])
    {
        [self.delegate constraintSpecification:constraintSpecification
                         didInstallConstraints:nsLayoutConstraints
                                      inTarget:target];
    }
}

@end

