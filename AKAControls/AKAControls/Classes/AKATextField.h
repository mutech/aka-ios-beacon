//
//  AKATextField.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAControlViewProtocol.h"
#import "AKATextFieldControlViewBinding.h"

IB_DESIGNABLE
@interface AKATextField: UITextField<AKAControlViewProtocol>

#pragma mark - Interface Builder Properties

@property(nonatomic) IBInspectable NSString* controlName;
@property(nonatomic) IBInspectable NSString* role;
@property(nonatomic) IBInspectable NSString* valueKeyPath;

@property(nonatomic) IBInspectable BOOL liveModelUpdates;
@property(nonatomic) IBInspectable BOOL autoActivate;
@property(nonatomic) IBInspectable BOOL KBActivationSequence;

@end
