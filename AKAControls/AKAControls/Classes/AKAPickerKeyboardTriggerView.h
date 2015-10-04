//
//  AKAPickerKeyboardTriggerView.h
//  AKAControls
//
//  Created by Michael Utech on 02.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKACustomKeyboardResponderView.h"

IB_DESIGNABLE
@interface AKAPickerKeyboardTriggerView : AKACustomKeyboardResponderView

@property(nonatomic) IBInspectable NSString* pickerBinding;

@end
