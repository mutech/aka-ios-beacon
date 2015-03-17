//
//  AKAControlViewBinding.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKAControlViewDelegate.h"

@class UIView;
@class AKAControl;
@class AKAProperty;

@interface AKAControlViewBinding : NSObject<AKAControlViewDelegate>

/**
 * Provides access to the view's value.
 */
@property(nonatomic, strong, readonly) AKAProperty* viewValueProperty;

@property(nonatomic, weak, readonly) AKAControl* control;

@property(nonatomic, weak, readonly) UIView* view;

@end
