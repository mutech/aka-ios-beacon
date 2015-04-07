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

#import <AKAControls/AKAControl.h>
#import <AKAControls/AKAControl_Protected.h>
#import <AKAControls/AKAControlDelegate.h>
#import <AKAControls/AKACompositeControl.h>
#import <AKAControls/AKAControlViewProtocol.h>
#import <AKAControls/AKAViewBinding.h>
#import <AKAControls/AKAViewBindingConfiguration.h>
#import <AKAControls/AKACompositeViewBindingConfiguration.h>
#import <AKAControls/UIView+AKABinding.h>
#import <AKAControls/AKAControlValidatorProtocol.h>
#import <AKAControls/AKAControlConverterProtocol.h>

// AKAControls/ControlViews

// AKAControls/ControlViews/ScalarControlViews
#import <AKAControls/AKALabel.h>
#import <AKAControls/AKALabelBinding.h>
#import <AKAControls/AKATextField.h>
#import <AKAControls/AKATextFieldBinding.h>
#import <AKAControls/AKASwitch.h>
#import <AKAControls/AKASwitchBinding.h>

// AKAControls/ControlViews/CompositeControlViews
#import <AKAControls/AKAEditorControlView.h>
#import <AKAControls/AKAEditorControlView_Protected.h>
#import <AKAControls/AKATextEditorControlView.h>
#import <AKAControls/AKAPasswordEditorControlView.h>
#import <AKAControls/AKASwitchEditorControlView.h>

// AKAControls/Themes
#import <AKAControls/AKAThemeProviderProtocol.h>
#import <AKAControls/UIView+AKAThemeProvider.h>
#import <AKAControls/AKATheme.h>
#import <AKAControls/AKAThemeViewApplicability.h>
#import <AKAControls/AKAViewCustomization.h>
#import <AKAControls/AKAThemeLayout.h>
#import <AKAControls/AKALayoutConstraintSpecification.h>
#import <AKAControls/AKAThemableContainerView.h>
#import <AKAControls/AKASubviewsSpecification.h>
