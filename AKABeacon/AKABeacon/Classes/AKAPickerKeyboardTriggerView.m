//
//  AKAPickerKeyboardTriggerView.m
//  AKABeacon
//
//  Created by Michael Utech on 02.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "NSObject+AKAAssociatedValues.h"

#import "AKAPickerKeyboardTriggerView.h"

#import "AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.h"
#import "AKAViewBinding+IBPropertySupport.h"
#import "AKAKeyboardControl.h"


@implementation AKAPickerKeyboardTriggerView

- (NSString*)              pickerBinding_aka
{
    return [AKABinding_AKAPickerKeyboardTriggerView_pickerBinding bindingExpressionTextForSelector:@selector(pickerBinding_aka)
                                                                                            inView:self];
}

- (void)                setPickerBinding_aka:(opt_NSString)pickerBinding
{
    [AKABinding_AKAPickerKeyboardTriggerView_pickerBinding setBindingExpressionText:pickerBinding
                                                                        forSelector:@selector(pickerBinding_aka)
                                                                             inView:self];
}

- (void)           setupControlConfiguration:(AKAMutableControlConfiguration*)controlConfiguration
{
    controlConfiguration[kAKAControlViewBinding] = NSStringFromSelector(@selector(pickerBinding_aka));
}

@end
