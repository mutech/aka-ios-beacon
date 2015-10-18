//
//  AKAPickerKeyboardTriggerView.m
//  AKAControls
//
//  Created by Michael Utech on 02.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAAssociatedValues;

#import "AKAPickerKeyboardTriggerView.h"
#import "AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding.h"
#import "AKAKeyboardControl.h"


@implementation AKAPickerKeyboardTriggerView

- (NSString*)              pickerBinding_aka
{
    AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding* provider =
        [AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding sharedInstance];

    return [provider bindingExpressionTextForSelector:@selector(pickerBinding_aka)
                                               inView:self];
}

- (void)                setPickerBinding_aka:(opt_NSString)pickerBinding
{
    AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding* provider =
        [AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding sharedInstance];

    [provider setBindingExpressionText:pickerBinding
                           forSelector:@selector(pickerBinding_aka)
                                inView:self];
}

- (void)           setupControlConfiguration:(AKAMutableControlConfiguration*)controlConfiguration
{
    controlConfiguration[kAKAControlViewBinding] = NSStringFromSelector(@selector(pickerBinding_aka));
}

@end
