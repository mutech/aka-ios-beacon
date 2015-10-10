//
//  AKADatePickerKeyboardTriggerView.m
//  AKAControls
//
//  Created by Michael Utech on 08.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKADatePickerKeyboardTriggerView.h"

#import "AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding.h"


@implementation AKADatePickerKeyboardTriggerView

- (NSString*)              datePickerBinding
{
    AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding* provider =
        [AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(datePickerBinding)
                                               inView:self];
}

- (void)                 setDatePickerBinding:(opt_NSString)datePickerBinding
{
    AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding* provider =
        [AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding sharedInstance];

    [provider setBindingExpressionText:datePickerBinding
                           forSelector:@selector(datePickerBinding)
                                inView:self];
}

@end
