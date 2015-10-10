//
//  AKAPickerKeyboardTriggerView.m
//  AKAControls
//
//  Created by Michael Utech on 02.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAPickerKeyboardTriggerView.h"

#import "AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding.h"

@implementation AKAPickerKeyboardTriggerView

- (NSString*)              pickerBinding
{
    AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding* provider =
        [AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(pickerBinding)
                                               inView:self];
}

- (void)                 setPickerBinding:(opt_NSString)pickerBinding
{
    AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding* provider =
        [AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding sharedInstance];

    [provider setBindingExpressionText:pickerBinding
                           forSelector:@selector(pickerBinding)
                                inView:self];
}

@end
