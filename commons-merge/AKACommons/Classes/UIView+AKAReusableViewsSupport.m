//
//  UIView+AKAReusableViewsSupport.m
//
//  Created by Michael Utech on 11.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIView+AKAReusableViewsSupport.h"

@implementation UIView (AKAReusableViewsSupport)

- (instancetype)aka_viewFromNibOrSelf
{
    id result = self;
    if (self.subviews.count == 0)
    {
        // Acquire the bundle from which to load the nib. Instead of the main bundle, we
        // use the bundle containing this view.
        // TODO: consider trying main bundle first and falling back to native bundle to allow users to override the NIB.
        NSBundle* bundle = [NSBundle bundleForClass:self.class];

        // Use the class name as NIB name.
        // TODO: consider making the NIB name customizable to allow users to override the NIB or use different NIBs.
        NSString* nibName = NSStringFromClass(self.class);

        // Load the NIB.
        // TODO: consider using UINIB and caching intermediate results.
        // TODO: instead of just taking the first object, try to find the best match.
        UIView* view = [bundle loadNibNamed:nibName
                                      owner:nil
                                    options:0].firstObject;

        // Check if we found a usable view
        if ([view isKindOfClass:self.class])
        {
            // Copy frame
            view.frame = self.frame;

            // Copy auto resizing configuration
            view.autoresizingMask = self.autoresizingMask;
            view.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints;

            // Copy autolayout constraints
            for (NSLayoutConstraint *constraint in self.constraints)
            {
                id firstItem = constraint.firstItem;
                if (firstItem == self)
                {
                    firstItem = view;
                }
                id secondItem = constraint.secondItem;
                if (secondItem == self)
                {
                    secondItem = view;
                }
                [view addConstraint:[NSLayoutConstraint constraintWithItem:firstItem
                                                                 attribute:constraint.firstAttribute
                                                                 relatedBy:constraint.relation
                                                                    toItem:secondItem
                                                                 attribute:constraint.secondAttribute
                                                                multiplier:constraint.multiplier
                                                                  constant:constraint.constant]];
            }
            result = view;
        }
    }
    return result;
}

@end
