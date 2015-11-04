//
//  AKADatePickerKeyboardTriggerView.m
//  AKABeacon
//
//  Created by Michael Utech on 08.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAAssociatedValues;

#import "AKADatePickerKeyboardTriggerView.h"
#import "AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding.h"
#import "AKAKeyboardControl.h"


@implementation AKADatePickerKeyboardTriggerView

- (NSString*)              datePickerBinding_aka
{
    AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding* provider =
        [AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(datePickerBinding_aka)
                                               inView:self];
}

- (void)                setDatePickerBinding_aka:(opt_NSString)datePickerBinding
{
    AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding* provider =
        [AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding sharedInstance];

    [provider setBindingExpressionText:datePickerBinding
                           forSelector:@selector(datePickerBinding_aka)
                                inView:self];
}

- (void)              setupControlConfiguration:(AKAMutableControlConfiguration*)controlConfiguration
{
    controlConfiguration[kAKAControlViewBinding] = NSStringFromSelector(@selector(datePickerBinding_aka));
}

@end
