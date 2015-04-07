//
// Created by Michael Utech on 26.03.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKALayoutConstraintSpecification;

/**
 * Delegate used by AKALayoutConstraintSpecificationDelegate in order
 * customize and observe the process of applying constraints.
 */
@protocol AKALayoutConstraintSpecificationDelegate <NSObject>

// TODO: make nsLayoutConstraints an inout NSArray** to allow the delegate to modify the constraints:
@optional
/**
 * Determines whether the specified @c nsLayoutConstraints should be
 * installed (added to) the specified @c target view in order to
 * implement the specified @c constraintSpecification.
 *
 * If the delegate does not implement this method, the constraints
 * will be installed.
 *
 * @bug nsLayoutConstraints should be an @c inout parameter to allow
 * the delegate to modify the set of constraints to be installed.
 *
 * @param constraintSpecification The constraint specification from which the NSLayoutConstraint's are derived.
 * @param nsLayoutConstraints The constraints to be installed
 * @param target the view to which the constraints should be added.
 *
 * @return YES if the constraints should be installed, NO otherwise.
 */
- (BOOL)constraintSpecification:(AKALayoutConstraintSpecification*)constraintSpecification
       shouldInstallConstraints:(NSArray*)nsLayoutConstraints
                       inTarget:(UIView*)target;
@optional
/**
 * Announces that the specified @c nsLayoutConstraints will be
 * installed (added to) the specified @c target view in order to
 * implement the specified @c constraintSpecification.
 *
 * @param constraintSpecification The constraint specification from which the NSLayoutConstraint's are derived.
 * @param nsLayoutConstraints The constraints to be installed
 * @param target the view to which the constraints should be added.
 */
- (void)constraintSpecification:(AKALayoutConstraintSpecification*)constraintSpecification
         willInstallConstraints:(NSArray*)nsLayoutConstraints
                       inTarget:(UIView*)target;

@optional
/**
 * Announces that the specified @c nsLayoutConstraints have been
 * installed (added to) the specified @c target view in order to
 * implement the specified @c constraintSpecification.
 *
 * @param constraintSpecification The constraint specification from which the NSLayoutConstraint's are derived.
 * @param nsLayoutConstraints The constraints to be installed
 * @param target the view to which the constraints should be added.
 */
- (void)constraintSpecification:(AKALayoutConstraintSpecification*)constraintSpecification
          didInstallConstraints:(NSArray*)nsLayoutConstraints
                       inTarget:(UIView*)target;

@end

/**
 * This protocol specifies the common interface of supported
 * layout constraint specifications.
 */
@protocol AKALayoutConstraintSpecificationProtocol<NSObject>

/**
 * The target or target specification identifying the view to which
 * constraints derived from this specification should be added.
 *
 * This can either be an instance of UIView or a name identifying
 * a view in a views dictionary (such as those used for visual format
 * layout specifications).
 */
@property(nonatomic, readonly) id target;

/**
 * Creates (but does not install) constraints implementing the specification for the views in the specified @c views dictionary.
 *
 * @param views a dictionary mapping view names to UIView instances.
 * @param metrics a dictionary mapping metric names to concrete values.
 *
 * @return an array of NSLayoutConstraint's matching the specification.
 */
- (NSArray*)constraintsForViews:(NSDictionary*)views
                        metrics:(NSDictionary*)metrics;

/**
 * Creates and installs constraints implementing the specification for the views in the specified @c views dictionary.
 *
 * @param views a dictionary mapping view names to UIView instances.
 * @param metrics a dictionary mapping metric names to concrete values.
 * @param defaultTarget the target to use if the @c target property is undefined.
 *
 * @return an array of NSLayoutConstraint's matching the specification.
 */
- (NSArray*)installConstraintsForViews:(NSDictionary*)views
                               metrics:(NSDictionary*)metrics
                         defaultTarget:(UIView*)defaultTarget;

/**
 * Creates and installs constraints implementing the specification for the views in the specified @c views dictionary.
 *
 * @param views a dictionary mapping view names to UIView instances.
 * @param metrics a dictionary mapping metric names to concrete values.
 * @param defaultTarget the target to use if the @c target property is undefined.
 * @param delegate a AKALayoutConstraintSpecificationDelegate used independent from a delegate possibly configured in the constraint specification.
 *
 * @return an array of NSLayoutConstraint's matching the specification.
 */
- (NSArray*)installConstraintsForViews:(NSDictionary*)views
                               metrics:(NSDictionary*)metrics
                         defaultTarget:(UIView*)defaultTarget
                              delegate:(NSObject<AKALayoutConstraintSpecificationDelegate>*)delegate;
@end

/**
 * Entry class for a cluster supporting the specification of NSLayoutConstraints using different
 * methods.
 */
@interface AKALayoutConstraintSpecification : NSObject<AKALayoutConstraintSpecificationProtocol>

#pragma mark - Initialization
/// @name Initialization

/**
 * Creates and initializes a constraint specification for the specified dictionary.
 *
 * @bug TODO: Documentation for the dictionary and example is missing
 *
 * @param dictionary the specification in its dictionary format.
 *
 * @return the constraint specification for the specified dictionary.
 */
+ (AKALayoutConstraintSpecification *)constraintSpecificationWithDictionary:(NSDictionary *)dictionary;

/**
 * Creates and initializes a constraint specification for the specified @c visualFormat and @c options.
 *
 * @param target the target UIView or the name of a view in a view dictionary.
 * @param visualFormat the visual format specifying the constraints
 * @param options options
 *
 * @return the layout constraint specification
 */
+ (AKALayoutConstraintSpecification *)constraintSpecificationWithTarget:(id)target
                                                           visualFormat:(NSString *)visualFormat
                                                                options:(NSLayoutFormatOptions)
                                                                        options;

/**
 * Creates a layout constraint specification which simply wraps an existing constraint.
 * This is primarily used to backup a constraint in order to restore it later on.
 *
 * @param constraint the existing constraint
 * @param target the target UIView or the name of a view in a view dictionary. Please note that since the constraint references concrete views, it is typically useless or even a fatal error to add it to a view different from the one it was taken from.
 *
 * @return the layout constraint specification.
 */
+ (AKALayoutConstraintSpecification *)constraint:(NSLayoutConstraint *)constraint
                                      withTarget:(id)target;

/**
 * Creates a layout constraint specification which simply wraps a set of existing constraints.
 * This is primarily used to backup constraints in order to restore them later on.
 *
 * @param constraints the existing constraints
 * @param target the target UIView or the name of a view in a view dictionary. Please note that since the constraints reference concrete views, it is typically useless or even a fatal error to add them to a view different from the one they were taken from.
 *
 * @return the layout constraint specification.
 */
+ (AKALayoutConstraintSpecification *)constraints:(NSArray *)constraints
                                       withTarget:(id)target;

/**
 * Creates a layout constraint specification from the specified parameters. This is very similar to the
 * method provided by NSLayoutConstraint. However, you can specify multiple first- and secondItems
 * which results in the cartesian product of constraints for each combination of first- and secondItems.
 *
 * @param target the target UIView or the name of a view in a view dictionary.
 * @param firstItems the first UIView(s) or the names of views in a view dictionary.
 * @param firstAttribute the attribute of the firstItem(s)
 * @param relation the relation type
 * @param secondItems the second UIView(s) or the names of views in a view dictionary.
 * @param secondAttribute the attribute of the secondItem(s)
 * @param multiplier the multiplier
 * @param constant the constant
 * @param priority the constraint priority
 *
 * @return the layout constraint specification
 */
+ (AKALayoutConstraintSpecification *)constraintSpecificationWithTarget:(id)target
                                                             firstItems:(NSArray *)firstItems
                                                         firstAttribute:(NSLayoutAttribute)firstAttribute
                                                              relatedBy:(NSLayoutRelation)relation
                                                            secondItems:(NSArray *)secondItems
                                                        secondAttribute:(NSLayoutAttribute)secondAttribute
                                                             multiplier:(CGFloat)multiplier
                                                               constant:(CGFloat)constant
                                                               priority:(int)priority;

#pragma mark - Configuration
///@name Configuration

/**
 * @note the delegate property is primarily used to propagate events up to toplevel specifications.
 */
@property(nonatomic, weak) NSObject<AKALayoutConstraintSpecificationDelegate>* delegate;

@end
