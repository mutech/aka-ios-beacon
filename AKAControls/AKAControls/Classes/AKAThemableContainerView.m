//
//  AKAThemableContainerView.m
//  AKAControls
//
//  Created by Michael Utech on 27.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAThemableContainerView.h"
#import "AKATheme.h"
#import <AKACommons/AKAErrors.h>

@interface AKAThemableContainerView()

@property(nonatomic) AKATheme* savedTheme;
@property(nonatomic) BOOL needsApplySelectedTheme;

@end

@interface AKAThemableContainerView(Protected)

+ (NSDictionary*)builtinThemes;
- (NSDictionary*)viewsParticipatingInTheme;
- (void)autocreateMissingViewsParticipatingInTheme;

@end

@implementation AKAThemableContainerView

#pragma mark - Abstract Methods

- (NSDictionary *)viewsParticipatingInTheme
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (void)autocreateMissingViewsParticipatingInTheme
{
    AKAErrorAbstractMethodImplementationMissing();
}

+ (NSDictionary*)builtinThemes
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (void)setThemeName:(NSString *)themeName
{
    if (themeName != _themeName && (themeName == nil || ![themeName isEqualToString:_themeName]))
    {
        _themeName = themeName;
        [self setNeedsApplySelectedTheme];
    }
}

- (AKATheme*)selectedTheme
{
    AKATheme* result = nil;
    NSString* theme = self.themeName;
    if (theme.length == 0 || [@"none" isEqualToString:theme])
    {
        result = self.savedTheme;
    }
    else
    {
        result = ([self.class builtinThemes])[theme];
    }
    return result;
}

- (void)setNeedsApplySelectedTheme
{
    self.needsApplySelectedTheme = YES;
    [self setNeedsUpdateConstraints];
}

- (void)applySelectedThemeIfNeeded
{
    if (self.customLayout && self.needsApplySelectedTheme)
    {
        self.needsApplySelectedTheme = NO;
        AKATheme* theme = [self selectedTheme];
        if (theme != nil)
        {
            NSDictionary* views = [self viewsParticipatingInTheme];
            if (self.savedTheme != nil)
            {
                [theme applyToTarget:self
                           withViews:views
                            delegate:nil];
            }
            else
            {
                AKAThemeChangeRecorderDelegate* delegate = [[AKAThemeChangeRecorderDelegate alloc] init];
                [theme applyToTarget:self
                           withViews:views
                            delegate:delegate];
                self.savedTheme = delegate.recordedTheme;
            }
        }
    }
}

- (void)updateConstraints
{
    [self applySelectedThemeIfNeeded];
    [super updateConstraints];
}

@end
