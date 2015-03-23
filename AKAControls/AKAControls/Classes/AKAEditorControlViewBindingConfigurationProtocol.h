//
//  AKAEditorControlViewBindingConfigurationProtocol.h
//  AKAControls
//
//  Created by Michael Utech on 20.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKAControlViewBindingConfigurationProtocol.h"

@protocol AKAEditorControlViewBindingConfigurationProtocol <AKAControlViewBindingConfigurationProtocol>

@property(nonatomic)/*IBInspectable*/ NSString* layoutIdentifier;

@property(nonatomic)/*IBInspectable*/ NSString* labelText;
@property(nonatomic)/*IBInspectable*/ UIColor* labelTextColor;
@property(nonatomic)                  UIFont* labelFont;

@property(nonatomic)/*IBInspectable*/ NSString* errorText;
@property(nonatomic)/*IBInspectable*/ UIColor* errorTextColor;
@property(nonatomic)                  UIFont* errorFont;

@end
