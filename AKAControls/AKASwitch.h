//
//  AKASwitch.h
//  AKACommons
//
//  Created by Michael Utech on 14.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKASwitch.h"
#import "AKAControlViewProtocol.h"

IB_DESIGNABLE
@interface AKASwitch: UISwitch<AKAEditingControlViewProtocol>

#pragma mark - Interface Builder Properties

@property(nonatomic) IBInspectable NSString* valueKeyPath;

@end
