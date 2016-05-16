//
//  UIView+AKAReusableViewsSupport.h
//
//  Created by Michael Utech on 11.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AKAReusableViewsSupport)

/**
 * Checks if the self has no subviews and if so, tries to load
 * the associated NIB file. If a matching view is found, this
 * view is configured using self as template (copying autoresizing settings and autolayout constraints).
 *
 * @return self, if self has subviews or no matching nib or view was found, or a view loaded from the associated NIB configured to replace self.
 */
- (instancetype)aka_viewFromNibOrSelf;

@end
