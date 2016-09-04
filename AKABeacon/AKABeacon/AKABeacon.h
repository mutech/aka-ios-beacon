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

#import <AKABeacon/AKABeaconErrors.h>
#import <AKABeacon/AKABeaconStyleKit.h>
#import <AKABeacon/AKABeaconNullability.h>
#import <AKABeacon/AKANSEnumerations.h>

#import <AKABeacon/AKAContentSizeCategoryChangeListener.h>

// Commons
// Commons/Runtime
#import <AKABeacon/AKAProtocolInfo.h>
#import <AKABeacon/AKADelegateDispatcher.h>

// Commons/Operations
#import <AKABeacon/AKAOperationErrors.h>
#import <AKABeacon/AKAOperationQueue.h>
#import <AKABeacon/AKAOperation.h>
#import <AKABeacon/AKABlockOperation.h>
#import <AKABeacon/AKAGroupOperation.h>
#import <AKABeacon/AKAOperationCondition.h>
#import <AKABeacon/AKANoFailedDependenciesOperationCondition.h>
#import <AKABeacon/AKAOperationObserver.h>
#import <AKABeacon/AKABlockOperationObserver.h>

// Commons/Operations/UIOperations
#import <AKABeacon/AKAPresentViewControllerOperation.h>
#import <AKABeacon/AKAAlertOperation.h>
#import <AKABeacon/AKASendMailOperation.h>

// Commons/AKACommons (Merged from AKACommons)
#import <AKABeacon/AKAArrayComparer.h>
#import <AKABeacon/AKAErrors.h>
#import <AKABeacon/AKALog.h>
#import <AKABeacon/AKAMutableOrderedDictionary.h>
#import <AKABeacon/AKANullability.h>
#import <AKABeacon/AKAProperty.h>
#import <AKABeacon/AKAReference.h>
#import <AKABeacon/AKATVCoordinateMappingProtocol.h>
#import <AKABeacon/AKATVDataSourceSpecification.h>
#import <AKABeacon/AKATVMultiplexedDataSource.h>
#import <AKABeacon/AKATVProxy.h>
#import <AKABeacon/AKATVRowSegment.h>
#import <AKABeacon/AKATVSection.h>
#import <AKABeacon/AKATVUpdateBatch.h>
#import <AKABeacon/NSIndexPath+AKARowAndSectionAsInteger.h>
#import <AKABeacon/NSMutableString+AKATools.h>
#import <AKABeacon/NSObject+AKAAssociatedValues.h>
#import <AKABeacon/NSObject+AKAConcurrencyTools.h>
#import <AKABeacon/NSObject+AKASelectorTools.h>
#import <AKABeacon/NSString+AKAKeyPathUtilities.h>
#import <AKABeacon/NSString+AKATools.h>
#import <AKABeacon/UIView+AKAConstraintTools.h>
#import <AKABeacon/UIView+AKAHierarchyVisitor.h>
#import <AKABeacon/UIView+AKAReusableViewsSupport.h>

// Behaviors
#import <AKABeacon/AKABindingBehavior.h>
#import <AKABeacon/AKAControlBindingBehavior.h>  // Obsolete (support AKAFormTableViewController)

// ViewControllers
#import <AKABeacon/AKAFormViewController.h>
#import <AKABeacon/AKAFormTableViewController.h> // Obsolete

#import <AKABeacon/UIViewController+AKAIBBindingProperties.h>

// Integration

// Integration/AKABindingTargetContainer
#import <AKABeacon/AKABindingTargetContainerProtocol.h>
#import <AKABeacon/UITableView+AKABindingTargetContainer.h>
#import <AKABeacon/UITableViewCell+AKABindingTargetContainer.h>
#import <AKABeacon/UIToolbar+AKABindingTargetContainer.h>
#import <AKABeacon/UIView+AKABindingTargetContainer.h>
#import <AKABeacon/UIViewController+AKABindingTargetContainer.h>

// Integration/AKAIBBindingProperties

// Integration/AKAIBBindingProperties/datasourceBinding
#import <AKABeacon/UITableView+AKAIBBindingProperties_datasourceBinding.h>

// Integration/AKAIBBindingProperties/enabledBinding
#import <AKABeacon/UIControl+AKAIBBindingProperties_enabledBinding.h>
#import <AKABeacon/UIBarButtonItem+AKAIBBindingProperties_enabledBinding.h>

// Integration/AKAIBBindingProperties/fontBinding
#import <AKABeacon/UILabel+AKAIBBindingProperties_fontBinding.h>
#import <AKABeacon/UITextField+AKAIBBindingProperties_fontBinding.h>
#import <AKABeacon/UITextView+AKAIBBindingProperties_fontBinding.h>

// Integration/AKAIBBindingProperties/gesturesBinding
#import <AKABeacon/UIView+AKAIBBindingProperties_gesturesBinding.h>

// Integration/AKAIBBindingProperties/imageBinding
#import <AKABeacon/UIImageView+AKAIBBindingProperties_imageBinding.h>

// Integration/AKAIBBindingProperties/stateBinding
#import <AKABeacon/UISwitch+AKAIBBindingProperties_stateBinding.h>

// Integration/AKAIBBindingProperties/styleBinding
#import <AKABeacon/UIView+AKAIBBindingProperties_styleBinding.h>
#import <AKABeacon/UILabel+AKAIBBindingProperties_styleBinding.h>

// Integration/AKAIBBindingProperties/textBinding
#import <AKABeacon/UILabel+AKAIBBindingProperties_textBinding.h>
#import <AKABeacon/UITextField+AKAIBBindingProperties_textBinding.h>
#import <AKABeacon/UITextView+AKAIBBindingProperties_textBinding.h>

// Integration/AKAIBBindingProperties/valueBinding
#import <AKABeacon/UIPickerView+AKAIBBindingProperties_valueBinding.h>
#import <AKABeacon/UISegmentedControl+IBBindingProperties_valueBinding.h>
#import <AKABeacon/UISlider+AKAIBBindingProperties_valueBinding.h>
#import <AKABeacon/UIStepper+AKAIBBindingProperties_valueBinding.h>

// BindingController
#import <AKABeacon/AKABindingController.h>
#import <AKABeacon/AKABindingControllerDelegate.h>
#import <AKABeacon/AKABindingController+BindingInitialization.h>
#import <AKABeacon/AKABindingController+ChildBindingControllers.h>
#import <AKABeacon/AKABindingController+BindingDelegatePropagation.h>
#import <AKABeacon/AKABindingController+BindingContextProtocol.h>
#import <AKABeacon/AKABindingController+KeyboardActivationSequence.h>

// Bindings
#import <AKABeacon/AKABindingExpression+Accessors.h>
#import <AKABeacon/AKABindingErrors.h>
#import <AKABeacon/AKABindingExpressionEvaluator.h>
#import <AKABeacon/AKABindingDelegate.h>
#import <AKABeacon/AKABindingOwnerProtocol.h>
#import <AKABeacon/AKABindingDelegateDispatcher.h>
#import <AKABeacon/AKABinding_Protected.h>
#import <AKABeacon/AKABinding+SubclassInitialization.h>
#import <AKABeacon/AKABinding+SubclassObservationEvents.h>
#import <AKABeacon/AKABinding+BindingOwner.h>
#import <AKABeacon/AKABinding+DelegateSupport.h>
#import <AKABeacon/AKABinding+IBPropertySupport.h>

#import <AKABeacon/AKAConditionalBinding.h>
#import <AKABeacon/AKABindingContextProtocol.h>
#import <AKABeacon/AKAChildBindingContext.h>

// Bindings/ViewBindings
#import <AKABeacon/AKAViewBinding.h>

#import <AKABeacon/AKAFontPropertyBinding.h>

// Bindings/ViewBindings/UIView
#import <AKABeacon/AKABinding_UIView_styleBinding.h>
#import <AKABeacon/AKABinding_UIView_gesturesBinding.h>

// Bindings/ViewBindings/UIControl
#import <AKABeacon/AKABinding_UIControl_enabledBinding.h>

// Bindings/ViewBindings/UILabel
#import <AKABeacon/AKABinding_UILabel_textBinding.h>
#import <AKABeacon/AKABinding_UILabel_styleBinding.h>

// Bindings/ViewBindings/UIImageView
#import <AKABeacon/AKABinding_UIImageView_imageBinding.h>

// Bindings/ViewBindings/UITableView
#import <AKABeacon/AKABinding_UITableView_dataSourceBinding.h>
#import <AKABeacon/AKATableViewCellFactory.h>
#import <AKABeacon/AKATableViewCellFactoryArrayPropertyBinding.h>
#import <AKABeacon/AKATableViewCellFactoryPropertyBinding.h>

// Bindings/ViewBindings/ControlViewBindings
#import <AKABeacon/AKAControlViewBinding.h>
#import <AKABeacon/AKAControlViewBindingDelegate.h>

// Bindings/ViewBindings/ControlViewBindings/UISegmentedControl
#import <AKABeacon/AKABinding_UISegmentedControl_valueBinding.h>

// Bindings/ViewBindings/ControlViewBindings/UISwitch
#import <AKABeacon/AKABinding_UISwitch_stateBinding.h>

// Bindings/ViewBindings/ControlViewBindings/UISlider
#import <AKABeacon/AKABinding_UISlider_valueBinding.h>

// Bindings/ViewBindings/ControlViewBindings/UIStepper
#import <AKABeacon/AKABinding_UIStepper_valueBinding.h>

// Bindings/ViewBindings/ControlViewBindings/UIPickerView
#import <AKABeacon/AKABinding_UIPickerView_valueBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings
#import <AKABeacon/AKAKeyboardControlViewBinding.h>
#import <AKABeacon/AKAKeyboardControlViewBindingDelegate.h>
#import <AKABeacon/AKAKeyboardControlViewBinding+DelegateSupport.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/UITextField
#import <AKABeacon/AKABinding_UITextField_textBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/UITextView
#import <AKABeacon/AKABinding_UITextView_textBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/CustomKeyboard
#import <AKABeacon/AKACustomKeyboardResponderView.h>
#import <AKABeacon/AKAKeyboardBinding_AKACustomKeyboardResponderView.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/CustomKeyboard/AKAPickerKeyboard
#import <AKABeacon/AKAPickerKeyboardTriggerView.h>
#import <AKABeacon/AKABinding_AKAPickerKeyboardTriggerView_pickerBinding.h>

// Bindings/ViewBindings/ControlViewBindings/KeyboardControlViewBindings/CustomKeyboard/AKADatePickerKeyboard
#import <AKABeacon/AKADatePickerKeyboardTriggerView.h>
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

// Bindings/PropertyBindings/Arrays
#import <AKABeacon/AKAArrayPropertyBinding.h>

// Bindings/PropertyBindings/Predicates
#import <AKABeacon/AKAPredicatePropertyBinding.h>

// Bindings/PropertyBindings/Formatters
#import <AKABeacon/AKAFormatterPropertyBinding.h>
#import <AKABeacon/AKANumberFormatterPropertyBinding.h>
#import <AKABeacon/AKADateFormatterPropertyBinding.h>
#import <AKABeacon/AKALocalePropertyBinding.h>
#import <AKABeacon/AKACalendarPropertyBinding.h>
#import <AKABeacon/AKATimeZonePropertyBinding.h>
#import <AKABeacon/AKAAttributedFormatterPropertyBinding.h>
#import <AKABeacon/AKAAttributedFormatter.h>

// Bindings/PropertyBindings/GestureRecognizers
#import <AKABeacon/AKATapGestureRecognizerBinding.h>

// Bindings/PropertyBindings/Animations
#import <AKABeacon/AKATransitionAnimationParameters.h>
#import <AKABeacon/AKATransitionAnimationParametersPropertyBinding.h>


#import <AKABeacon/AKATableViewDataSourcePropertyBinding.h>

// Bindings/Expressions
#import <AKABeacon/AKABindingSpecification.h>
#import <AKABeacon/AKABindingExpressionParser.h>
#import <AKABeacon/AKABindingExpression.h>

// Bindings/Expressions/Concrete Binding Expressions

// Bindings/Expressions/Concrete Binding Expressions/Control Structures

#import <AKABeacon/AKAControlStructureBindingExpression.h>
#import <AKABeacon/AKAConditionalBindingExpression.h>

// Bindings/Expressions/Concrete Binding Expressions/Key Paths

#import <AKABeacon/AKAKeyPathBindingExpression.h>

// Bindings/Expressions/Concrete Binding Expressions/Constants

#import <AKABeacon/AKAConstantBindingExpression.h>
#import <AKABeacon/AKAArrayBindingExpression.h>
#import <AKABeacon/AKAConstantBindingExpression_Protected.h>
#import <AKABeacon/AKAStringConstantBindingExpression.h>
#import <AKABeacon/AKAEnumConstantBindingExpression.h>
#import <AKABeacon/AKAOptionsConstantBindingExpression.h>
#import <AKABeacon/AKANumberConstantBindingExpression.h>
#import <AKABeacon/AKABooleanConstantBindingExpression.h>
#import <AKABeacon/AKAIntegerConstantBindingExpression.h>
#import <AKABeacon/AKADoubleConstantBindingExpression.h>
#import <AKABeacon/AKAClassConstantBindingExpression.h>
//#import <AKABeacon/AKAObjectConstantBindingExpression.h> (not yet)
#import <AKABeacon/AKAColorConstantBindingExpression.h>
#import <AKABeacon/AKAUIFontConstantBindingExpression.h>
#import <AKABeacon/AKAStructConstantBindingExpression.h>
#import <AKABeacon/AKACGPointConstantBindingExpression.h>
#import <AKABeacon/AKACGSizeConstantBindingExpression.h>
#import <AKABeacon/AKACGRectConstantBindingExpression.h>


// KeyboardActivationSequence
#import <AKABeacon/AKAKeyboardActivationSequence.h>
#import <AKABeacon/AKAKeyboardActivationSequenceItemProtocol.h>
#import <AKABeacon/AKAKeyboardActivationSequenceAccessoryView.h>

//// Soon Obsolete:

// Controls
#import <AKABeacon/AKAControlValidationState.h>
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
#import <AKABeacon/AKATableViewCompositeControl.h>
#import <AKABeacon/AKATableViewCellCompositeControl.h>
#import <AKABeacon/AKADynamicPlaceholderTableViewCellCompositeControl.h>
#import <AKABeacon/AKAFormControl.h>
#import <AKABeacon/AKAFormControl+BindingDelegatePropagation.h>

#import <AKABeacon/AKAControlViewProtocol.h>
#import <AKABeacon/AKAControlValidatorProtocol.h>
#import <AKABeacon/AKAControlConverterProtocol.h>

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
