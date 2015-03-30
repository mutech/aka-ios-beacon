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

@property(nonatomic) IBInspectable NSString* editorBinding;
@property(nonatomic) IBInspectable NSString* labelText;

@end
