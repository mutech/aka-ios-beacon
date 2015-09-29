//
//  UITextField+AKAIBBindingProperties.h
//  AKAControls
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit.UITextField;

IB_DESIGNABLE
@interface UITextField(AKAIBBindingProperties)

@property(nonatomic, nullable) IBInspectable NSString* textBinding;

@end

