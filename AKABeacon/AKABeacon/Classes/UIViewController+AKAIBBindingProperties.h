//
//  UIViewController+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 13.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKABindingBehavior.h"

@interface UIViewController (AKAIBBindingProperties)

#pragma mark - Binding Support

@property(nonatomic, nullable, readonly) AKABindingBehavior *  aka_bindingBehaviour;

@end
