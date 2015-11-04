//
//  AKAThemableContainerView.h
//  AKABeacon
//
//  Created by Michael Utech on 27.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AKAThemeNameInherited @"inherited"
#define AKAThemeNameNone @"none"
#define AKAThemeNameDefault @"default"

IB_DESIGNABLE
@interface AKAThemableContainerView : UIView

/**
 * The name of the theme to apply to this view and its subviews.
 * 
 */
@property (nonatomic)IBInspectable NSString* themeName;

@property (nonatomic)IBInspectable BOOL IBEnablePreview;

@end
