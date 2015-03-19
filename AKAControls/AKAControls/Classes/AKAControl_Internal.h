//
//  AKAControl_Internal.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl_Protected.h"

@interface AKAControl (Internal)

#pragma mark - Control Hierarchy

- (void)setOwner:(AKACompositeControl*)owner;

#pragma mark - Binding

- (void)setViewBinding:(AKAControlViewBinding *)viewBinding;

#pragma mark - Change Tracking

- (void)viewValueDidChangeFrom:(id)oldValue to:(id)newValue;

#pragma mark - Activation

// These are called by the control binding:

- (void)didActivate;

- (void)didDeactivate;

@end
