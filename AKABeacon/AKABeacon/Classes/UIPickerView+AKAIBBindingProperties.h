//
//  UIPickerView+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 24.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAControlViewProtocol.h"

@interface UIPickerView (AKAIBBindingProperties) <AKAControlViewProtocol>

@property(nonatomic) IBInspectable NSString* valueBinding_aka;

@end
