//
//  UIView+AKAConstraintTools.h
//  AKACommons
//
//  Created by Michael Utech on 16.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AKAConstraintTools)

- (NSArray*)removeConstraintsAffecting:(UIView*)view;

@end
