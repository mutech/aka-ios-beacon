//
// Created by Michael Utech on 25.03.15.
// Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKAThemeViewCustomization;

@protocol AKAThemeViewCustomizationDelegate <NSObject>

@optional
- (void)viewCustomizations:(AKAThemeViewCustomization*)customization
      willBeAppliedToView:(id)view;

@optional
- (BOOL)viewCustomizations:(AKAThemeViewCustomization *)customization
         shouldSetProperty:(NSString*)name
                     value:(id)oldValue
                        to:(id)newValue;

@optional
- (void)viewCustomizations:(AKAThemeViewCustomization *)customization
            didSetProperty:(NSString *)name
                     value:(id)oldValue
                        to:(id)newValue;

@optional
- (void)viewCustomizations:(AKAThemeViewCustomization*)customizations
     haveBeenAppliedToView:(id)view;

@end

@interface AKAThemeViewCustomization: NSObject

#pragma mark Initialization

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

#pragma mark - Configuration

@property (nonatomic, weak) NSObject<AKAThemeViewCustomizationDelegate>* delegate;

#pragma mark Properties

@property(nonatomic) NSString* viewKey;

#pragma mark Configuration

- (void)setRequiresViewsOfTypeIn:(NSArray*)validTypes;
- (void)setRequiresViewsOfTypeNotIn:(NSArray*)invalidTypes;

- (void)addCustomizationSetValue:(id)value forPropertyName:(NSString*)name;
- (void)removeCustomizationSetValueForPropertyName:(NSString*)name;

#pragma mark Application

- (BOOL)isApplicableToView:(id)view;

- (BOOL)applyToViews:(NSDictionary *)views
            delegate:(id<AKAThemeViewCustomizationDelegate>)delegate;
- (BOOL)applyToView:(id)view
           delegate:(id<AKAThemeViewCustomizationDelegate>)delegate;
@end
