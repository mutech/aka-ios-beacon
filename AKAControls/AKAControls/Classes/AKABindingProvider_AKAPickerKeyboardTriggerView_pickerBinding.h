//
//  AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding.h
//  AKAControls
//
//  Created by Michael Utech on 04.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//


#import "AKABindingProvider.h"
#import "AKAKeyboardActivationSequence.h"

@interface AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding : AKABindingProvider

@end

#pragma mark - AKABinding_AKAPickerKeyboardTriggerView_pickerBinding - Interface
#pragma mark -

@interface AKABinding_AKAPickerKeyboardTriggerView_pickerBinding: AKABinding<
    AKAKeyboardActivationSequenceItemProtocol
>

@property(nonatomic, readonly, weak) id<AKABindingContextProtocol>  bindingContext;

@property(nonatomic, readonly) AKABindingExpression*                choicesBindingExpression;
@property(nonatomic, readonly) opt_NSString                         textForUndefinedValue;
@property(nonatomic, readonly) opt_NSString                         textForOtherValue;

@property(nonatomic, readonly) BOOL                                 autoActivate;
@property(nonatomic, readonly) BOOL                                 KBActivationSequence;
@property(nonatomic, readonly) BOOL                                 liveModelUpdates;

@property(nonatomic, readonly) BOOL                                 needsReloadChoices;
@property(nonatomic, readonly) id                                   otherValue;

@end

