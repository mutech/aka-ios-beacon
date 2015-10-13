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

#import <AKAControls/AKAControl.h>
#import <AKAControls/AKAControl_Protected.h>
#import <AKAControls/AKAControlDelegate.h>
#import <AKAControls/AKACompositeControl.h>
#import <AKAControls/AKATableViewCellCompositeControl.h>
#import <AKAControls/AKADynamicPlaceholderTableViewCellCompositeControl.h>
#import <AKAControls/AKAFormControl.h>

#import <AKAControls/AKAControlViewProtocol.h>
#import "AKAObsoleteViewBinding.h"
#import <AKAControls/UIView+AKABinding.h>
#import "AKAObsoleteViewBindingConfiguration.h"
#import <AKAControls/AKACompositeViewBindingConfiguration.h>
#import <AKAControls/AKAControlValidatorProtocol.h>
#import <AKAControls/AKAControlConverterProtocol.h>
#import <AKAControls/AKAKeyboardActivationSequence.h>
#import <AKAControls/AKAKeyboardActivationSequenceItemProtocol.h>
#import <AKAControls/AKAKeyboardActivationSequenceAccessoryView.h>

// AKAControls/Converters
#import <AKAControls/AKANumberTextConverter.h>
#import <AKAControls/AKABooleanTextConverter.h>

// AKAControls/Validators
#import <AKAControls/AKAEmailValidator.h>

// AKAControls/ControlViews

// AKAControls/ControlViews/ScalarControlViews
#import <AKAControls/AKATextLabel.h>
#import <AKAControls/AKATextLabelBinding.h>
#import <AKAControls/AKABooleanLabel.h>
#import <AKAControls/AKABooleanLabelBinding.h>
#import <AKAControls/AKATextField.h>
#import <AKAControls/AKATextField_Protected.h>
#import <AKAControls/AKATextFieldBinding.h>
#import <AKAControls/AKANumberTextField.h>
#import <AKAControls/AKASwitch.h>
#import <AKAControls/AKASwitchBinding.h>
//#import <AKAControls/AKAPickerView.h>
//#import <AKAControls/AKAPickerViewBinding.h>

// AKAControls/ControlViews/CompositeControlViews
#import <AKAControls/AKACompositeControlView.h>
#import <AKAControls/AKAThemableCompositeControlView.h>
#import <AKAControls/AKAEditorControlView.h>
#import <AKAControls/AKAEditorControlView_Protected.h>
#import <AKAControls/AKATextEditorControlView.h>
#import <AKAControls/AKANumberEditorControlView.h>
#import <AKAControls/AKAPasswordEditorControlView.h>
#import <AKAControls/AKASwitchEditorControlView.h>
#import <AKAControls/AKATableViewCell.h>
#import <AKAControls/AKADynamicPlaceholderTableViewCell.h>

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

// AKAControls/ViewControllers
#import <AKAControls/AKAFormViewController.h>
#import <AKAControls/AKAFormTableViewController.h>

#import <AKAControls/AKAPickerView.h>
#import <AKAControls/AKAPickerViewBinding.h>
#import <AKAControls/AKASingleChoiceEditorControlView.h>

// AKAControls/Bindings (new)
#import <AKAControls/AKABinding.h>
#import <AKAControls/AKABindingDelegate.h>
#import <AKAControls/AKABindingExpression.h>
#import <AKAControls/AKABindingSpecification.h>
#import <AKAControls/NSScanner+AKABindingExpressionParser.h>
#import <AKAControls/AKABindingProvider.h>
#import <AKAControls/AKABindingProviderRegistry.h>
#import <AKAControls/AKABindingContextProtocol.h>

#import <AKAControls/UIView+AKABindingSupport.h>
#import <AKAControls/UITextField+AKAIBBindingProperties.h>

#import <AKAControls/AKAPropertyBinding.h>
#import <AKAControls/AKABinding_AKABinding_formatter.h>
#import <AKAControls/AKABinding_AKABinding_numberFormatter.h>
#import <AKAControls/AKABinding_AKABinding_dateFormatter.h>

#import <AKAControls/AKAPickerKeyboardTriggerView.h>
#import <AKAControls/AKACustomKeyboardResponderView.h>
#import <AKAControls/AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding.h>
#import <AKAControls/AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.h>

#import <AKAControls/AKADatePickerKeyboardTriggerView.h>
#import <AKAControls/AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding.h>
#import <AKAControls/AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding.h>

#import <AKAControls/UILabel+AKAIBBindingProperties.h>
#import <AKAControls/AKABindingProvider_UILabel_textBinding.h>

#import <AKAControls/UITextField+AKAIBBindingProperties.h>
#import <AKAControls/AKABindingProvider_UITextField_textBinding.h>

#import <AKAControls/UITextView+AKAIBBindingProperties.h>
#import <AKAControls/AKABindingProvider_UITextView_textBinding.h>
#import <AKAControls/AKABinding_UITextView_textBinding.h>

#import <AKAControls/UISwitch+AKAIBBindingProperties.h>
#import <AKAControls/AKABindingProvider_UISwitch_stateBinding.h>

// Interfacing

#import <AKAControls/AKANSEnumerations.h>
