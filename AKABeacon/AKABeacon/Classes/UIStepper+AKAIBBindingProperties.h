//
//  UIStepper+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 09.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAControlViewProtocol.h"

@interface UIStepper (AKAIBBindingProperties) <AKAControlViewProtocol>

@property(nonatomic) IBInspectable NSString* valueBinding_aka;

@end
