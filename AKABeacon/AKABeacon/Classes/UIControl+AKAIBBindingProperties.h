//
//  UIControl+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 21.03.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>


IB_DESIGNABLE
@interface UIControl (AKAIBBindingProperties)

@property(nonatomic) IBInspectable NSString* enabledBinding_aka;

@end


IB_DESIGNABLE
@interface UIBarButtonItem (AKAIBBindingProperties)

@property(nonatomic) IBInspectable NSString* enabledBinding_aka;

@end