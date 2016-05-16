//
//  UIView+AKAConstraintTools.h
//  AKACommons
//
//  Created by Michael Utech on 16.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AKAConstraintTools)

/**
 * Determines if self is (directly) affected by the specified constraint.
 *
 * @note that this only tests first- and secondItem of the constraint
 * and thus does not attempt to perform any magic to find out if the constraint
 * really affects the view.
 *
 * @param constraint the constraint to test
 *
 * @return YES if the constraint references the view, NO otherwise.
 */
- (BOOL)aka_isAffectedByConstraint:(NSLayoutConstraint*)constraint;

/**
 * Determines if self is the only view (directly) affected by the specified constraint.
 *
 * @note This only tests first- and secondItem of the constraint
 * and thus does not attempt to perform any magic to find out if the constraint
 * really affects the view.
 *
 * @note Only direct instances of NSLayoutConstraint are included. Intances of private
 *       or custom constraint implementations are ignored.
 *
 * @param constraint the constraint to test
 *
 * @return YES if the constraint references no other view, NO otherwise.
 */
- (BOOL)aka_isTheOnlyViewDirectlyAffectedBy:(NSLayoutConstraint*)constraint;

/**
 * Gets an array containing all constraints which directly affect the specified view.
 *
 * @sa aka_isAffectedByConstraint:
 *
 * @param view the view
 *
 * @return all constraints affecting the specified view.
 */
- (NSArray*)aka_constraintsAffectingView:(UIView*)view;

/**
 * Gets an array containing all constraints which directly affect any of the specified views.
 *
 * @param views an array of views
 *
 * @return All constraints which directly affect one or more of the specified views.
 */
- (NSArray*)aka_constraintsAffectingViews:(NSArray*)views;

/**
 * Gets all constraints which only (directly) affect this instance
 *
 * @sa aka_isTheOnlyViewDirectlyAffectedBy:
 *
 * @return All constraints which do not (directly) affect other views.
 */
- (NSArray*)aka_constraintsAffectingOnlySelf;

/**
 * Removes all constraints of this instance, which (directly) affect the specified view.
 *
 * @param view the view
 *
 * @return an array containing the removed constraints.
 */
- (NSArray*)aka_removeConstraintsAffectingView:(UIView*)view;

/**
 * Removes all constraints of this instance, which (directly) affect any of the specified views.
 *
 * @param views the views
 *
 * @return an array containing the removed constraints.
 */
- (NSArray *)aka_removeConstraintsAffectingViews:(NSArray *)views;

/**
 * Removes all constraints of this instance, which do not (directly) affect any views except this instance.
 *
 * @return an array containing the removed constraints.
 */
- (NSArray *)aka_removeConstraintsAffectingOnlySelf;

#pragma mark - Themes

/**
 * Applies the theme specification to the subviews specified in views.
 *
 * A theme specification consists of two toplevel elements: The @b viewCustomization,
 * which allows you to overwrite UIView properties (using KVC) and the @b layouts,
 * containing conditional constraint specifications to apply.
 *
 * For example:
 * @code
 * @{ @"metrics": @{ @"pad": @4, @"c1Width": @100, @"hspace": @4 },
 *    @"viewCustomization":
 *    @{ @"label":     @{ @"textFont":  [UIFont systemFontOfSize:14.0] },
 *       @"textField": @{ @"textFont":  [UIFont systemFontOfSize:14.0] },
 *       @"error":     @{ @"textFont":  [UIFont systemFontOfSize:10.0],
 *                        @"textColor": [UIColor redColor]             },
 *     },
 *    @"layouts":
 *    @[ @{ @"requiredViews": @[ @"label", @"textField", @"error" ],
 *          @"metrics": @{ @"vspace": @2 },
 *          @"constraints":
 *          @[ @{ @"format": @"H:|-(pad)-[label(c1Width)]-(hspace)-[textField]-(pad)-|",
 *                @options": @(NSLayoutFormatAlignAllFirstBaseline)
 *              },
 *             @{ @"format": @"V:|-(pad)-[textField]-(vspace)-[error]-(pad)-|",
 *                @"options": @(NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight)}
 *           ],
 *        },
 *       @{ @"requiredViews" @[ @"label", @"textField" ],
 *          @"constraints":
 *          @[ @{ @"format": @"H:|-(pad)-[label(c1Width)]-(hspace)-[textField]-(pad)-|",
 *                @options": @()
 *              },
 *             @{ @"format": @"V:|-(pad)-[textField]-(pad)-|" }
 *           ]
 *        }
 *     ]
 * @endcode
 * defines a theme applicable to a view (self) which contains two or three subviews identified
 * by names "label", "textField" and "error". If applied, the theme will change the properties
 * textFont and textColor as specified in viewCustomization and use the first applicable
 * constraint specification. A constraint specification is applicable if all required views
 * are found in the @b views dictionary.
 *
 * @ref aka_constraintsForSpecification:views:metrics: for a documentation of the
 * constraint specification format.
 *
 * @param themeSpecification the theme specification (see description)
 * @param views a dictionary mapping view names to names.
 *
 * @return @{ @"addedConstraints": @[...], @"removedConstraints": @[...] }
 */
- (NSDictionary*)aka_applyTheme:(NSDictionary*)themeSpecification
                        toViews:(NSDictionary*)views;

/**
 * Generates constraints based on the specification which can be
 * provided as visual format with options:
 * @code
 * @{ @"format": @"|-4-[view1]-4-[view2]-4-|",\n
 *    @"options": @(NSLayoutFormatAlignAllFirstBaseline)
 *    }
 * @endcode
 * plain constraint properties:
 * @code
 * @{ @"firstItem": @"view1",
 *    @"firstAttribute": @(NSLayoutAttributeBottom),
 *    @"relatedBy": @"==",
 *    @"secondItem": @"view2",
 *    @"secondAttribute": @(NSLayoutAttributeBottom),
 *    @"multiplier": @(1.1),
 *    @"constant": @(4),
 *    @"priority": @(1000)
 *    }
 * @endcode
 * or constraint sets (where either or both of firstItem and secondItem
 * can be replaced by firstItems or secondItems:
 * @code
 * @{ @"firstItem": @"view1",
 *    @"firstAttribute": @(NSLayoutAttributeBottom),
 *    @"relatedBy": @"<=",
 *    @"secondItems": @[ @{ @"item": @"view2" },
 *                       @{ @"item": @"view3",
 *                          @"relatedBy": @(NSLayoutRelationLessThanOrEqual)
 *                          @"secondAttribute": @(NSLayoutAttributeTop),
 *                          @"constant" @(2) }
 *                       ],
 *    @"secondAttribute": @(NSLayoutAttributeBottom),
 *    @"multiplier": @(1.1),
 *    @"constant": @(4),
 *    @"priority": @(1000)
 *    }
 * @endcode
 * Please note that properties defined in firstItems and secondItems
 * override those defined at toplevel. It is invalid to specify
 * the same property in both firstItems and secondItems entries.
 *
 * @note You should use the visual format in preference to plain constraint specifications.
 *
 * @param specification a constraint specification (see description)
 * @param views a dictionary mapping names to views
 * @param metrics a dictionary mapping names to metric values
 *
 * @return an array contains the generated constraints.
 */
- (NSArray*)aka_constraintsForSpecification:(NSDictionary*)specification
                                      views:(NSDictionary*)views
                                    metrics:(NSDictionary*)metrics;

@end
