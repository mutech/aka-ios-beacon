//
//  AKAControlDelegate.h
//  AKAControls
//
//  Created by Michael Utech on 17.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKAControl;

@protocol AKAControlDelegate <NSObject>

#pragma mark Activation

- (BOOL)shouldControlActivate:(AKAControl*)memberControl;

- (void)controlDidActivate:(AKAControl*)memberControl;

- (BOOL)shouldControlDeactivate:(AKAControl*)memberControl;

- (void)controlDidDeactivate:(AKAControl*)memberControl;

@end
