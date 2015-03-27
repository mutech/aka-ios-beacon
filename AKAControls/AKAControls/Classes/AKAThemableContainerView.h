//
//  AKAThemableContainerView.h
//  AKAControls
//
//  Created by Michael Utech on 27.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AKAThemableContainerView : UIView

@property (nonatomic)IBInspectable NSString* themeName;

@property (nonatomic)IBInspectable BOOL customLayout;

@end
