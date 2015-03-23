//
//  AKAEditorControlView.h
//  AKACommons
//
//  Created by Michael Utech on 15.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAControlViewProtocol.h"
#import "AKAEditorControlViewBindingConfigurationProtocol.h"

IB_DESIGNABLE
@interface AKAEditorControlView : UIView<
    AKAControlViewProtocol,
    AKAEditorControlViewBindingConfigurationProtocol>

#pragma mark - Interface Builder and Binding Configuration Properties

@property(nonatomic) IBInspectable NSString* controlName;
@property(nonatomic) IBInspectable NSString* role;
@property(nonatomic) IBInspectable NSString* valueKeyPath;

@property(nonatomic) IBInspectable NSString* layoutIdentifier;

@property(nonatomic) IBInspectable NSString* editorValueKeyPath;

@property(nonatomic) IBInspectable NSString* labelValueKeyPath;
@property(nonatomic) IBInspectable NSString* labelText;
@property(nonatomic) IBInspectable UIColor* labelTextColor;
@property(nonatomic)               UIFont* labelFont;


@property(nonatomic) IBInspectable NSString* errorText;
@property(nonatomic) IBInspectable UIColor* errorTextColor;
@property(nonatomic)               UIFont* errorFont;

#pragma mark - Outlets

@property(nonatomic, weak) IBOutlet UILabel* label;
@property(nonatomic, weak) IBOutlet UIView* editor;
@property(nonatomic, weak) IBOutlet UILabel* errorMessageLabel;

@end
