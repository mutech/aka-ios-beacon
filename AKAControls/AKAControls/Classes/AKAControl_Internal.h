//
//  AKAControl_Internal.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;

#import "AKAControl.h"
#import "AKAControlConfiguration.h"

@interface AKAControl (Internal)


#pragma mark - Initialization

- (instancetype _Nonnull)             initWithConfiguration:(opt_AKAControlConfiguration)configuration;

- (instancetype _Nonnull)                     initWithOwner:(req_AKACompositeControl)owner
                                              configuration:(opt_AKAControlConfiguration)configuration;

- (instancetype _Nonnull)               initWithDataContext:(opt_id)dataContext
                                              configuration:(opt_AKAControlConfiguration)configuration;

#pragma mark - Control Hierarchy

- (void)                                          setOwner:(opt_AKACompositeControl)owner;

- (void)                                           setView:(opt_UIView)view;

@end
