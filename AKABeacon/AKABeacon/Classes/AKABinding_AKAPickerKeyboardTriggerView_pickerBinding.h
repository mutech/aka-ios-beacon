//
//  AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 04.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAKeyboardBinding_AKACustomKeyboardResponderView.h"


#pragma mark - AKABinding_AKAPickerKeyboardTriggerView_pickerBinding - Interface
#pragma mark -

@interface AKABinding_AKAPickerKeyboardTriggerView_pickerBinding: AKAKeyboardBinding_AKACustomKeyboardResponderView

@property(nonatomic, readonly) AKABindingExpression*                choicesBindingExpression;
@property(nonatomic, readonly) AKABindingExpression*                titleBindingExpression;
@property(nonatomic, readonly) opt_NSString                         titleForUndefinedValue;
@property(nonatomic, readonly) opt_NSString                         titleForOtherValue;

@property(nonatomic, readonly) BOOL                                 needsReloadChoices;
@property(nonatomic, readonly) id                                   otherValue;

@end


