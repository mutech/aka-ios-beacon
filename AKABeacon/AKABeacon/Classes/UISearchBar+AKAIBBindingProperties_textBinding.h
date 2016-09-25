//
//  UISearchBar+AKAIBBindingProperties_textBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 21.09.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit.UISearchBar;
#import "AKAControlViewProtocol.h"

IB_DESIGNABLE
@interface UISearchBar (AKAIBBindingProperties_textBinding) <AKAControlViewProtocol>

@property(nonatomic, nullable) IBInspectable NSString* textBinding_aka;

@end
