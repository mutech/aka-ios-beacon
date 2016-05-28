//
//  UISegmentedControl+IBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 20.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit.UISegmentedControl;
#import "AKAControlViewProtocol.h"


IB_DESIGNABLE
@interface UISegmentedControl (IBBindingProperties_valueBinding) <AKAControlViewProtocol>

@property(nonatomic) IBInspectable NSString* valueBinding_aka;

@end
