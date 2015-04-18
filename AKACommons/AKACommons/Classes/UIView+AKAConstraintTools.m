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
    NSDictionary* result = @{ @"viewCustomization": NSMutableArray.new,
                              @"layouts": @[ @{ @"constraints": removedConstraints } ]
                              };

    NSMutableArray* addedConstraints = NSMutableArray.new;

    NSArray* viewCustomization = themeSpecification[@"viewCustomization"];
    for (NSDictionary* customization in viewCustomization)
    {
        id viewSpec = customization[@"view"];
        UIView* view = [self resolveViewSpecification:viewSpec
                                             inViews:views];
        NSDictionary* requirements = customization[@"requirements"];
        if ([view aka_viewSatisfiesRequirements:requirements])
        {

            NSDictionary* properties = (NSDictionary*)customization[@"properties"];
            NSMutableDictionary* modifiedProperties = NSMutableDictionary.new;
            for (NSString* property in properties.keyEnumerator)
            {
                id oldValue = [view valueForKey:property];
                oldValue = (oldValue == nil) ? [NSNull null] : oldValue;
                modifiedProperties[property] = oldValue;

                id value = properties[property];
                value = (value == [NSNull null]) ? nil : value;
                [view setValue:value forKey:property];
            }
            if (modifiedProperties.count > 0)
            {
                [(NSMutableArray*)result[@"viewCustomization"] addObject:@{ @"view": viewSpec, @"properties": modifiedProperties }];
            }
        }
    }


    for (NSString* viewName in views.keyEnumerator)
    {
        UIView* view = views[viewName];

        NSArray* fromSelf = [self aka_removeConstraintsAffectingView:view];
        NSArray* fromView1 = [view aka_removeConstraintsAffectingView:self];
        NSArray* fromView2 = [view aka_removeConstraintsAffectingOnlySelf];

        if (fromSelf.count > 0)
        {
            [removedConstraints addObject:@{ @"constraints": fromSelf }];
        }
        if (fromView1.count > 0)
        {
            [removedConstraints addObject:@{ @"constraints": fromView1, @"target": viewName }];
        }
        if (fromView2.count > 0)
        {
            [removedConstraints addObject:@{ @"constraints": fromView2, @"target": viewName }];
        }
    }

    NSDictionary* defaultMetrics = themeSpecification[@"metrics"];
    NSArray* layouts = themeSpecification[@"layouts"];
    for (NSDictionary* layout in layouts)
    {
        BOOL applicable = [self aka_views:views statisfyRequirements:layout[@"viewRequirements"]];
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
            for (NSDictionary* constraintSpec in layout[@"constraints"])
            {
                NSArray* constraints = [self aka_addConstraintsForSpecification:constraintSpec
                                                                          views:views
                                                                        metrics:metrics];
                if (constraints.count > 0)
                {
                    [addedConstraints addObjectsFromArray:constraints];
                }
            }
        }
    }
    return result;
}

- (BOOL)aka_viewSatisfiesRequirements:(NSDictionary*)requirements
{
    BOOL result = YES;
    UIView* view = self;

    id typeSpec = requirements[@"type"];
    if (result && [typeSpec isKindOfClass:[NSArray class]])
    {
        result = NO;
        for (Class type in ((NSArray*)typeSpec))
        {
            result |= [view isKindOfClass:type];
        }
    }
    else if ([typeSpec respondsToSelector:@selector(superclass)])
    {
        result &= [view isKindOfClass:typeSpec];
    }

    id notTypeSpec = requirements[@"notType"];
    if ([notTypeSpec isKindOfClass:[NSArray class]])
    {
        for (Class type in ((NSArray*)notTypeSpec))
        {
            result &= ![view isKindOfClass:type];
        }
    }
    else if ([notTypeSpec respondsToSelector:@selector(superclass)])
    {
        result &= ![view isKindOfClass:notTypeSpec];
    }

    return result;
}

- (BOOL)aka_views:(NSDictionary*)views statisfyRequirements:(NSDictionary*)requirementsByViewName
{
    BOOL result = YES;

    for (NSString* viewName in requirementsByViewName.keyEnumerator)
    {
        id spec = requirementsByViewName[viewName];
        id view = views[viewName];

        if ([spec isKindOfClass:[NSNumber class]])
        {
            BOOL value = ((NSNumber*)spec).boolValue;
            result &= (value == (view != nil));
        }
        else if ([spec isKindOfClass:[NSDictionary class]] && [view isKindOfClass:[UIView class]])
        {
            result &= [((UIView*)view)aka_viewSatisfiesRequirements:spec];
        }
        if (!result)
        {
            break;
        }
    }
    return result;
}

- (NSArray*)aka_addConstraintsForSpecification:(NSDictionary*)specification
                                      views:(NSDictionary*)views
                                    metrics:(NSDictionary*)metrics
{
    NSArray* result = [self aka_constraintsForSpecification:specification views:views metrics:metrics];

    if (result.count > 0)
    {
        // target is the view where constraints will be added
        UIView* target = [self resolveViewSpecification:specification[@"target"] inViews:views];
        if (target == nil)
        {
            target = self;
        }
        [target addConstraints:result];
    }

    return result;
}

- (NSArray*)aka_constraintsForSpecification:(NSDictionary*)specification
                                      views:(NSDictionary*)views
                                    metrics:(NSDictionary*)metrics
{
    NSArray* result = nil;

    if (specification[@"format"] != nil)
    {
        NSLayoutFormatOptions options = ((NSNumber*)specification[@"options"]).unsignedIntegerValue;

        result = [NSLayoutConstraint constraintsWithVisualFormat:specification[@"format"]
                                                         options:options
                                                         metrics:metrics
                                                           views:views];
    }
    else if (specification[@"firstItem"] != nil || specification[@"firstItems"] != nil)
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
                UIView* firstItem = [self resolveViewSpecification:firstItemSpec[@"item"]
                                                        inViews:views];
                NSNumber* firstAttribute = [self resolveKey:@"firstAttribute"
                                                      inTop:specification
                                                      first:firstItemSpec
                                                     second:secondItemSpec];
                UIView* secondItem = [self resolveViewSpecification:secondItemSpec[@"item"]
                                                         inViews:views];
                NSNumber* secondAttribute = [self resolveKey:@"secondAttribute"
                                                      inTop:specification
                                                      first:firstItemSpec
                                                     second:secondItemSpec];
                NSNumber* relatedBy = [self resolveKey:@"relatedBy"
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
                                                multiplier:multiplier.floatValue
                                                  constant:constant.floatValue];
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
    else if (specification[@"constraint"] != nil)
    {
        result = @[ specification[@"constraint"] ];
    }
    else if (specification[@"constraints"] != nil)
    {
        result = specification[@"constraints"];
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
        result = ((NSNumber*)relation).intValue;
    }
    else
    {
        // TODO: error handling
    }
    return result;
}

- (UIView*)resolveViewSpecification:(id)item inViews:(NSDictionary*)views
{
    UIView* result = nil;
    if ([item isKindOfClass:[UIView class]])
    {
        result = item;
    }
    else if ([item isKindOfClass:[NSString class]])
    {
        result = views[item];
        if (result == nil && [@"self" isEqualToString:item])
        {
            result = self;
        }
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
