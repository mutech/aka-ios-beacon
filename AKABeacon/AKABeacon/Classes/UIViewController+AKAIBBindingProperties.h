//
//  UIViewController+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 13.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKABindingBehaviourViewController.h"

@interface UIViewController (AKAIBBindingProperties)

#pragma mark - Binding Support

- (void)aka_enableBindingSupport;

@property(nonatomic, nullable,
          setter=aka_setBindingBehaviour:
          )                 AKABindingBehaviourViewController*  aka_bindingBehaviour;

@end
