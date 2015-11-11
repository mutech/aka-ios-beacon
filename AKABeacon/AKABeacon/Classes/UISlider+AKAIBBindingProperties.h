//
//  UISlider+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 30.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAControlViewProtocol.h"

@interface UISlider (AKAIBBindingProperties) <AKAControlViewProtocol>

@property(nonatomic) IBInspectable NSString* valueBinding_aka;

@end
