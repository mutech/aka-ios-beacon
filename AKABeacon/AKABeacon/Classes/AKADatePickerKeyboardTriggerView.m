//
//  AKADatePickerKeyboardTriggerView.m
//  AKABeacon
//
//  Created by Michael Utech on 08.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "NSObject+AKAAssociatedValues.h"

#import "AKADatePickerKeyboardTriggerView.h"

#import "AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding.h"
#import "AKAViewBinding+IBPropertySupport.h"
#import "AKAKeyboardControl.h"


@implementation AKADatePickerKeyboardTriggerView

- (NSString*)              datePickerBinding_aka
{
    return [AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding bindingExpressionTextForSelector:@selector(datePickerBinding_aka)
                                                                                                    inView:self];
}

- (void)                setDatePickerBinding_aka:(opt_NSString)datePickerBinding
{
    [AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding setBindingExpressionText:datePickerBinding
                                                                                forSelector:@selector(datePickerBinding_aka)
                                                                                     inView:self];
}

- (void)              setupControlConfiguration:(AKAMutableControlConfiguration*)controlConfiguration
{
    controlConfiguration[kAKAControlViewBinding] = NSStringFromSelector(@selector(datePickerBinding_aka));
}

@end
