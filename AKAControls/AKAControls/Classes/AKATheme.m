//
//  AKATheme.m
//  AKAControls
//
//  Created by Michael Utech on 24.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATheme.h"
#import "AKAViewCustomization.h"
#import "AKAThemeLayout.h"
#import <AKACommons/UIView+AKAConstraintTools.h>

@interface AKATheme()<
        AKAViewCustomizationDelegate,
    AKAThemeLayoutDelegate
> {
    NSMutableArray* _viewCustomizations;
    NSMutableArray* _layouts;
}
@end

@implementation AKATheme

#pragma mark - Initialization

+ (instancetype)themeWithDictionary:(NSDictionary *)specification
{
    return [[self alloc] initWithDictionary:specification];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _viewCustomizations = NSMutableArray.new;
        _layouts = NSMutableArray.new;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)specification
{
    self = [self init];
    if (self)
    {
        [specification enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([@"views" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    NSString* viewName = key;
                    [(NSDictionary*)obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        if ([@"outlet" isEqualToString:key])
                        {
                            // TODO: implement
                        }
                        else if ([@"autocreate" isEqualToString:key])
                        {
                            // TODO: implement
                        }
                        else if ([@"customization" isEqualToString:key])
                        {
                            // TODO: refactor theme to use view configuration at toplevel
                            NSMutableDictionary* tmp = [NSMutableDictionary dictionaryWithDictionary:obj];
                            tmp[@"view"] = viewName;
                            [self addViewCustomizationWithDictionary:tmp];
                        }
                    }];
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
            else if ([@"metrics" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    [self setDefaultMetrics:obj];
                }
                else
                {
                    // TODO: error handling
                }
            }
            else if ([@"layouts" isEqualToString:key])
            {
                if ([obj isKindOfClass:[NSArray class]])
                {
                    [self addLayoutsWithArrayOfDictionaries:obj];
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

#pragma mark - View Customizations

- (NSArray *)viewCustomizations
{
    return [NSArray arrayWithArray:_viewCustomizations];
}

- (NSUInteger)addViewCustomizationsWithArrayOfDictionaries:(NSArray*)specifications
{
    NSUInteger count = 0;
    for (id spec in specifications)
    {
        if ([spec isKindOfClass:[NSDictionary class]])
        {
            id vc = [self addViewCustomizationWithDictionary:spec];
            if (vc != nil)
            {
                ++count;
            }
            else
            {
                // TODO: error handling
            }
        }
        else
        {
            // TODO: error handling
        }
    }
    return count;
}

- (AKAViewCustomization *)addViewCustomizationWithDictionary:(NSDictionary*)specification
{
    AKAViewCustomization * result = [[AKAViewCustomization alloc] initWithDictionary:specification];
    if (result != nil)
    {
        [self addViewCustomization:result];
    }
    return result;
}

- (void)addViewCustomization:(AKAViewCustomization *)viewCustomization
{
    [_viewCustomizations addObject:viewCustomization];
    //viewCustomization.delegate = self;
}

- (AKAViewCustomization *)customizeViewWithKey:(NSString*)key
                                       whereTypeIn:(NSArray*)validTypes
                                      andTypeNotIn:(NSArray*)invalidTypes
                                  modifyProperties:(NSDictionary*)propertyModifications
{
    // TODO: implement
    return nil;
}

#pragma mark - Layout Constraint Specifications

- (NSArray *)layouts
{
    return [NSArray arrayWithArray:_layouts];
}

- (NSUInteger)addLayoutsWithArrayOfDictionaries:(NSArray*)specifications
{
    NSUInteger count = 0;
    for (id spec in specifications)
    {
        if ([spec isKindOfClass:[NSDictionary class]])
        {
            id vc = [self addLayoutWithDictionary:spec];
            if (vc != nil)
            {
                ++count;
            }
            else
            {
                // TODO: error handling
            }
        }
        else
        {
            // TODO: error handling
        }
    }
    return count;
}

- (AKAThemeLayout*)addLayoutWithDictionary:(NSDictionary*)specification
{
    AKAThemeLayout* result = [[AKAThemeLayout alloc] initWithDictionary:specification];
    if (result != nil)
    {
        [self addLayout:result];
    }
    return result;
}

- (void)addLayout:(AKAThemeLayout*)layout
{
    if (layout.delegate != nil)
    {
        // TODO: error handling
    }
    [_layouts addObject:layout];
    layout.delegate = self;
}

#pragma mark - Application

- (void)applyToTarget:(UIView*)target
            withViews:(NSDictionary*)views
             delegate:(NSObject<AKAThemeDelegate>*)delegate
{
    if ([self shouldApplyViewCustomizations:self.viewCustomizations
                                    toViews:views
                                   delegate:delegate])
    {
        for (AKAViewCustomization * customization in self.viewCustomizations)
        {
            [customization applyToViews:views withContext:target delegate:delegate];
        }
    }

    [self willRemoveConstraintsDelegate:delegate];
    for (NSString* viewName in views.keyEnumerator)
    {
        UIView* view = views[viewName];

        NSArray* fromTarget = [target aka_constraintsAffectingView:view];
        if ([self shouldRemoveConstraints:&fromTarget
                            relatedToView:view
                                  withKey:viewName
                                  inViews:views
                               fromTarget:target
                                 delegate:delegate])
        {
            [target removeConstraints:fromTarget];
            [self didRemoveConstraints:fromTarget
                              fromView:target
                              delegate:delegate];
        }

        NSArray* fromView1 = [view aka_constraintsAffectingView:target];
        if ([self shouldRemoveConstraints:&fromView1
                          relatedToTarget:target
                                 fromView:view
                                  withKey:viewName
                                  inViews:views
                                 delegate:delegate])
        {
            [view removeConstraints:fromView1];
            [self didRemoveConstraints:fromView1
                              fromView:view
                              delegate:delegate];
        }

        NSArray* fromView2 = [view aka_constraintsAffectingOnlySelf];
        if ([self shouldRemoveConstraintsOnlyRelatedToSelf:&fromView2
                                                  fromView:view
                                                   withKey:viewName
                                                   inViews:views
                                                  delegate:delegate])
        {
            [view removeConstraints:fromView2];
            [self didRemoveConstraints:fromView2
                              fromView:view
                              delegate:delegate];
        }
    }
    [self didRemoveConstraintsDelegate:delegate];

    for (AKAThemeLayout* layout in self.layouts)
    {
        [layout applyToViews:views
          withDefaultMetrics:self.defaultMetrics
               defaultTarget:target
                withDelegate:delegate];
    }
}

- (BOOL)shouldApplyViewCustomizations:(NSArray*)customizations
                              toViews:(NSDictionary*)views
                             delegate:(NSObject<AKAThemeDelegate>*)delegate
{
    BOOL result = customizations.count > 0;
    if (result && [delegate respondsToSelector:@selector(theme:shouldApplyViewCustomizations:toViews:)])
    {
        result &= [delegate theme:self shouldApplyViewCustomizations:customizations toViews:views];
    }
    if (result && [self.delegate respondsToSelector:@selector(theme:shouldApplyViewCustomizations:toViews:)])
    {
        result &= [self.delegate theme:self shouldApplyViewCustomizations:customizations toViews:views];
    }
    return result;
}

- (void)willRemoveConstraintsDelegate:(NSObject<AKAThemeDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(themeWillRemoveConstraints:)])
    {
        [delegate themeWillRemoveConstraints:self];
    }
    if ([self.delegate respondsToSelector:@selector(themeWillRemoveConstraints:)])
    {
        [self.delegate themeWillRemoveConstraints:self];
    }
}

- (BOOL)shouldRemoveConstraints:(inout NSArray**)constraints
                  relatedToView:(UIView*)view
                        withKey:(NSString*)key
                        inViews:(NSDictionary*)views
                     fromTarget:(UIView*)target
                       delegate:(NSObject<AKAThemeDelegate>*)delegate
{
    BOOL result = YES;
    if (result && [delegate respondsToSelector:@selector(theme:shouldRemoveConstraints:relatedToView:withKey:inViews:fromTarget:)])
    {
        result &= [delegate theme:self
          shouldRemoveConstraints:constraints
                    relatedToView:view
                          withKey:key
                          inViews:views
                       fromTarget:target];
    }
    if (result && [self.delegate respondsToSelector:@selector(theme:shouldRemoveConstraints:relatedToView:withKey:inViews:fromTarget:)])
    {
        result &= [self.delegate theme:self
               shouldRemoveConstraints:constraints
                         relatedToView:view
                               withKey:key
                               inViews:views
                            fromTarget:target];
    }
    return result;
}

- (BOOL)shouldRemoveConstraints:(inout NSArray**)constraints
                relatedToTarget:(UIView*)target
                       fromView:(UIView*)view
                        withKey:(NSString*)key
                        inViews:(NSDictionary*)views
                       delegate:(NSObject<AKAThemeDelegate>*)delegate
{
    BOOL result = YES;
    if (result && [delegate respondsToSelector:@selector(theme:shouldRemoveConstraints:relatedToTarget:fromView:withKey:inViews:)])
    {
        result &= [delegate theme:self
          shouldRemoveConstraints:constraints
                  relatedToTarget:target
                         fromView:view
                          withKey:key
                          inViews:views];
    }
    if (result && [self.delegate respondsToSelector:@selector(theme:shouldRemoveConstraints:relatedToTarget:fromView:withKey:inViews:)])
    {
        result &= [self.delegate theme:self
               shouldRemoveConstraints:constraints
                       relatedToTarget:target
                              fromView:view
                               withKey:key
                               inViews:views];
    }
    return result;
}

- (BOOL)shouldRemoveConstraintsOnlyRelatedToSelf:(inout NSArray**)constraints
                                        fromView:(UIView*)view
                                         withKey:(NSString*)key
                                         inViews:(NSDictionary*)views
                                        delegate:(NSObject<AKAThemeDelegate>*)delegate
{
    BOOL result = YES;
    if (result && [delegate respondsToSelector:@selector(theme:shouldRemoveConstraintsOnlyRelatedToSelf:fromView:withKey:inViews:)])
    {
        result &= [delegate                 theme:self
         shouldRemoveConstraintsOnlyRelatedToSelf:constraints
                                         fromView:view
                                          withKey:key
                                          inViews:views];
    }
    if (result && [self.delegate respondsToSelector:@selector(theme:shouldRemoveConstraintsOnlyRelatedToSelf:fromView:withKey:inViews:)])
    {
        result &= [self.delegate                 theme:self
         shouldRemoveConstraintsOnlyRelatedToSelf:constraints
                                         fromView:view
                                          withKey:key
                                          inViews:views];
    }
    return result;
}

- (void)didRemoveConstraints:(NSArray*)constraints
                    fromView:(UIView*)view
                    delegate:(NSObject<AKAThemeDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(theme:didRemoveConstraints:fromView:)])
    {
        [delegate theme:self
   didRemoveConstraints:constraints
               fromView:view];
    }
    if ([self.delegate respondsToSelector:@selector(theme:didRemoveConstraints:fromView:)])
    {
        [self.delegate theme:self
   didRemoveConstraints:constraints
               fromView:view];
    }
}

- (void)didRemoveConstraintsDelegate:(NSObject<AKAThemeDelegate>*)delegate
{
    if ([delegate respondsToSelector:@selector(themeDidRemoveConstraints:)])
    {
        [delegate themeDidRemoveConstraints:self];
    }
    if ([self.delegate respondsToSelector:@selector(themeDidRemoveConstraints:)])
    {
        [self.delegate themeDidRemoveConstraints:self];
    }
}


#pragma mark - AKAThemeDelegate support

#pragma mark - AKAViewCustomizationDelegate

- (void)viewCustomizations:(AKAViewCustomization *)customization willBeAppliedToView:(id)view
{
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:willBeAppliedToView:)])
    {
        [self.delegate viewCustomizations:customization willBeAppliedToView:view];
    }
}

- (BOOL)viewCustomizations:(AKAViewCustomization *)customization shouldSetProperty:(NSString *)name value:(id)oldValue to:(id)newValue
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:shouldSetProperty:value:to:)])
    {
        result &= [self.delegate viewCustomizations:customization shouldSetProperty:name value:oldValue to:newValue];
    }
    return result;
}

- (void)viewCustomizations:(AKAViewCustomization *)customization didSetProperty:(NSString *)name value:(id)oldValue to:(id)newValue
{
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:didSetProperty:value:to:)])
    {
        [self.delegate viewCustomizations:customization didSetProperty:name value:oldValue to:newValue];
    }
}

- (void)viewCustomizations:(AKAViewCustomization *)customizations haveBeenAppliedToView:(id)view
{
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:haveBeenAppliedToView:)])
    {
        [self.delegate viewCustomizations:customizations haveBeenAppliedToView:view];
    }
}

#pragma mark - AKAThemeLayoutDelegate

- (void)                    layout:(AKAThemeLayout *)layout
      didCheckApplicabilityToViews:(NSDictionary *)views
                        withResult:(BOOL)result
{
    if ([self.delegate respondsToSelector:@selector(layout:didCheckApplicabilityToViews:withResult:)])
    {
        [self.delegate layout:layout
 didCheckApplicabilityToViews:views
                   withResult:result];
    }
}

- (void)      layout:(AKAThemeLayout *)layout
willBeAppliedToViews:(NSDictionary *)views
             metrics:(NSDictionary *)metrics
       defaultTarget:(UIView *)target
{
    if ([self.delegate respondsToSelector:@selector(layout:willBeAppliedToViews:metrics:defaultTarget:)])
    {
        [self.delegate layout:layout
         willBeAppliedToViews:views
                      metrics:metrics
                defaultTarget:target];
    }
}

- (void)       layout:(AKAThemeLayout *)layout
hasBeenAppliedToViews:(NSDictionary *)views
              metrics:(NSDictionary *)metrics
        defaultTarget:(UIView *)target
{
    if ([self.delegate respondsToSelector:@selector(layout:hasBeenAppliedToViews:metrics:defaultTarget:)])
    {
        [self.delegate layout:layout
        hasBeenAppliedToViews:views
                      metrics:metrics
                defaultTarget:target];
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


@implementation AKAThemeDelegateProxy

#pragma mark - AKAThemeDelegate Implementation

- (BOOL)                    theme:(AKATheme*)theme
    shouldApplyViewCustomizations:(NSArray*)viewCustomizations
                          toViews:(NSDictionary*)views
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(theme:shouldApplyViewCustomizations:toViews:)])
    {
        result = [self.delegate theme:theme
        shouldApplyViewCustomizations:viewCustomizations
                              toViews:views];
    }
    return result;
}

- (void)themeWillRemoveConstraints:(AKATheme*)theme
{
    if ([self.delegate respondsToSelector:@selector(themeWillRemoveConstraints:)])
    {
        [self.delegate themeWillRemoveConstraints:theme];
    }
}

- (BOOL)                    theme:(AKATheme*)theme
          shouldRemoveConstraints:(inout NSArray**)constraints
                    relatedToView:(UIView*)view
                          withKey:(NSString*)key
                          inViews:(NSDictionary*)views
                       fromTarget:(UIView*)target
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(theme:shouldRemoveConstraints:relatedToView:withKey:inViews:fromTarget:)])
    {
        result = [self.delegate theme:theme
              shouldRemoveConstraints:constraints
                        relatedToView:view
                              withKey:key
                              inViews:views
                           fromTarget:target];
    }
    return result;
}

- (BOOL)                    theme:(AKATheme*)theme
          shouldRemoveConstraints:(inout NSArray**)constraints
                  relatedToTarget:(UIView*)target
                         fromView:(UIView*)view
                          withKey:(NSString*)key
                          inViews:(NSDictionary*)views
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(theme:shouldRemoveConstraints:relatedToTarget:fromView:withKey:inViews:)])
    {
        result = [self.delegate theme:theme
              shouldRemoveConstraints:constraints
                      relatedToTarget:target
                             fromView:view
                              withKey:key
                              inViews:views];
    }
    return result;
}

- (BOOL)                    theme:(AKATheme*)theme
shouldRemoveConstraintsOnlyRelatedToSelf:(inout NSArray**)constraints
                         fromView:(UIView*)view
                          withKey:(NSString*)key
                          inViews:(NSDictionary*)views
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(theme:shouldRemoveConstraintsOnlyRelatedToSelf:fromView:withKey:inViews:)])
    {
        result = [self.delegate theme:theme
shouldRemoveConstraintsOnlyRelatedToSelf:constraints
                             fromView:view
                              withKey:key
                              inViews:views];
    }
    return result;
}

- (void)                    theme:(AKATheme*)theme
             didRemoveConstraints:(NSArray*)constraints
                         fromView:(UIView*)view
{
    if ([self.delegate respondsToSelector:@selector(theme:didRemoveConstraints:fromView:)])
    {
        [self.delegate theme:theme
        didRemoveConstraints:constraints
                    fromView:view];
    }
}

- (void)themeDidRemoveConstraints:(AKATheme*)theme
{
    if ([self.delegate respondsToSelector:@selector(themeDidRemoveConstraints:)])
    {
        [self.delegate themeDidRemoveConstraints:theme];
    }
}

#pragma mark - AKAThemeLayoutDelegate methods

- (void)                    layout:(AKAThemeLayout*)layout
      didCheckApplicabilityToViews:(NSDictionary*)views
                        withResult:(BOOL)result
{
    if ([self.delegate respondsToSelector:@selector(layout:didCheckApplicabilityToViews:withResult:)])
    {
        [self.delegate layout:layout didCheckApplicabilityToViews:views withResult:result];
    }
}

- (void)                    layout:(AKAThemeLayout *)layout
              willBeAppliedToViews:(NSDictionary *)views
                           metrics:(NSDictionary *)metrics
                     defaultTarget:(UIView *)target
{
    if ([self.delegate respondsToSelector:@selector(layout:willBeAppliedToViews:metrics:defaultTarget:)])
    {
        [self.delegate layout:layout
         willBeAppliedToViews:views
                      metrics:metrics
                defaultTarget:target];
    }
}

- (void)                    layout:(AKAThemeLayout *)layout
             hasBeenAppliedToViews:(NSDictionary *)views
                           metrics:(NSDictionary *)metrics
                     defaultTarget:(UIView *)target
{
    if ([self.delegate respondsToSelector:@selector(layout:hasBeenAppliedToViews:metrics:defaultTarget:)])
    {
        [self.delegate layout:layout
        hasBeenAppliedToViews:views
                      metrics:metrics
                defaultTarget:target];
    }
}

#pragma mark - AKALayoutConstraintSpecificationDelegate methods

- (BOOL)constraintSpecification:(AKALayoutConstraintSpecification*)constraintSpecification
       shouldInstallConstraints:(NSArray*)nsLayoutConstraints
                       inTarget:(UIView*)target
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(constraintSpecification:shouldInstallConstraints:inTarget:)])
    {
        result = [self.delegate constraintSpecification:constraintSpecification
                               shouldInstallConstraints:nsLayoutConstraints
                                               inTarget:target];
    }
    return result;
}

- (void)constraintSpecification:(AKALayoutConstraintSpecification*)constraintSpecification
         willInstallConstraints:(NSArray*)nsLayoutConstraints
                       inTarget:(UIView*)target
{
    if ([self.delegate respondsToSelector:@selector(constraintSpecification:willInstallConstraints:inTarget:)])
    {
        [self.delegate constraintSpecification:constraintSpecification
                        willInstallConstraints:nsLayoutConstraints
                                      inTarget:target];
    }
}

- (void)constraintSpecification:(AKALayoutConstraintSpecification*)constraintSpecification
          didInstallConstraints:(NSArray*)nsLayoutConstraints
                       inTarget:(UIView*)target
{
    if ([self.delegate respondsToSelector:@selector(constraintSpecification:didInstallConstraints:inTarget:)])
    {
        [self.delegate constraintSpecification:constraintSpecification
                         didInstallConstraints:nsLayoutConstraints
                                      inTarget:target];
    }
}

#pragma mark - AKAViewCustomizationDelegate methods

- (void)viewCustomizations:(AKAViewCustomization *)customization
       willBeAppliedToView:(id)view
{
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:willBeAppliedToView:)])
    {
        [self.delegate viewCustomizations:customization
                      willBeAppliedToView:view];
    }
}

- (BOOL)viewCustomizations:(AKAViewCustomization *)customization
         shouldSetProperty:(NSString*)name
                     value:(id)oldValue
                        to:(id)newValue
{
    BOOL result = YES;
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:shouldSetProperty:value:to:)])
    {
        result = [self.delegate viewCustomizations:customization
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
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:didSetProperty:value:to:)])
    {
        [self.delegate viewCustomizations:customization
                           didSetProperty:name
                                    value:oldValue
                                       to:newValue];
    }
}

- (void)viewCustomizations:(AKAViewCustomization *)customizations
     haveBeenAppliedToView:(id)view
{
    if ([self.delegate respondsToSelector:@selector(viewCustomizations:haveBeenAppliedToView:)])
    {
        [self.delegate viewCustomizations:customizations
                    haveBeenAppliedToView:view];
    }
}

@end

@interface AKAThemeChangeRecorderDelegate()

@property(nonatomic) AKAThemeLayout* currentlyRecordedLayout;
@property(nonatomic) AKAViewCustomization * currentlyRecordedViewCustomization;

@end

@implementation AKAThemeChangeRecorderDelegate

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.recordedTheme = [[AKATheme alloc] init];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<AKAThemeDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - AKAThemeDelegate

#pragma mark - Recording Modified View Properties

- (void)viewCustomizations:(AKAViewCustomization *)customization
       willBeAppliedToView:(id)view
{
    self.currentlyRecordedViewCustomization = [[AKAViewCustomization alloc] init];
    self.currentlyRecordedViewCustomization.viewKey = customization.viewKey;
    [super viewCustomizations:customization willBeAppliedToView:view];
}

- (void)viewCustomizations:(AKAViewCustomization *)customization
            didSetProperty:(NSString *)name
                     value:(id)oldValue
                        to:(id)newValue
{
    [self.currentlyRecordedViewCustomization addCustomizationSetValue:oldValue forPropertyName:name];
    [super viewCustomizations:customization didSetProperty:name value:oldValue to:newValue];
}

- (void)viewCustomizations:(AKAViewCustomization *)customizations
     haveBeenAppliedToView:(id)view
{
    [self.recordedTheme addViewCustomization:self.currentlyRecordedViewCustomization];
    self.currentlyRecordedViewCustomization = nil;
    [super viewCustomizations:customizations haveBeenAppliedToView:view];
}

#pragma mark - Recording Removed Constraints

- (void)themeWillRemoveConstraints:(AKATheme *)theme
{
    self.currentlyRecordedLayout = [[AKAThemeLayout alloc] init];
    [super themeWillRemoveConstraints:theme];
}

- (void)theme:(AKATheme *)theme didRemoveConstraints:(NSArray *)constraints fromView:(UIView *)view
{
    [self.currentlyRecordedLayout addConstraintSpecificationWithConstraints:constraints
                                                        forTarget:view];
    [super theme:theme didRemoveConstraints:constraints fromView:view];
}

- (void)themeDidRemoveConstraints:(AKATheme *)theme
{
    [self.recordedTheme addLayout:self.currentlyRecordedLayout];
    self.currentlyRecordedLayout = nil;
    [super themeDidRemoveConstraints:theme];
}

@end
