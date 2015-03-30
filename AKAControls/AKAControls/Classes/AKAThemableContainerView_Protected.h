//
//  AKAThemableContainerView_Protected.h
//  AKAControls
//
//  Created by Michael Utech on 29.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKASubviewsSpecification.h"
#import <AKAControls/AKAThemableContainerView.h>
#import <AKAControls/AKATheme.h>

@interface AKAThemableContainerView (Protected) <
    AKASubviewsSpecificationDelegate,
    AKAThemeDelegate
>

#pragma mark - Configuration

+ (AKASubviewsSpecification*)subviewsSpecification;

+ (NSDictionary*)builtinThemes;

#pragma mark - Access

- (NSDictionary*)viewsParticipatingInTheme;

@end
