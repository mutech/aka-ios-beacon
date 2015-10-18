//
//  UISwitch+AKAIBBindingProperties.h
//  AKAControls
//
//  Created by Michael Utech on 29.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAControlViewProtocol.h"


@interface UISwitch (AKAIBBindingProperties) <AKAControlViewProtocol>

@property(nonatomic, nullable) IBInspectable NSString* stateBinding_aka;

@end
