//
//  AKAEditorControlView.h
//  AKACommons
//
//  Created by Michael Utech on 15.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface AKAEditorControlView : UIView

#pragma mark - Interface Builder Properties

@property(nonatomic, weak) IBInspectable NSString* layoutIdentifier;

@property(nonatomic) IBInspectable NSString* labelText;
@property(nonatomic) IBInspectable UIColor* labelTextColor;
@property(nonatomic) IBInspectable UIFont* labelFont;

@property(nonatomic) IBInspectable NSString* errorText;
@property(nonatomic) IBInspectable UIColor* errorTextColor;
@property(nonatomic) IBInspectable UIFont* errorFont;

#pragma mark - Outlets

@property(nonatomic, weak) IBOutlet UILabel* label;
@property(nonatomic, weak) IBOutlet UIView* editor;
@property(nonatomic, weak) IBOutlet UILabel* errorMessageLabel;

- (BOOL)validateLabel:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)error;
- (BOOL)validateEditor:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)error;
- (BOOL)validateErrorMessageLabel:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)error;

@end
