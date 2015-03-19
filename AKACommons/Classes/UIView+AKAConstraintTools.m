//
//  UIView+AKAConstraintTools.m
//  AKACommons
//
//  Created by Michael Utech on 16.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "UIView+AKAConstraintTools.h"

@implementation UIView (AKAConstraintTools)

- (NSArray *)aka_removeConstraintsAffecting:(UIView *)view
{
    NSMutableArray* constraintsToRemove = NSMutableArray.new;

    for (NSLayoutConstraint* constraint in self.constraints)
    {
        if (constraint.firstItem == view || constraint.secondItem == view)
        {
            [constraintsToRemove addObject:constraint];
        }
    }
    if (constraintsToRemove.count > 0)
    {
        [self removeConstraints:constraintsToRemove];
    }
    return constraintsToRemove;
}

@end
