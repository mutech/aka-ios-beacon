//
//  UIView+AKAThemeProvider.m
//  AKABeacon
//
//  Created by Michael Utech on 24.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "UIView+AKAThemeProvider.h"
#import "AKAThemeProviderProtocol.h"

#import <objc/runtime.h>

@implementation UIView (AKAThemeProvider)

#pragma mark - Protocol implementation

- (AKATheme *)aka_defaultThemeForClass:(Class)type
{
    AKATheme* result = [self aka_getDefaultThemeForClass:type];
    if (!result)
    {
        result = [self.superview aka_getDefaultThemeForClass:type];
    }
    return result;
}

- (AKATheme *)aka_themeWithName:(NSString *)name forClass:(Class)type
{
    AKATheme* result = [self aka_getThemeWithName:name forClass:type];
    if (!result)
    {
        result = [self.superview aka_themeWithName:name forClass:type];
    }
    return result;
}

// Warning: "No method with selector '...' is implemented in compilation unit"
// The methods for these selectors exist, ignoring the warning.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"

- (void)aka_setTheme:(AKATheme *)theme
            withName:(NSString *)name
            forClass:(Class)class
{
    if ([self conformsToProtocol:@protocol(AKAThemeProviderProtocol)] &&
        [self respondsToSelector:@selector(setTheme:withName:forClass:)])
    {
        [self performSelector:@selector(setTheme:withName:forClass:)
                   withObject:name
                withObject:class];
    }
    else
    {
        BOOL create = (theme != nil);
        NSMutableDictionary* themes = [self aka_getThemesForClass:class createIfMissing:create];
        if (themes && theme)
        {
            themes[name] = theme;
        }
    }
    return;
}

#pragma mark - Implemenentation - Local access

- (AKATheme *)aka_getDefaultThemeForClass:(Class)type
{
    AKATheme* result = nil;
    if ([self conformsToProtocol:@protocol(AKAThemeProviderProtocol)] &&
        [self respondsToSelector:@selector(defaultThemeForClass:)])
    {
        result = [self performSelector:@selector(defaultThemeForClass:)
                            withObject:type];
    }
    else if (result == nil)
    {
        result = [self aka_getThemeWithName:@"default" forClass:type];
    }
    return result;
}

- (AKATheme *)aka_getThemeWithName:(NSString *)name forClass:(Class)type
{
    AKATheme* result = nil;
    if ([self conformsToProtocol:@protocol(AKAThemeProviderProtocol)] &&
        [self respondsToSelector:@selector(themeWithName:forClass:)])
    {
        result = [self performSelector:@selector(themeWithName:forClass:)
                            withObject:type];
    }
    else if (result == nil)
    {
        NSDictionary* themes = [self aka_getThemesForClass:type];
        result = themes[name];
    }
    return result;
}

#pragma clang diagnostic pop

#pragma mark - Implementation - Theme collections

- (NSDictionary*)aka_getThemesForClass:(Class)type
{
    return [self aka_getThemesForClass:type createIfMissing:NO];
}

- (NSMutableDictionary*)aka_getThemesForClass:(Class)type
                              createIfMissing:(BOOL)createIfMissing;
{
    NSMutableDictionary* result = nil;
    NSMutableDictionary* allThemes = [self aka_getThemesCreateIfMissing:createIfMissing];
    if (allThemes != nil)
    {
        result = allThemes[type];
        if (result == nil && createIfMissing)
        {
            result = NSMutableDictionary.new;
            // This works, but Class does not conform to NSCopying protocol:
            allThemes[(id<NSCopying>)type] = result;
        }
    }
    return result;
}

- (NSMutableDictionary*)aka_getThemesCreateIfMissing:(BOOL)createIfMissing;
{
    static char associationKey;
    id result = objc_getAssociatedObject(self, &associationKey);
    if (result == nil)
    {
        if (createIfMissing)
        {
            result = NSMutableDictionary.new;
            objc_setAssociatedObject(self, &associationKey, result, OBJC_ASSOCIATION_RETAIN);
        }
    }
    return result;
}

@end
