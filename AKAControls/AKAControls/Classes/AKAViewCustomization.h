//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

@class AKAViewCustomization;


@protocol AKAViewCustomizationDelegate <NSObject>

@optional
- (void)                                   viewCustomizations:(AKAViewCustomization *)customization
                                          willBeAppliedToView:(id)view;

@optional
- (BOOL)                                   viewCustomizations:(AKAViewCustomization *)customization
                                            shouldSetProperty:(NSString*)name
                                                        value:(id)oldValue
                                                           to:(id)newValue;

@optional
- (void)                                   viewCustomizations:(AKAViewCustomization *)customization
                                               didSetProperty:(NSString *)name
                                                        value:(id)oldValue
                                                           to:(id)newValue;

@optional
- (void)                                   viewCustomizations:(AKAViewCustomization *)customizations
                                        haveBeenAppliedToView:(id)view;

@end


@interface AKAViewCustomization: NSObject

#pragma mark Initialization

- (instancetype)                            initWithDictionary:(NSDictionary*)dictionary;

#pragma mark - Configuration

@property (nonatomic, weak) NSObject<AKAViewCustomizationDelegate>* delegate;

#pragma mark Properties

@property(nonatomic) NSString*                                 viewKey;

#pragma mark Configuration

/**
 * Adds a customization which will change the property with the specified name to
 * the specified value. The value may be an instance of AKAProperty, which will
 * be resolved at the time of application. If the property is unbound, the context
 * passed to applyToView:withContext:delegate: will be used to resolve the value.
 *
 * @param value the value to be set on application
 * @param name the name of the property to change.
 */
- (void)                              addCustomizationSetValue:(id)value
                                               forPropertyName:(NSString*)name;

- (void)            removeCustomizationSetValueForPropertyName:(NSString*)name;

#pragma mark Application

- (BOOL)                                    isApplicableToView:(id)view;

/**
 * Applies the customizations configured in this instance to the entry in the views
 * dictionary that matches the configured viewKey.
 *
 * This method is equivalent to [self applyToView:views[self.viewKey] ...].
 *
 * @param views a dictionary of views by key (matching self.viewKey)
 * @param context the context in which AKAProperty values are resolved.
 * @param delegate the delegate to use (in addition to self.delegate).
 *
 * @return YES if the customization is applicable
 */
- (BOOL)                                          applyToViews:(NSDictionary *)views
                                                   withContext:(id)context
                                                      delegate:(id<AKAViewCustomizationDelegate>)delegate;

/**
 * Applies the customizations configured in this instance to the specified view.
 *
 * @param view the view to apply this customization to.
 * @param context the context in which AKAProperty values are resolved.
 * @param delegate the delegate to use (in addition to self.delegate).
 *
 * @return YES if the customization is applicable
 */
- (BOOL)                                           applyToView:(id)view
                                                   withContext:(id)context
                                                      delegate:(id<AKAViewCustomizationDelegate>)delegate;

@end


@interface AKAViewCustomizationContainer: NSObject

@property(nonatomic, readonly) NSObject<AKAViewCustomizationDelegate>* viewCustomizationDelegate;

@property(nonatomic, readonly) NSArray*                        viewCustomizations;

#pragma mark - Adding View Customizations

- (NSUInteger)    addViewCustomizationsWithArrayOfDictionaries:(NSArray*)specifications;

- (AKAViewCustomization *)  addViewCustomizationWithDictionary:(NSDictionary*)specification;

- (void)                                  addViewCustomization:(AKAViewCustomization *)viewCustomization;


#pragma mark - Application

- (void)                       applyViewCustomizationsToTarget:(UIView*)target
                                                     withViews:(NSDictionary*)views
                                                      delegate:(NSObject<AKAViewCustomizationDelegate>*)delegate;

@end
