//
//  UIView+AKAHierarchyVisitor.m
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "UIView+AKAHierarchyVisitor.h"

@implementation UIView (AKAHierarchyVisitor)

- (BOOL)enumerateSubviewsUsingBlock:(void(^)(UIView* view, BOOL* stop, BOOL* doNotDescend))visitor
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
            stop = ![view enumerateSubviewsUsingBlock:visitor];
        }
        if (stop) { break; }
    }
    return !stop;
}

- (BOOL)enumerateSelfAndSubviewsUsingBlock:(void(^)(UIView* view, BOOL* stop, BOOL* doNotDescend))visitor
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
            stop = ![self enumerateSubviewsUsingBlock:visitor];
        }
    }
    return !stop;
}

@end
