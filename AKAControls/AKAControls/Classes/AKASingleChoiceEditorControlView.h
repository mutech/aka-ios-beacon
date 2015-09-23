//
//  AKASingleChoiceEditorControlView.h
//  AKAControls
//
//  Created by Michael Utech on 14.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAEditorControlView.h"

IB_DESIGNABLE
@interface AKASingleChoiceEditorControlView : AKAEditorControlView

@property(nonatomic, strong) UIView* inputAccessoryView;

#pragma mark - Interface Builder Properties

@property(nonatomic, strong) IBInspectable NSString* pickerValuesKeyPath;
@property(nonatomic, strong) IBInspectable NSString* titleKeyPath;
@property(nonatomic, strong) IBInspectable NSString* titleConverterKeyPath;
@property(nonatomic, strong) IBInspectable NSString* otherValueTitle;
@property(nonatomic, strong) IBInspectable NSString* undefinedValueTitle;


/**
 * Determines whether the view should automatically activate if the owner of the
 * bound control activates.
 */
@property(nonatomic) IBInspectable BOOL autoActivate;

/**
 * Determines whether the view and thus its bound control should participate in
 * the keyboard activation sequence.
 */
@property(nonatomic) IBInspectable BOOL KBActivationSequence;

@end

@interface AKASingleChoiceEditorBinding: AKAEditorBinding
@end

@interface AKASingleChoiceEditorBindingConfiguration: AKAEditorBindingConfiguration

@property(nonatomic, strong) NSString* pickerValuesKeyPath;
@property(nonatomic, strong) NSString* titleKeyPath;
@property(nonatomic, strong) NSString* titleConverterKeyPath;
@property(nonatomic, strong) NSString* otherValueTitle;
@property(nonatomic, strong) NSString* undefinedValueTitle;


/**
 * Determines whether the view should automatically activate if the owner of the
 * bound control activates.
 */
@property(nonatomic) BOOL autoActivate;

/**
 * Determines whether the view and thus its bound control should participate in
 * the keyboard activation sequence.
 */
@property(nonatomic) BOOL KBActivationSequence;

@end