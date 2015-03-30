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
#import "AKAThemableContainerView_Protected.h"

IB_DESIGNABLE
@interface AKAEditorControlView : AKAThemableContainerView<
    AKAControlViewProtocol,
    AKAEditorControlViewBindingConfigurationProtocol>

#pragma mark - Interface Builder and Binding Configuration Properties

@property(nonatomic) IBInspectable NSString* controlName;
@property(nonatomic) IBInspectable NSString* role;
@property(nonatomic) IBInspectable NSString* valueKeyPath; // TODO: rename to binding?

@property(nonatomic) IBInspectable NSString* editorBinding;
@property(nonatomic) IBInspectable NSString* labelText;

#pragma mark - Outlets

@property(nonatomic, weak) IBOutlet UILabel* label;
@property(nonatomic, weak) IBOutlet UIView* editor;
@property(nonatomic, weak) IBOutlet UILabel* messageLabel;

@end
