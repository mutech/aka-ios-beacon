//
//  UIViewController+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 13.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKABindingBehaviourViewController.h"

IB_DESIGNABLE
@interface UIViewController (AKAIBBindingProperties)

#pragma mark - Interface Builder Properties

@property(nonatomic,
          getter=aka_bindingsEnabled,
          setter=aka_setBindingsEnabled:
          ) IBInspectable   BOOL                                bindingsEnabled_aka;

#pragma mark - Binding Support

@property(nonatomic, nullable,
          setter=aka_setBindingBehaviour:
          )                 AKABindingBehaviourViewController*  aka_bindingBehaviour;

@end
