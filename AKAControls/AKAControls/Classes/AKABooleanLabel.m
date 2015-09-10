//
//  AKABooleanLabel.m
//  AKAControls
//
//  Created by Michael Utech on 09.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKABooleanLabel.h"
#import "AKABooleanLabelBinding.h"

@implementation AKABooleanLabel

#pragma mark - Interface Builder Properties

- (NSString *)textForYes { return self.bindingConfiguration.textForYes; }
- (void)setTextForYes:(NSString *)textForYes { self.bindingConfiguration.textForYes = textForYes; }

- (NSString *)textForNo { return self.bindingConfiguration.textForNo; }
- (void)setTextForNo:(NSString *)textForNo { self.bindingConfiguration.textForNo = textForNo; }

- (NSString *)textForUndefined { return self.bindingConfiguration.textForUndefined; }
- (void)setTextForUndefined:(NSString *)textForUndefined { self.bindingConfiguration.textForUndefined = textForUndefined; }

#pragma mark - Configuration

- (AKABooleanLabelBindingConfiguration*)bindingConfiguration
{
    return (AKABooleanLabelBindingConfiguration*)super.bindingConfiguration;
}

- (AKABooleanLabelBindingConfiguration*)createBindingConfiguration
{
    return AKABooleanLabelBindingConfiguration.new;
}

@end
