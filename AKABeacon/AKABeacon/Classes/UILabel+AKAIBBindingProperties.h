//
//  UILabel+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit.UILabel;

IB_DESIGNABLE
@interface UILabel (AKAIBBindingProperties)

@property(nonatomic, nullable)IBInspectable NSString* textBinding_aka;
@property(nonatomic, nullable)IBInspectable NSString* fontBinding_aka;

@end
