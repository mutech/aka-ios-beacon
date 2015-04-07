//
//  UIView+AKAThemeProvider.h
//  AKAControls
//
//  Created by Michael Utech on 24.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AKATheme;

@interface UIView (AKAThemeProvider)

- (AKATheme *)aka_defaultThemeForClass:(Class)type;
- (AKATheme *)aka_themeWithName:(NSString *)name forClass:(Class)type;
- (void)aka_setTheme:(AKATheme *)theme withName:(NSString *)name forClass:(Class)class;

@end