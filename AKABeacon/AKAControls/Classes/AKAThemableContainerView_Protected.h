//
//  AKAThemableContainerView_Protected.h
//  AKABeacon
//
//  Created by Michael Utech on 29.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKASubviewsSpecification.h"
#import "AKAThemableContainerView.h"
#import "AKATheme.h"

@interface AKAThemableContainerView (Protected) <
    AKASubviewsSpecificationDelegate,
    AKAThemeDelegate
>

#pragma mark - Configuration

- (void)setupDefaultValues;

+ (AKASubviewsSpecification*)subviewsSpecification;

+ (NSDictionary*)builtinThemes;

#pragma mark - Access

- (NSDictionary*)viewsParticipatingInTheme;

#pragma mark - Theme changes

- (void)setNeedsApplySelectedTheme;

@end
