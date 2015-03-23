//
//  UIView+AKAConstraintTools.m
//  AKACommons
//
//  Created by Michael Utech on 16.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "UIView+AKAConstraintTools.h"

@implementation UIView (AKAConstraintTools)

- (BOOL)aka_isAffectedByConstraint:(NSLayoutConstraint*)constraint
{
    return constraint.firstItem == self || constraint.secondItem == self;
}

- (BOOL)aka_isTheOnlyViewDirectlyAffectedBy:(NSLayoutConstraint*)constraint
{
    return (constraint.firstItem == self && \
            constraint.class == [NSLayoutConstraint class] && \
            (constraint.secondItem == self || constraint.secondItem == nil));
}

- (NSArray*)aka_constraintsAffectingView:(UIView*)view
{
    NSMutableArray* result = NSMutableArray.new;
    for (NSLayoutConstraint* constraint in self.constraints)
    {
        if ([view aka_isAffectedByConstraint:constraint])
        {
            [result addObject:constraint];
        }
    }
    return result;
}

- (NSArray*)aka_constraintsAffectingOnlySelf
{
    NSMutableArray* result = NSMutableArray.new;
    for (NSLayoutConstraint* constraint in self.constraints)
    {
        if ([self aka_isTheOnlyViewDirectlyAffectedBy:constraint])
        {
            [result addObject:constraint];
        }
    }
    return result;
}

- (NSArray*)aka_constraintsAffectingViews:(NSArray*)views
{
    NSMutableArray* result = NSMutableArray.new;
    for (NSLayoutConstraint* constraint in self.constraints)
    {
        for (UIView* view in views)
        {
            if ([view aka_isAffectedByConstraint:constraint])
            {
                [result addObject:constraint];
            }
        }
    }
    return result;
}

- (NSArray *)aka_removeConstraintsAffectingOnlySelf
{
    NSArray* constraintsToRemove = [self aka_constraintsAffectingOnlySelf];
    [self removeConstraints:constraintsToRemove];
    return constraintsToRemove;
}

- (NSArray *)aka_removeConstraintsAffectingView:(UIView *)view
{
    NSArray* constraintsToRemove = [self aka_constraintsAffectingView:view];
    [self removeConstraints:constraintsToRemove];
    return constraintsToRemove;
}

- (NSArray *)aka_removeConstraintsAffectingViews:(NSArray *)views
{
    NSArray* constraintsToRemove =  [self aka_constraintsAffectingViews:views];
    [self removeConstraints:constraintsToRemove];
    return constraintsToRemove;
}

#pragma mark - Themes

- (NSDictionary*)aka_applyTheme:(NSDictionary*)themeSpecification
               toViews:(NSDictionary*)views
{
    NSMutableArray* removedConstraints = NSMutableArray.new;
    NSMutableArray* addedConstraints = NSMutableArray.new;

    NSDictionary* viewCustomization = themeSpecification[@"viewCustomization"];
    for (NSString* viewName in views.keyEnumerator)
    {
        UIView* view = views[viewName];
        if (view != nil)
        {
            NSDictionary* customization = viewCustomization[viewName];
            if (customization != nil)
            {
                for (NSString* property in customization.keyEnumerator)
                {
                    id value = customization[property];
                    [view setValue:value forKey:property];
                }
            }
        }
    }

    NSDictionary* defaultMetrics = themeSpecification[@"metrics"];
    NSArray* layouts = themeSpecification[@"layouts"];
    for (NSDictionary* layout in layouts)
    {
        BOOL applicable = YES;
        NSArray* requiredViews = layout[@"requiredViews"];
        for (NSString* viewName in requiredViews)
        {
            if (views[viewName] == nil)
            {
                applicable = NO;
                break;
            }
        }

        if (applicable)
        {
            NSDictionary* metrics = layout[@"metrics"];
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
            for (UIView* view in views.objectEnumerator)
            {
                // TODO: record target from which constraints have been removed:
                [removedConstraints addObjectsFromArray:[self aka_removeConstraintsAffectingView:view]];
                [removedConstraints addObjectsFromArray:[view aka_removeConstraintsAffectingView:self]];
                [removedConstraints addObjectsFromArray:[view aka_removeConstraintsAffectingOnlySelf]];
            }
            for (NSDictionary* constraintSpec in layout[@"constraints"])
            {
                NSArray* constraints = [self aka_constraintsForSpecification:constraintSpec
                                                                       views:views
                                                                     metrics:metrics];
                [self addConstraints:constraints];
                [addedConstraints addObjectsFromArray:constraints];
            }

            break;
        }
    }
    return NSDictionaryOfVariableBindings(addedConstraints, removedConstraints);
}

- (NSArray*)aka_constraintsForSpecification:(NSDictionary*)specification
                                      views:(NSDictionary*)views
                                    metrics:(NSDictionary*)metrics
{
    NSArray* result = nil;
    NSString* visualFormat = specification[@"format"];
    if (visualFormat)
    {
        NSLayoutFormatOptions options = ((NSNumber*)specification[@"options"]).unsignedIntegerValue;

        result = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                         options:options
                                                         metrics:metrics
                                                           views:views];
    }
    else
    {
        NSMutableArray* constraints = NSMutableArray.new;

        NSArray* firstItems = specification[@"firstItems"];
        if (firstItems == nil)
        {
            NSString* item = specification[@"firstItem"];
            if (item)
            {
                firstItems = @[ @{ @"item": item } ];
            }
        }
        NSArray* secondItems = specification[@"secondItems"];
        if (secondItems == nil)
        {
            NSString* item = specification[@"secondItem"];
            if (item)
            {
                secondItems = @[ @{ @"item": item } ];
            }
        }

        for (NSDictionary* firstItemSpec in firstItems)
        {
            for (NSDictionary* secondItemSpec in secondItems)
            {
                UIView* firstItem = [self resolveConstraintItem:firstItemSpec[@"item"]
                                                        inViews:views];
                NSNumber* firstAttribute = [self resolveKey:@"firstAttribute"
                                                      inTop:specification
                                                      first:firstItemSpec
                                                     second:secondItemSpec];
                UIView* secondItem = [self resolveConstraintItem:secondItemSpec[@"item"]
                                                         inViews:views];
                NSNumber* secondAttribute = [self resolveKey:@"secondAttribute"
                                                      inTop:specification
                                                      first:firstItemSpec
                                                     second:secondItemSpec];
                NSNumber* relatedBy = [self resolveKey:@"secondAttribute"
                                                        inTop:specification
                                                        first:firstItemSpec
                                                       second:secondItemSpec];
                relatedBy = @([self resolveConstraintRelation:relatedBy]);
                NSNumber* constant = [self resolveKey:@"constant"
                                                inTop:specification first:firstItemSpec second:secondItemSpec];
                constant = [self resolveConstraintValue:constant
                                              inMetrics:metrics];
                NSNumber* multiplier = [self resolveKey:@"multiplier"
                                                  inTop:specification first:firstItemSpec second:secondItemSpec];
                if (multiplier == nil)
                {
                    multiplier = @1;
                }
                NSNumber* priority = [self resolveKey:@"priority"
                                               inTop:specification
                                               first:firstItemSpec
                                              second:secondItemSpec];
                priority = [self resolveConstraintValue:priority
                                             inMetrics:metrics];

                NSLayoutConstraint* constraint =
                    [NSLayoutConstraint constraintWithItem:firstItem
                                                 attribute:firstAttribute.intValue
                                                 relatedBy:relatedBy.intValue
                                                    toItem:secondItem
                                                 attribute:secondAttribute.intValue
                                                multiplier:multiplier.doubleValue
                                                  constant:constant.doubleValue];
                if ([priority isKindOfClass:[NSNumber class]])
                {
                    constraint.priority = ((NSNumber*)priority).intValue;
                }
                [constraints addObject:constraint];

            }
        }

        if (constraints.count > 0)
        {
            result = constraints;
        }
    }
    return result;
}

- (id)resolveKey:(NSString*)key
                  inTop:(NSDictionary*)toplevel
                  first:(NSDictionary*)firstItemSpec
                 second:(NSDictionary*)secondItemSpec
{
    NSParameterAssert(firstItemSpec[key] == nil || secondItemSpec[key] == nil);

    id result = toplevel[key];
    id firstValue = firstItemSpec[key];
    id secondValue = secondItemSpec[key];

    if (firstValue != nil)
    {
        result = firstValue;
    }
    else if (secondValue != nil)
    {
        result = secondValue;
    }
    return result;
}


- (NSLayoutRelation)resolveConstraintRelation:(id)relation
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
            // TODO: error handling
        }
    }
    else if ([relation isKindOfClass:[NSNumber class]])
    {
        result = ((NSNumber*)relation).unsignedIntegerValue;
    }
    else
    {
        // TODO: error handling
    }
    return result;
}

- (UIView*)resolveConstraintItem:(id)item inViews:(NSDictionary*)views
{
    UIView* result = nil;
    if ([item isKindOfClass:[UIView class]])
    {
        result = item;
    }
    else
    {
        result = views[item];
    }
    return result;
}

- (NSNumber*)resolveConstraintValue:(id)value inMetrics:(NSDictionary*)metrics
{
    NSNumber* result;
    if ([value isKindOfClass:[NSNumber class]])
    {
        result = value;
    }
    else
    {
        result = metrics[value];
    }
    return result;
}

@end
