//
//  UIView+AKAHierarchyVisitor.m
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "UIView+AKAHierarchyVisitor.h"

@implementation UIView (AKAHierarchyVisitor)

- (BOOL)aka_enumerateSubviewsUsingBlock:(void(^)(UIView* view, BOOL* stop, BOOL* doNotDescend))visitor
{
    BOOL stop = NO;
    BOOL doNotDescend = NO;

    for (UIView* view in self.subviews)
    {
        visitor(view, &stop, &doNotDescend);
        if (stop) { break; }
        if (doNotDescend)
        {
            doNotDescend = NO;
        }
        else
        {
            stop = ![view aka_enumerateSubviewsUsingBlock:visitor];
        }
        if (stop) { break; }
    }
    return !stop;
}

- (BOOL)aka_enumerateSelfAndSubviewsUsingBlock:(void(^)(UIView* view, BOOL* stop, BOOL* doNotDescend))visitor
{
    BOOL stop = NO;
    BOOL doNotDescend = NO;

    visitor(self, &stop, &doNotDescend);
    if (!stop)
    {
        if (doNotDescend)
        {
            doNotDescend = NO;
        }
        else
        {
            stop = ![self aka_enumerateSubviewsUsingBlock:visitor];
        }
    }
    return !stop;
}

- (id)aka_superviewOfType:(Class)type
{
    return [self.superview aka_selfOrSuperviewOfType:type];
}

- (id)aka_selfOrSuperviewOfType:(Class)type
{
    UIView* result = nil;
    if ([self isKindOfClass:type])
    {
        result = self;
    }
    else
    {
        result = [self.superview aka_selfOrSuperviewOfType:type];
    }
    return result;
}

@end
