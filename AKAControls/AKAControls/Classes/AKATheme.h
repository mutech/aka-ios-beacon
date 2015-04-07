//
//  AKATheme.h
//  AKAControls
//
//  Created by Michael Utech on 24.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAThemeViewApplicability.h"
#import "AKAViewCustomization.h"
#import "AKAThemeLayout.h"

#pragma mark - AKAViewCustomization
#pragma mark -

@class AKATheme;
@protocol AKAThemeDelegate<
    AKAThemeLayoutDelegate
>

@optional
- (BOOL)                    theme:(AKATheme*)theme
    shouldApplyViewCustomizations:(NSArray*)viewCustomizations
                          toViews:(NSDictionary*)views;

@optional
- (void)themeWillRemoveConstraints:(AKATheme*)theme;

@optional
- (BOOL)                    theme:(AKATheme*)theme
          shouldRemoveConstraints:(inout NSArray**)constraints
                    relatedToView:(UIView*)view
                          withKey:(NSString*)key
                          inViews:(NSDictionary*)views
                       fromTarget:(UIView*)target;

@optional
- (BOOL)                    theme:(AKATheme*)theme
          shouldRemoveConstraints:(inout NSArray**)constraints
                  relatedToTarget:(UIView*)target
                         fromView:(UIView*)view
                          withKey:(NSString*)key
                          inViews:(NSDictionary*)views;

@optional
- (BOOL)                    theme:(AKATheme*)theme
shouldRemoveConstraintsOnlyRelatedToSelf:(inout NSArray**)constraints
                         fromView:(UIView*)view
                          withKey:(NSString*)key
                          inViews:(NSDictionary*)views;

@optional
- (void)                    theme:(AKATheme*)theme
             didRemoveConstraints:(NSArray*)constraints
                         fromView:(UIView*)view;

@optional
- (void)themeDidRemoveConstraints:(AKATheme*)theme;

@end

/**
 * Implementation of the AKAThemeDelegate protocol that forwards all methods its @c delegate.
 *
 * This is useful chain delegates and f.e. used by the AKAThemeChangeRecorderDelegate to record changes
 * while preserving the possibility to serve another delegate.
 */
@interface AKAThemeDelegateProxy: NSObject<AKAThemeDelegate>

/**
 * The delegate to which all messages are forwarded.
 */
@property(nonatomic) id<AKAThemeDelegate> delegate;

@end

/**
 * This delegate records all changes made by a theme application and creates a theme that can be
 * applied in order to restore the initial state of a set of views undoing the previous theme
 * application.
 *
 * @note The current implementation saves concrete instances of NSLayoutConstraint's which means
 * that a recorded theme can only be applied to the target which has been originally recorded.
 */
@interface AKAThemeChangeRecorderDelegate: AKAThemeDelegateProxy

/**
 * Initializes the theme recorded with the specified delegate. The theme recorded forwards all
 * delegate messages to the specified delegate in order to transparently perform its task
 *
 * @param delegate a delegate or nil
 *
 * @return the theme change recorder.
 */
- (instancetype)initWithDelegate:(id<AKAThemeDelegate>)delegate;

/**
 * The recorded theme (available after a theme was applied with this instance as delegate).
 */
@property(nonatomic) AKATheme* recordedTheme;

@end

@interface AKATheme : AKAViewCustomizationContainer

#pragma mark - Initialization

+ (instancetype)themeWithDictionary:(NSDictionary*)specification;

- (instancetype)initWithDictionary:(NSDictionary*)specification;

#pragma mark - Application

- (void)applyToTarget:(UIView*)target
            withViews:(NSDictionary*)views
             delegate:(NSObject<AKAThemeDelegate>*)delegate;

#pragma mark - Configuration

@property(nonatomic, weak) NSObject<AKAThemeDelegate>* delegate;

@property(nonatomic) NSDictionary* defaultMetrics;
@property(nonatomic, readonly) NSArray* layouts;

@end
