//
//  AKATheme.h
//  AKAControls
//
//  Created by Michael Utech on 24.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AKAControls/AKAThemeViewApplicability.h>
#import <AKAControls/AKAThemeViewCustomization.h>
#import <AKAControls/AKAThemeLayout.h>

#pragma mark - AKAThemeViewCustomization
#pragma mark -

@class AKATheme;
@protocol AKAThemeDelegate<
    AKAThemeViewCustomizationDelegate,
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

@interface AKAThemeChangeRecorderDelegate: NSObject<AKAThemeDelegate>

@property(nonatomic) AKATheme* recordedTheme;

@end

@interface AKATheme : NSObject

#pragma mark - Initialization

+ (instancetype)themeWithDictionary:(NSDictionary*)specification;

- (instancetype)initWithDictionary:(NSDictionary*)specification;

#pragma mark - Application

- (void)applyToTarget:(UIView*)target
            withViews:(NSDictionary*)views
             delegate:(NSObject<AKAThemeDelegate>*)delegate;

#pragma mark - Configuration

@property(nonatomic, weak) NSObject<AKAThemeDelegate>* delegate;

@property(nonatomic, readonly) NSArray* viewCustomizations;
@property(nonatomic) NSDictionary* defaultMetrics;
@property(nonatomic, readonly) NSArray* layouts;

@end
