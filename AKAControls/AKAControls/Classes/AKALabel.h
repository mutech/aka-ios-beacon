//
//  AKALabel.h
//  AKACommons
//
//  Created by Michael Utech on 14.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAControlViewProtocol.h"

IB_DESIGNABLE
@interface AKALabel : UILabel<AKAControlViewProtocol>

#pragma mark - Interface Builder Properties

@property(nonatomic) IBInspectable NSString* controlName;
@property(nonatomic) IBInspectable NSString* role;
@property(nonatomic) IBInspectable NSString* valueKeyPath;

@end
