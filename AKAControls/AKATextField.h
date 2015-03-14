//
//  AKATextField.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAControlViewProtocol.h"

IB_DESIGNABLE
@interface AKATextField : UITextField<AKAEditingControlViewProtocol>

#pragma mark - Interface Builder Properties

@property(nonatomic) IBInspectable NSString* valueKeyPath;
@property(nonatomic) IBInspectable BOOL liveModelUpdates;

@end
