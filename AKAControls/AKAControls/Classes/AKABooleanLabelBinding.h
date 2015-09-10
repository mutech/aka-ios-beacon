//
//  AKABooleanLabelBinding.h
//  AKAControls
//
//  Created by Michael Utech on 09.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATextLabelBinding.h"

@interface AKABooleanLabelBindingConfiguration : AKATextLabelBindingConfiguration

@property(nonatomic) NSString* textForYes;
@property(nonatomic) NSString* textForNo;
@property(nonatomic) NSString* textForUndefined;

@end

@interface AKABooleanLabelBinding : AKATextLabelBinding

@property(nonatomic, readonly)AKABooleanLabelBindingConfiguration* configuration;

@end
