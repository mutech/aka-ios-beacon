//
// Created by Michael Utech on 26.03.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKALayoutConstraintSpecification;
@protocol AKALayoutConstraintSpecificationDelegate <NSObject>

@optional
- (BOOL)constraintSpecification:(AKALayoutConstraintSpecification*)constraintSpecification
       shouldInstallConstraints:(NSArray*)nsLayoutConstraints
                       inTarget:(UIView*)target;
@optional
- (void)constraintSpecification:(AKALayoutConstraintSpecification*)constraintSpecification
         willInstallConstraints:(NSArray*)nsLayoutConstraints
                       inTarget:(UIView*)target;
@optional
- (void)constraintSpecification:(AKALayoutConstraintSpecification*)constraintSpecification
          didInstallConstraints:(NSArray*)nsLayoutConstraints
                       inTarget:(UIView*)target;

@end

@protocol AKALayoutConstraintSpecificationProtocol<NSObject>

@property(nonatomic, readonly) id target;

- (NSArray*)constraintsForViews:(NSDictionary*)views
                        metrics:(NSDictionary*)metrics;

- (NSArray*)installConstraintsForViews:(NSDictionary*)views
                               metrics:(NSDictionary*)metrics
                         defaultTarget:(UIView*)defaultTarget;

- (NSArray*)installConstraintsForViews:(NSDictionary*)views
                               metrics:(NSDictionary*)metrics
                         defaultTarget:(UIView*)defaultTarget
                              delegate:(NSObject<AKALayoutConstraintSpecificationDelegate>*)delegate;
@end

@interface AKALayoutConstraintSpecification : NSObject<AKALayoutConstraintSpecificationProtocol>

@property(nonatomic, weak) NSObject<AKALayoutConstraintSpecificationDelegate>* delegate;

+ (AKALayoutConstraintSpecification *)constraintSpecificationWithDictionary:(NSDictionary *)dictionary;

+ (AKALayoutConstraintSpecification *)constraintSpecificationWithTarget:(id)target
                                                           visualFormat:(NSString *)visualFormat
                                                                options:(NSLayoutFormatOptions)
                                                                        options;

+ (AKALayoutConstraintSpecification *)constraint:(NSLayoutConstraint *)constraint
                                      withTarget:(id)target;

+ (AKALayoutConstraintSpecification *)constraints:(NSArray *)constraints
                                       withTarget:(id)target;

+ (AKALayoutConstraintSpecification *)constraintSpecificationWithTarget:(id)target
                                                             firstItems:(NSArray *)firstItems
                                                         firstAttribute:(NSLayoutAttribute)firstAttribute
                                                              relatedBy:(NSLayoutRelation)relation
                                                            secondItems:(NSArray *)secondItems
                                                        secondAttribute:(NSLayoutAttribute)secondAttribute
                                                             multiplier:(CGFloat)multiplier
                                                               constant:(CGFloat)constant
                                                               priority:(int)priority;

@end
