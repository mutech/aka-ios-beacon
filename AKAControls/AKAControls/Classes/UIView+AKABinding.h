//
//  UIView+AKABinding.h
//  AKAControls
//
//  Created by Michael Utech on 31.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKAViewBinding;

/**
 * This category provides a weak link to the control view binding which binds the view to its control.
 * The reference is stored in associated storage.
 */
@interface UIView (AKABinding)

/**
 * The binding instance to which this view is bound.
 *
 * @note This property should not be changed manually, it is maintained
 * by its binding instance.
 */
@property(nonatomic, weak) AKAViewBinding* aka_binding;

@end
