//
//  AKAControl_Protected.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl.h"

@interface AKAControl ()

#pragma mark - Initialization
/// @name Initialization

- (instancetype)initWithOwner:(AKACompositeControl*)owner
                configuration:(id<AKAControlConfigurationProtocol>)configuration;

- (instancetype)initWithDataContext:(id)dataContext
                      configuration:(id<AKAControlConfigurationProtocol>)configuration;

#pragma mark - Value Properties

#pragma mark - Obsolete
// TODO: remove when new binding mechanism is ready:


@end
