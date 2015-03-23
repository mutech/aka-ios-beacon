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

// AKAControls/Controls
#import <AKAControls/AKAControl.h>
#import <AKAControls/AKAControl_Protected.h>
#import <AKAControls/AKAControlDelegate.h>
#import <AKAControls/AKACompositeControl.h>
#import <AKAControls/AKAControlValidatorProtocol.h>
#import <AKAControls/AKAControlConverterProtocol.h>

// AKAControls/ControlViews
#import <AKAControls/AKAControlViewProtocol.h>
#import <AKAControls/AKAControlViewDelegate.h>

// AKAControls/ControlViews/ScalarControlViews
#import <AKAControls/AKATextField.h>
#import <AKAControls/AKALabel.h>
#import <AKAControls/AKASwitch.h>

// AKAControls/ControlViews/CompositeControlViews
#import <AKAControls/AKAEditorControlView.h>

// AKAControls/ControlViewBindings
#import <AKAControls/AKAControlViewBinding.h>
#import <AKAControls/AKAControlViewBinding_Protected.h>
#import <AKAControls/AKAControlViewBindingConfigurationProtocol.h>
#import <AKAControls/AKATextFieldControlViewBinding.h>
#import <AKAControls/AKAEditorControlViewBindingConfigurationProtocol.h>

// AKAControls/Properties
#import <AKAControls/AKAProperty.h>
