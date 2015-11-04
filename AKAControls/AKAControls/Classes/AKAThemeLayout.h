//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAThemeViewApplicability.h"
#import "AKALayoutConstraintSpecification.h"
#import "AKAViewCustomization.h"

@class AKAThemeLayout;
@protocol AKAThemeLayoutDelegate<
    AKALayoutConstraintSpecificationDelegate,
    AKAViewCustomizationDelegate
>

@optional
- (void)                    layout:(AKAThemeLayout*)layout
      didCheckApplicabilityToViews:(NSDictionary*)views
                        withResult:(BOOL)result;

@optional
- (void)                    layout:(AKAThemeLayout *)layout
              willBeAppliedToViews:(NSDictionary *)views
                           metrics:(NSDictionary *)metrics
                     defaultTarget:(UIView *)target;

@optional
- (void)                    layout:(AKAThemeLayout *)layout
             hasBeenAppliedToViews:(NSDictionary *)views
                           metrics:(NSDictionary *)metrics
                     defaultTarget:(UIView *)target;

@end

@interface AKAThemeLayout: AKAViewCustomizationContainer

#pragma mark - Initialization

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

#pragma mark - Application

/**
 * Determines whether this layout is applicable to the specified views.
 *
 * @param views a dictionary mapping names to views
 *
 * @return YES if the layout can be applied, NO otherwise.
 */
- (BOOL)isApplicableToViews:(NSDictionary*)views;

/**
 * Applies this layout to the specified default target (used if <target> and dviews
 *
 * @param views a dictionary mapping view names to views.
 * @param defaultMetrics the default metrics, if the layout defines its own metrics, both will be merged with layout metrics overwriting default metrics.
 * @param defaultTarget the default target used to install constraints, used if the layout does not specify its own target.
 *
 * @return if the layout was successfully applied.
 */
- (BOOL)applyToViews:(NSDictionary*)views
  withDefaultMetrics:(NSDictionary*)defaultMetrics
       defaultTarget:(UIView*)defaultTarget;

/**
 * Applies this layout to the specified default target (used if <target> and dviews
 *
 * @param views a dictionary mapping view names to views.
 * @param defaultMetrics the default metrics, if the layout defines its own metrics, both will be merged with layout metrics overwriting default metrics.
 * @param defaultTarget the default target used to install constraints, used if the layout does not specify its own target.
 * @param delegate additional delegate monitoring and customizing the application process.
 *
 * @return if the layout was successfully applied.
 */
- (BOOL)applyToViews:(NSDictionary*)views
  withDefaultMetrics:(NSDictionary*)defaultMetrics
       defaultTarget:(UIView*)target
        withDelegate:(NSObject<AKAThemeLayoutDelegate>*)delegate;

#pragma mark - Configuration

@property(nonatomic, weak) NSObject<AKAThemeLayoutDelegate>* delegate;

#pragma mark - Applicability requirements

/**
 * Restricts the applicability of this layout to view dictionaries which contain a view for the specified key that matches the specified type constraints.
 *
 * The applicability of a layout to a view can be restricted based on the views type by including and
 * excluding types. If both validTypes and invalidTypes is specified, a view has to match validTypes
 * and at the same time must not match invalidTypes. See parameter descriptions.
 *
 * @param key the name of a view required to be present in a view dictionary/
 * @param validTypes the view for the specified key must be a kind of at least one of the types specified here. If valid types is nil, any object will match (=> object is valid), if it is empty, no object will match (=> object is invalid).
 * @param invalidTypes the view for the specified key must not be a kind of any of the types specified here. If invalidTypes is nil, no object will match (=> object is valid), if it is empty, all views will match (=> object is invalid).
 */
- (void)requireView:(NSString*)key
         withTypeIn:(NSArray*)validTypes
       andTypeNotIn:(NSArray*)invalidTypes;

/**
 * Restricts the applicability of this layout to view dictionaries which contain a view for the
 * specified key.
 *
 * @param key the name of a view required to be present in a view dictionary/
 */
- (void)requireView:(NSString*)key
  withApplicability:(AKAThemeViewApplicability*)applicability;

/**
 * Restricts the applicability of this layout to view dictionaries which do not contain a view for
 * the specified key.
 *
 * @param key a key in the views dictionary to be tested for applicability.
 */
- (void)requireViewIsAbsent:(NSString*)key;

#pragma mark - Adding constraint specifications

/**
 * Adds a constraint specification with the specified serialized specification.
 *
 * @sa AKALayoutConstraintSpecification::constraintSpecificationWithDictionary:
 *
 * @param dictionary <#dictionary description#>
 */
- (void)addConstraintSpecificationWithDictionary:(NSDictionary*)dictionary;

/**
 * Adds a constraint specification with the specified visual format and options.
 *
 * @sa AKALayoutConstraintSpecification::constraintSpecificationWithVisualFormat:options:forTarget
 *
 * @param visualFormat the visual format specifying the constraints.
 * @param options see NSLayoutFormatOptions
 */
- (void)addConstraintSpecificationWithVisualFormat:(NSString *)visualFormat
                                           options:(NSLayoutFormatOptions)options;

/**
 * Adds a constraint specification with the specified visual format and options for the specified
 * target (view).
 *
 * @sa AKALayoutConstraintSpecification::constraintSpecificationWithVisualFormat:options:forTarget
 *
 * @param visualFormat the visual format specifying the constraints.
 * @param options see NSLayoutFormatOptions
 * @param target the target view or view dictionary key specifying where the constraints should be installed.
 */
- (void)addConstraintSpecificationWithVisualFormat:(NSString *)visualFormat
                                           options:(NSLayoutFormatOptions)options
                                         forTarget:(id)target;

- (void)addConstraintSpecificationWithConstraint:(NSLayoutConstraint *)constraint
                                       forTarget:(id)target;

- (void)addConstraintSpecificationWithConstraints:(NSArray *)constraints
                                        forTarget:(id)target;

- (void)addConstraintSpecificationWithFirstItems:(NSArray *)firstItems
                                  firstAttribute:(NSLayoutAttribute)firstAttribute
                                       relatedBy:(NSLayoutRelation)relation
                                     secondItems:(NSArray *)secondItems
                                 secondAttribute:(NSLayoutAttribute)secondAttribute
                                      multiplier:(CGFloat)multiplier
                                        constant:(CGFloat)constant
                                        priority:(int)priority
                                       forTarget:(id)target;

@end

