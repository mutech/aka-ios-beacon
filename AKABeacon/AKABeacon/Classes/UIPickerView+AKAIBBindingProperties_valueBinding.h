//
//  UIPickerView+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 24.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit.UIPickerView;
#import "AKAControlViewProtocol.h"


IB_DESIGNABLE
@interface UIPickerView (AKAIBBindingProperties_valueBinding) <AKAControlViewProtocol>

@property(nonatomic) IBInspectable NSString* valueBinding_aka;

@end
