//
//  AKAControlViewDelegate.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AKAControlViewDelegate <NSObject>

- (void)                controlView:(UIView*)controlView
          didChangeValueChangedFrom:(id)oldValue
                                 to:(id)newValue;

#pragma mark - Activation

- (BOOL)controlViewShouldActivate:(UIView*)controlView;
- (void)controlViewDidActivate:(UIView *)controlView;
- (BOOL)controlViewShouldDeactivate:(UIView*)controlView;
- (void)controlViewDidDeactivate:(UIView *)controlView;

- (BOOL)controlViewShouldActivateNextControl:(UIView*)controlView;
- (void)controlViewRequestsActivateNextControl:(UIView*)controlView;

@end
