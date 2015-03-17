//
//  UIView+AKAHierarchyVisitor.h
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIView (AKAHierarchyVisitor)

- (BOOL)enumerateSubviewsUsingBlock:(void(^)(UIView* view, BOOL* stop, BOOL* doNotDescend))visitor;

- (BOOL)enumerateSelfAndSubviewsUsingBlock:(void(^)(UIView* view, BOOL* stop, BOOL* doNotDescend))visitor
;

@end
