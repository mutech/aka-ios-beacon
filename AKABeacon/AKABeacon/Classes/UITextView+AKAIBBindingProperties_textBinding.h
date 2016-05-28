//
//  UITextView+AKAIBBindingProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 09.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit.UITextView;
#import "AKAControlViewProtocol.h"


IB_DESIGNABLE
@interface UITextView (AKAIBBindingProperties_textBinding) <AKAControlViewProtocol>

@property(nonatomic, nullable) IBInspectable NSString* textBinding_aka;

@end
