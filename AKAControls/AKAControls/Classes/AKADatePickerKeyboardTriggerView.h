//
//  AKADatePickerKeyboardTriggerView.h
//  AKAControls
//
//  Created by Michael Utech on 08.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKACustomKeyboardResponderView.h"
#import "AKAControlViewProtocol.h"


IB_DESIGNABLE
@interface AKADatePickerKeyboardTriggerView: AKACustomKeyboardResponderView<AKAControlViewProtocol>

@property(nonatomic) IBInspectable NSString* datePickerBinding_aka;

@end
