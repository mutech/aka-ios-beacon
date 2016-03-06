//
//  AKAFormViewController.h
//  AKABeacon
//
//  Created by Michael Utech on 12.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAFormControl.h"

@interface AKAFormViewController: UIViewController<AKAControlDelegate>

#pragma mark - Configuration

@property(nonatomic, readonly) AKAFormControl* formControl;

- (void)                             initializeFormControl;
- (void)                        initializeFormControlTheme;
- (void)                      initializeFormControlMembers;

#pragma mark - Outlets

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

#pragma mark - Configuration

/**
 Used by scrollViewToVisible:animated: to extend the rectangle scrolled into the visible area
 for a view that becomes first responder. The default implementation adds 30pt above and 20pt
 below the frame rectangle of the specified view.

 @param firstResponder the view to be scrolled into the visible area of the screen.

 @return a rectangle in the view's superview's coordinate system.
 */
- (CGRect)friendlyFrameForFirstResponder:(UIView*)firstResponder;

@end

