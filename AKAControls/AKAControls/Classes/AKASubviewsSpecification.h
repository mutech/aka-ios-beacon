//
//  AKASubviewsSpecification.h
//  AKAControls
//
//  Created by Michael Utech on 27.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AKACommons/AKAProperty.h>
#import "AKAThemeViewApplicability.h"

@class AKASubviewsSpecification;
@class AKASubviewsSpecificationItem;

@protocol AKASubviewSpecificationItemDelegate <NSObject>

@optional
/**
 * Indicates, that the specified @c containerView does not contain a subview
 * matching the @c specification.
 *
 * If the delegate chooses to create the missing view in response to this message,
 * it should return YES and set the created view parameter to refer to the new view.
 *
 * @param specification the subview specification of the missing view
 * @param containerView the container view
 * @param createdView a pointer to a view reference that the delegate should set if it creates the missing view.
 *
 * @return YES if the delegate created the view.
 */
- (BOOL)subviewSpecificationItem:(AKASubviewsSpecificationItem*)specification
         subviewNotFoundInTarget:(UIView*)containerView
                     createdView:(out UIView**)createdView;

@optional
/**
 * Indicates, that the previously by this delegate @c createdView is not a subview
 * of the specified @c containerView.
 *
 * If the delegate chooses to add the created view to the container view, it should
 * return YES.
 *
 * If the receiver does not respond to this message or if it returns NO the view
 * will be added if it is required and if validation is instructed to fix problems.
 *
 * @param specification the subviews specification item
 * @param createdView the view previously created by this delegate
 * @param containerView the container view
 *
 * @return YES if the delegate added the createdView to the containerView, otherwise NO.
 */
- (BOOL)subviewSpecificationItem:(AKASubviewsSpecificationItem*)specification
                     createdView:(UIView*)createdView
            isNotSubviewOfTarget:(UIView*)containerView;

@optional
/**
 * Indicates, that the view tag of the subview (or the previously created view)
 * differs from the expected view tag configured in the specification.
 *
 * IF the delegate chooses to correct the tag value, it should return YES.
 *
 * @param specification the views specification
 * @param containerView the container view
 * @param subviewOrCreatedView the subview or previously created view
 * @param currentTagValue the current value of the views tag property
 * @param specifiedTagValue the expected tag value
 *
 * @return YES if the delegate corrected the tag value
 */
- (BOOL)subviewSpecificationItem:(AKASubviewsSpecificationItem *)specification
                          target:(UIView*)containerView
                            view:(UIView*)subviewOrCreatedView
                        tagValue:(NSInteger)currentTagValue
        differsFromExpectedValue:(NSInteger)specifiedTagValue;

@optional
/**
 * Indicates that the @c outlet in the @c containerView does not refer to
 * the @c subviewOrCreatedView. This message is only send if an outlet was configured
 * (im- or explicitely) in the @c specification. If the delegate chooses to
 * set the outlet (directly or using @c<pre>[outlet setValue:subviewOrCreatedView forTarget:containerView]</pre>
 * it should return YES, otherwise NO.
 *
 * @param specification the subviews specification item
 * @param containerView the container view
 * @param outlet a reference to the outlet property
 * @param subviewOrCreatedView the view not referenced by the outlet
 *
 * @return YES if the delegate set the outlet, NO otherwise.
 */
- (BOOL)subviewSpecificationItem:(AKASubviewsSpecificationItem *)specification
                           target:(UIView*)containerView
                           outlet:(AKAUnboundProperty*)outlet
               doesNotReferToView:(UIView*)subviewOrCreatedView;

@optional
/**
 * Indicates that the view created in response to @c subviewNotFoundInTarget
 * will not be found in the @c containerView, because it is not a subview
 * or it is not referenced by an outlet and also not identifiable by it tag value.
 *
 * This is most likely an error, because future validations will probably trigger
 * another creation which will probably fail again.
 *
 * @param specification the subview specification item
 * @param createdView the view previously created by the delegate
 * @param containerView the container view
 */
- (void)subviewSpecificationItem:(AKASubviewsSpecificationItem*)specification
                     createdView:(UIView*)createdView
          willNotBeFoundInTarget:(UIView*)containerView;

@optional
/**
 * Indicates that the @c subviewOrCreatedView does not meet the requirements
 * configured in the specification. This may or may not be an error. The subview
 * will be ignored in all operations except for validation.
 *
 * If the delegate can fix the problem, it should do so and then trigger a revalidation
 * of the view (or the container).
 *
 * @param specification the subview's specification
 * @param containerView the container view
 * @param subviewOrCreatedView the subview
 * @param requirements the unsatisfied requirements
 */
- (void)subviewSpecificationItem:(AKASubviewsSpecificationItem*)specification
                          target:(UIView*)containerView
                            view:(UIView*)subviewOrCreatedView
         doesNotMeetRequirements:(AKAThemeViewApplicability*)requirements;

@end

@protocol AKASubviewsSpecificationDelegate <AKASubviewSpecificationItemDelegate>

@optional
- (void)subviewsSpecification:(AKASubviewsSpecification*)specification
                         item:(AKASubviewsSpecificationItem*)item
           willValidateTarget:(UIView*)containerView;

@optional
- (void)subviewsSpecification:(AKASubviewsSpecification*)specification
                         item:(AKASubviewsSpecificationItem*)item
            didValidateTarget:(UIView*)containerView
                  withSuccess:(BOOL)success;

@end

/**
* Specifies a set of subviews of a container view. The specification can be used
* to validate the container, create missing subviews, setup outlets, customize
* subview properties and to create a views dictionary suitable to be used to
* define visual layout constraints for these views in the container.
*/
@interface AKASubviewsSpecification : NSObject

#pragma mark - Initialization

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

#pragma mark - Access

@property(nonatomic, readonly) NSDictionary* subviewSpecificationsByName;

- (NSDictionary*)viewsDictionaryForTarget:(UIView*)containerView;

#pragma mark - Validation

- (BOOL)validateTarget:(UIView*)target
          withDelegate:(id<AKASubviewsSpecificationDelegate>)delegate
           fixProblems:(BOOL)fixProblems;

@end

@interface AKASubviewsSpecificationItem : NSObject

#pragma mark - Initialization

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
                              name:(NSString*)name;

- (instancetype)initWithName:(NSString*)name
                      outlet:(AKAUnboundProperty*)outlet
                     viewTag:(NSNumber*)viewTag
                requirements:(AKAThemeViewApplicability*)requirements;

#pragma mark - Configuration

@property(nonatomic, readonly) NSString* name;
@property(nonatomic, readonly) AKAUnboundProperty* outlet;
@property(nonatomic, readonly) NSNumber* viewTag;
@property(nonatomic, readonly) AKAThemeViewApplicability* requirements;

#pragma mark - 

/**
 * Returns the subview of the specified @c containerView that matches the specification
 * or nil if no such view is found.
 *
 * @param containerView the container view
 *
 * @return the matching view or nil if no matching view was found
 */
- (UIView*)matchingViewInTarget:(UIView*)containerView;

/**
 * Determines if the target view satisfies the requirements configured in this
 * instance. If the presence of a view is required (which is typically true),
 * then this method checks if the view can be located. The specified delegate
 * is notified about problems and can assist in fixing them. See the documentation
 * of delegate methods in @c AKASubviewSpecificationItemDelegate
 *
 * If @c fixProblems is YES, the following corrections are applied (unless the
 * delegate responds to corresponding methods and returns NO): view tags are set to the configured value (if provided); outlets are set to reference matching views (if outlet is configured); orphaned views are added to the target view container
 *
 * @see AKASubviewSpecificationItemDelegate
 *
 * @param target the container view
 * @param delegate a delegate or nil
 * @param fixProblems YES if correctable problems should be fixed, NO otherwise
 *
 * @return YES if the configured requirements are satisfied (or if no requirements are configured and a matching view could be located), NO otherwise.
 */
- (BOOL)validateTarget:(UIView*)target
          withDelegate:(id<AKASubviewSpecificationItemDelegate>)delegate
           fixProblems:(BOOL)fixProblems;

@end



