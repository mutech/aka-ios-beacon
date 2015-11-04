//
//  AKAThemeProviderProtocol.h
//  AKABeacon
//
//  Created by Michael Utech on 24.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKATheme;

@protocol AKAThemeProviderProtocol <NSObject>

#pragma mark - Accessing Themes

- (AKATheme*)themeWithName:(NSString*)name forClass:(Class)type;

- (AKATheme*)defaultThemeForClass:(Class)type;

#pragma mark - Adding and removing themes

- (void)setTheme:(AKATheme*)theme withName:(NSString*)name forClass:(Class)class;

- (void)setDefaultTheme:(AKATheme*)theme forClass:(Class)class;

@end
