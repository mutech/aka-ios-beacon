//
//  UITextField+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit.UITextField;

#import "AKAControlViewProtocol.h"


IB_DESIGNABLE
@interface UITextField(AKAIBBindingProperties) <AKAControlViewProtocol>

@property(nonatomic, nullable) IBInspectable NSString* textBinding_aka;

@end

