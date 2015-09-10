//
//  AKABooleanLabel.h
//  AKAControls
//
//  Created by Michael Utech on 09.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextLabel.h"
#import "AKABooleanLabelBinding.h"

@interface AKABooleanLabel : AKATextLabel

#pragma mark - Configuration
#pragma mark -

@property(nonatomic, readonly) AKABooleanLabelBindingConfiguration* bindingConfiguration;

#pragma mark - Interface Builder Properties
#pragma mark -

@property(nonatomic) IBInspectable NSString* textForYes;
@property(nonatomic) IBInspectable NSString* textForNo;
@property(nonatomic) IBInspectable NSString* textForUndefined;

@end
