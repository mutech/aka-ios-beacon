//
//  UIView+AKAHierarchyVisitor.h
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIView (AKAHierarchyVisitor)

- (BOOL)aka_enumerateSubviewsUsingBlock:(void(^)(UIView* view, BOOL* stop, BOOL* doNotDescend))visitor;

- (BOOL)aka_enumerateSelfAndSubviewsUsingBlock:(void(^)(UIView* view, BOOL* stop, BOOL* doNotDescend))visitor
;

- (id)aka_superviewOfType:(Class)type;
- (id)aka_selfOrSuperviewOfType:(Class)type;

@end
