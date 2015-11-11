//
//  AKABeacon.h
//  AKABeacon
//
//  Created by Michael Utech on 17.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

// TODO: move/copy this to troubleshooting docs:
//
// Please note that since Cocoapods generate their own umbrella header, this file
// is not used when Beacon is integrated using Cocoapods. This should be transparent for you
// if you use @import AKABeacon. To avoid conflicts, this header is marked private in the podspec.
// If you want or have to use non-modular imports, use
// AKABeacon/AKABeacon-umbrella.h (the generated header) if integrating from Cocoapods and
// AKABeacon/AKABeacon.h otherwise. Sorry for that.
//
// The current podspec includes this header in source and declares it as private header.
// This seems to be the least troubling setup.
//
// If you get warnings about 'AKABeacon.h' referenced from modules map, check if you have the
// latest version of beacon.
//
// If @import AKABeacon statements fail with errors without reasonable explanation, try to:
//  - Just build or rebuild the project, they might go away immediately
//  - Clean your project (all projects in workspace), rebuild
//  - Delete derived data for XCode (I'm using a plugin for this), rebuild
//  - Refresh views for Storyboards (while in storyboard, Menu>Editor>Refresh all views)
//  - Close storyboard editors (all of them)
//  - Close Xcode and start it again
//  - Different combinations of the above

#import <UIKit/UIKit.h>

//! Project version number for AKAControls.
FOUNDATION_EXPORT double AKABeaconVersionNumber;

//! Project version string for AKAControls.
FOUNDATION_EXPORT const unsigned char AKABeaconVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AKABeacon/PublicHeader.h>

#import "AKABeaconErrors.h"
#import "AKABeaconStyleKit.h"

// ViewControllers
#import <AKABeacon/AKAFormViewController.h>
#import <AKABeacon/AKAFormTableViewController.h>


// Controls
#import <AKABeacon/AKAControlConfiguration.h>
#import <AKABeacon/AKAControlDelegate.h>
#import <AKABeacon/AKAControl.h>
#import <AKABeacon/AKAControl+BindingDelegate.h>

// ScalarControls
#import <AKABeacon/AKAScalarControl.h>
#import <AKABeacon/AKAScalarControl_Protected.h>
#import <AKABeacon/AKAScalarControl+ControlViewBindingDelegate.h>
#import <AKABeacon/AKAKeyboardControl.h>
#import <AKABeacon/AKAKeyboardControl+KeyboardControlViewBindingDelegate.h>

// ComplexControls
#import <AKABeacon/AKACompositeControl.h>
#import <AKABeacon/AKACompositeControl+BindingDelegatePropagation.h>
#import <AKABeacon/AKATableViewCellCompositeControl.h>
#import <AKABeacon/AKADynamicPlaceholderTableViewCellCompositeControl.h>
#import <AKABeacon/AKAFormControl.h>
#import <AKABeacon/AKAFormControl+BindingDelegatePropagation.h>

#import <AKABeacon/AKAControlViewProtocol.h>
#import <AKABeacon/AKAControlValidatorProtocol.h>
#import <AKABeacon/AKAControlConverterProtocol.h>


// Bindings
#import <AKABeacon/AKABindingErrors.h>
#import <AKABeacon/AKABindingDelegate.h>
#import <AKABeacon/AKABinding.h>
#import <AKABeacon/AKABindingProviderRegistry.h>
#import <AKABeacon/AKABindingProvider.h>
#import <AKABeacon/AKABindingContextProtocol.h>
#import <AKABeacon/UIView+AKABindingSupport.h>

// Bindings/ViewBindings
#import <AKABeacon/AKAViewBinding.h>
#import <AKABeacon/AKAControlViewBinding.h>

// Bindings/ViewBindings/UILabel
#import <AKABeacon/UILabel+AKAIBBindingProperties.h>
#import <AKABeacon/AKABindingProvider_UILabel_textBinding.h>

// Bindings/ViewBindings/ControlViewBindings
#import <AKABeacon/AKAControlViewBindingDelegate.h>

// Bindings/ViewBindings/ControlViewBindings/UISwitch
#import <AKABeacon/UISwitch+AKAIBBindingProperties.h>
#import <AKABeacon/AKABinding_UISwitch_stateBinding.h>
#import <AKABeacon/AKABindingProvider_UISwitch_stateBinding.h>

// Bindings/ViewBindings/ControlViewBindings/UISlider
#import <AKABeacon/UISlider+AKAIBBindingProperties.h>
#import <AKABeacon/AKABinding_UISlider_valueBinding.h>
#import <AKABeacon/AKABindingProvider_UISlider_valueBinding.h>

// Bindings/ViewBindings/ControlViewBindings/UIStepper
#import <AKABeacon/UIStepper+AKAIBBindingProperties.h>
#import <AKABeacon/AKABinding_UIStepper_valueBinding.h>
#import <AKABeacon/AKABindingProvider_UIStepper_valueBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings
#import <AKABeacon/AKAKeyboardControlViewBinding.h>
#import <AKABeacon/AKAKeyboardControlViewBindingDelegate.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/UITextField
#import <AKABeacon/UITextField+AKAIBBindingProperties.h>
#import <AKABeacon/AKABinding_UITextField_textBinding.h>
#import <AKABeacon/AKABindingProvider_UITextField_textBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/UITextView
#import <AKABeacon/UITextView+AKAIBBindingProperties.h>
#import <AKABeacon/AKABindingProvider_UITextView_textBinding.h>
#import <AKABeacon/AKABinding_UITextView_textBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/CustomKeyboard
#import <AKABeacon/AKACustomKeyboardResponderView.h>
#import <AKABeacon/AKAKeyboardBinding_AKACustomKeyboardResponderView.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/CustomKeyboard/AKAPickerKeyboard
#import <AKABeacon/AKAPickerKeyboardTriggerView.h>
#import <AKABeacon/AKABindingProvider_AKAPickerKeyboardTriggerView_pickerBinding.h>
#import <AKABeacon/AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/CustomKeyboard/AKADatePickerKeyboard
#import <AKABeacon/AKADatePickerKeyboardTriggerView.h>
#import <AKABeacon/AKABindingProvider_AKADatePickerKeyboardTriggerView_datePickerBinding.h>
#import <AKABeacon/AKABinding_AKADatePickerKeyboardTriggerView_datePickerBinding.h>

// Bindings/ViewBindings/ControlViewBindings/ComplexControlViewBindings
#import <AKABeacon/AKAComplexControlViewBinding.h>

// Bindings/ViewBindings/ControlViewBindings/ComplexControlViewBindings/CompositeControlViewBindings
#import <AKABeacon/AKACompositeControlView.h>
#import <AKABeacon/AKAThemableCompositeControlView.h>
#import <AKABeacon/AKAEditorControlView.h>
#import <AKABeacon/AKAEditorControlView_Protected.h>
#import <AKABeacon/AKATextEditorControlView.h>
#import <AKABeacon/AKASwitchEditorControlView.h>
#import <AKABeacon/AKATableViewCell.h>

// Bindings/ViewBindings/ControlViewBindings/ComplexControlViewBindings/CollectionControlViewBindings
#import <AKABeacon/AKACollectionControlViewBinding.h>
#import <AKABeacon/AKACollectionControlViewBindingDelegate.h>
#import <AKABeacon/AKADynamicPlaceholderTableViewCell.h>

// Bindings/PropertyBindings
#import <AKABeacon/AKAPropertyBinding.h>
#import <AKABeacon/AKABinding_AKABinding_formatter.h>
#import <AKABeacon/AKABinding_AKABinding_numberFormatter.h>
#import <AKABeacon/AKABinding_AKABinding_dateFormatter.h>
#import <AKABeacon/AKANSEnumerations.h>

// Bindings/Specification
#import <AKABeacon/AKABindingExpression.h>
#import <AKABeacon/AKABindingSpecification.h>
#import <AKABeacon/NSScanner+AKABindingExpressionParser.h>


// KeyboardActivationSequence
#import <AKABeacon/AKAKeyboardActivationSequence.h>
#import <AKABeacon/AKAKeyboardActivationSequenceItemProtocol.h>
#import <AKABeacon/AKAKeyboardActivationSequenceAccessoryView.h>


// AKAControls/Themes
#import <AKABeacon/AKAThemeProviderProtocol.h>
#import <AKABeacon/UIView+AKAThemeProvider.h>
#import <AKABeacon/AKATheme.h>
#import <AKABeacon/AKAThemeViewApplicability.h>
#import <AKABeacon/AKAViewCustomization.h>
#import <AKABeacon/AKAThemeLayout.h>
#import <AKABeacon/AKALayoutConstraintSpecification.h>
#import <AKABeacon/AKAThemableContainerView.h>
#import <AKABeacon/AKAThemableContainerView_Protected.h>
#import <AKABeacon/AKASubviewsSpecification.h>


// Obsolete/Converter
#import <AKABeacon/AKANumberTextConverter.h>
#import <AKABeacon/AKABooleanTextConverter.h>

// Obsolete/Validators
#import <AKABeacon/AKAEmailValidator.h>
