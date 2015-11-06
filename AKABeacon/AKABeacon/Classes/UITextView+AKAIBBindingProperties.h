//
//  UITextView+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 09.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAControlViewProtocol.h"


@interface UITextView (AKAIBBindingProperties) <AKAControlViewProtocol>

@property(nonatomic, nullable) IBInspectable NSString*textBinding_aka;

@end
