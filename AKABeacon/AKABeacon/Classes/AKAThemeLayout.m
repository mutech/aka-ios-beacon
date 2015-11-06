//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
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
            (void)stop; // not needed
            if ([@"viewRequirements" isEqualToString:key])
            {
                NSDictionary* viewRequirements = obj;
                [viewRequirements enumerateKeysAndObjectsUsingBlock:^(id innerKey, id innerObj, BOOL *innerStop) {
                    (void)innerStop;
                    AKAThemeViewApplicability* applicability = [[AKAThemeViewApplicability alloc] initWithSpecification:innerObj];
                    [self requireView:innerKey withApplicability:applicability];
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
            else if ([@"viewCustomization" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSArray class]])
                {
                    [self addViewCustomizationsWithArrayOfDictionaries:obj];
                }
                else
                {
                    // TODO: error handling
                }
            }
        }];
    }
    return self;
}

#pragma mark - View Customizations Container Support

- (NSObject<AKAViewCustomizationDelegate> *)viewCustomizationDelegate
{
    return self.delegate;
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
        // View customizations first (no particular reason):
        [self applyViewCustomizationsToTarget:target
                                    withViews:views
                                     delegate:self.viewCustomizationDelegate];

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
    NSObject<AKAThemeLayoutDelegate>* selfDelegate = self.delegate;
    if ([selfDelegate respondsToSelector:@selector(layout:didCheckApplicabilityToViews:withResult:)])
    {
        [selfDelegate layout:self didCheckApplicabilityToViews:views withResult:result];
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
    NSObject<AKAThemeLayoutDelegate>* selfDelegate = self.delegate;
    if ([selfDelegate respondsToSelector:@selector(layout:willBeAppliedToViews:metrics:defaultTarget:)])
    {
        [selfDelegate layout:self willBeAppliedToViews:views metrics:metrics defaultTarget:defaultTarget];
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
    NSObject<AKAThemeLayoutDelegate>* selfDelegate = self.delegate;
    if ([selfDelegate respondsToSelector:@selector(layout:hasBeenAppliedToViews:metrics:defaultTarget:)])
    {
        [selfDelegate layout:self hasBeenAppliedToViews:views metrics:metrics defaultTarget:defaultTarget];
    }
}

#pragma mark - AKALayoutConstraintDelegate

- (BOOL)constraintSpecification:(AKALayoutConstraintSpecification *)constraintSpecification
       shouldInstallConstraints:(NSArray *)nsLayoutConstraints
                       inTarget:(UIView *)target
{
    BOOL result = YES;
    NSObject<AKAThemeLayoutDelegate>* selfDelegate = self.delegate;
    if ([selfDelegate respondsToSelector:@selector(constraintSpecification:shouldInstallConstraints:inTarget:)])
    {
        result &= [selfDelegate constraintSpecification:constraintSpecification
                                shouldInstallConstraints:nsLayoutConstraints
                                                inTarget:target];
    }
    return result;
}

- (void)constraintSpecification:(AKALayoutConstraintSpecification *)constraintSpecification
         willInstallConstraints:(NSArray *)nsLayoutConstraints
                       inTarget:(UIView *)target
{
    NSObject<AKAThemeLayoutDelegate>* selfDelegate = self.delegate;
    if ([selfDelegate respondsToSelector:@selector(constraintSpecification:willInstallConstraints:inTarget:)])
    {
        [selfDelegate constraintSpecification:constraintSpecification
                        willInstallConstraints:nsLayoutConstraints
                                      inTarget:target];
    }
}

- (void)constraintSpecification:(AKALayoutConstraintSpecification *)constraintSpecification
          didInstallConstraints:(NSArray *)nsLayoutConstraints
                       inTarget:(UIView *)target
{
    NSObject<AKAThemeLayoutDelegate>* selfDelegate = self.delegate;
    if ([selfDelegate respondsToSelector:@selector(constraintSpecification:didInstallConstraints:inTarget:)])
    {
        [selfDelegate constraintSpecification:constraintSpecification
                         didInstallConstraints:nsLayoutConstraints
                                      inTarget:target];
    }
}

#pragma mark - AKAViewCustomizationDelegate methods

- (void)viewCustomizations:(AKAViewCustomization *)customization
       willBeAppliedToView:(id)view
{
    NSObject<AKAThemeLayoutDelegate>* selfDelegate = self.delegate;
    if ([selfDelegate respondsToSelector:@selector(viewCustomizations:willBeAppliedToView:)])
    {
        [selfDelegate viewCustomizations:customization
                      willBeAppliedToView:view];
    }
}

- (BOOL)viewCustomizations:(AKAViewCustomization *)customization
         shouldSetProperty:(NSString*)name
                     value:(id)oldValue
                        to:(id)newValue
{
    BOOL result = YES;
    NSObject<AKAThemeLayoutDelegate>* selfDelegate = self.delegate;
    if ([selfDelegate respondsToSelector:@selector(viewCustomizations:shouldSetProperty:value:to:)])
    {
        result = [selfDelegate viewCustomizations:customization
                                 shouldSetProperty:name
                                             value:oldValue
                                                to:newValue];
    }
    return result;
}

- (void)viewCustomizations:(AKAViewCustomization *)customization
            didSetProperty:(NSString *)name
                     value:(id)oldValue
                        to:(id)newValue
{
    NSObject<AKAThemeLayoutDelegate>* selfDelegate = self.delegate;
    if ([selfDelegate respondsToSelector:@selector(viewCustomizations:didSetProperty:value:to:)])
    {
        [selfDelegate viewCustomizations:customization
                           didSetProperty:name
                                    value:oldValue
                                       to:newValue];
    }
}

- (void)viewCustomizations:(AKAViewCustomization *)customizations
     haveBeenAppliedToView:(id)view
{
    NSObject<AKAThemeLayoutDelegate>* selfDelegate = self.delegate;
    if ([selfDelegate respondsToSelector:@selector(viewCustomizations:haveBeenAppliedToView:)])
    {
        [selfDelegate viewCustomizations:customizations
                    haveBeenAppliedToView:view];
    }
}

@end

