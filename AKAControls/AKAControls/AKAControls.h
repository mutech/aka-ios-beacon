//
//  AKAControls.h
//  AKAControls
//
//  Created by Michael Utech on 17.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for AKAControls.
FOUNDATION_EXPORT double AKAControlsVersionNumber;

//! Project version string for AKAControls.
FOUNDATION_EXPORT const unsigned char AKAControlsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AKAControls/PublicHeader.h>

#import <AKAControls/AKAControlsErrors.h>
#import <AKAControls/AKAControlsStyleKit.h>

// ViewControllers
#import <AKAControls/AKAFormViewController.h>
#import <AKAControls/AKAFormTableViewController.h>


// Controls
#import <AKAControls/AKAControlConfiguration.h>
#import <AKAControls/AKAControlDelegate.h>
#import <AKAControls/AKAControl.h>
#import <AKAControls/AKAControl+BindingDelegate.h>

// ScalarControls
#import <AKAControls/AKAScalarControl.h>
#import <AKAControls/AKAScalarControl_Protected.h>
#import <AKAControls/AKAScalarControl+ControlViewBindingDelegate.h>
#import <AKAControls/AKAKeyboardControl.h>

// ComplexControls
#import <AKAControls/AKACompositeControl.h>
#import <AKAControls/AKACompositeControl+BindingDelegatePropagation.h>
#import <AKAControls/AKATableViewCellCompositeControl.h>
#import <AKAControls/AKADynamicPlaceholderTableViewCellCompositeControl.h>
#import <AKAControls/AKAFormControl.h>
#import <AKAControls/AKAFormControl+BindingDelegatePropagation.h>

#import <AKAControls/AKAControlViewProtocol.h>
#import <AKAControls/AKAControlValidatorProtocol.h>
#import <AKAControls/AKAControlConverterProtocol.h>


// Bindings
#import <AKAControls/AKABindingDelegate.h>
#import <AKAControls/AKABinding.h>
#import <AKAControls/AKABindingProviderRegistry.h>
#import <AKAControls/AKABindingProvider.h>
#import <AKAControls/AKABindingContextProtocol.h>
#import <AKAControls/UIView+AKABindingSupport.h>

// Bindings/ViewBindings
#import <AKAControls/AKAViewBinding.h>
#import <AKAControls/AKAControlViewBinding.h>

// Bindings/ViewBindings/UILabel
#import <AKAControls/UILabel+AKAIBBindingProperties.h>
#import <AKAControls/AKABindingProvider_UILabel_textBinding.h>

// Bindings/ViewBindings/ControlViewBindings
#import <AKAControls/AKAControlViewBindingDelegate.h>

// Bindings/ViewBindings/ControlViewBindings/UISwitch
#import <AKAControls/UISwitch+AKAIBBindingProperties.h>
#import <AKAControls/AKABinding_UISwitch_stateBinding.h>
#import <AKAControls/AKABindingProvider_UISwitch_stateBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings
#import <AKAControls/AKAKeyboardControlViewBinding.h>
#import <AKAControls/AKAKeyboardControlViewBindingDelegate.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/UITextField
#import <AKAControls/UITextField+AKAIBBindingProperties.h>
#import <AKAControls/AKABinding_UITextField_textBinding.h>
#import <AKAControls/AKABindingProvider_UITextField_textBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/UITextView
#import <AKAControls/UITextView+AKAIBBindingProperties.h>
#import <AKAControls/AKABindingProvider_UITextView_textBinding.h>
#import <AKAControls/AKABinding_UITextView_textBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/CustomKeyboard
#import <AKAControls/AKACustomKeyboardResponderView.h>
#import <AKAControls/AKAKeyboardBinding_AKACustomKeyboardResponderView.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/CustomKeyboard/AKAPickerKeyboard
#import <AKAControls/AKAPickerKeyboardTriggerView.h>
#import <AKAControls/AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding.h>
#import <AKAControls/AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/CustomKeyboard/AKADatePickerKeyboard
#import <AKAControls/AKADatePickerKeyboardTriggerView.h>
#import <AKAControls/AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding.h>
#import <AKAControls/AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding.h>

// Bindings/ViewBindings/ControlViewBindings/CompositeControlViewBindings
#import <AKAControls/AKACompositeControlView.h>
#import <AKAControls/AKAThemableCompositeControlView.h>
#import <AKAControls/AKAEditorControlView.h>
#import <AKAControls/AKAEditorControlView_Protected.h>
#import <AKAControls/AKATextEditorControlView.h>
#import <AKAControls/AKASwitchEditorControlView.h>
#import <AKAControls/AKATableViewCell.h>
#import <AKAControls/AKADynamicPlaceholderTableViewCell.h>

// Bindings/PropertyBindings
#import <AKAControls/AKAPropertyBinding.h>
#import <AKAControls/AKABinding_AKABinding_formatter.h>
#import <AKAControls/AKABinding_AKABinding_numberFormatter.h>
#import <AKAControls/AKABinding_AKABinding_dateFormatter.h>
#import <AKAControls/AKANSEnumerations.h>

// Bindings/Specification
#import <AKAControls/AKABindingExpression.h>
#import <AKAControls/AKABindingSpecification.h>
#import <AKAControls/NSScanner+AKABindingExpressionParser.h>


// KeyboardActivationSequence
#import <AKAControls/AKAKeyboardActivationSequence.h>
#import <AKAControls/AKAKeyboardActivationSequenceItemProtocol.h>
#import <AKAControls/AKAKeyboardActivationSequenceAccessoryView.h>


// AKAControls/Themes
#import <AKAControls/AKAThemeProviderProtocol.h>
#import <AKAControls/UIView+AKAThemeProvider.h>
#import <AKAControls/AKATheme.h>
#import <AKAControls/AKAThemeViewApplicability.h>
#import <AKAControls/AKAViewCustomization.h>
#import <AKAControls/AKAThemeLayout.h>
#import <AKAControls/AKALayoutConstraintSpecification.h>
#import <AKAControls/AKAThemableContainerView.h>
#import <AKAControls/AKAThemableContainerView_Protected.h>
#import <AKAControls/AKASubviewsSpecification.h>


// Obsolete/Converter
#import <AKAControls/AKANumberTextConverter.h>
#import <AKAControls/AKABooleanTextConverter.h>

// Obsolete/Validators
#import <AKAControls/AKAEmailValidator.h>
