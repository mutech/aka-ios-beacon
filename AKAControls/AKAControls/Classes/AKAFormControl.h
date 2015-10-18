//
//  AKAFormControl.h
//  AKAControls
//
//  Created by Michael Utech on 10.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKACompositeControl.h"
#import "AKAControlConfiguration.h"
#import "AKAControlDelegate.h"

@interface AKAFormControl : AKACompositeControl

#pragma mark - Initialization

- (instancetype _Nonnull)                   initWithDataContext:(req_id)dataContext
                                                       delegate:(opt_AKAControlDelegate)delegate;

- (instancetype _Nonnull)                   initWithDataContext:(req_id)dataContext
                                                  configuration:(opt_AKAControlConfiguration)configuration
                                                       delegate:(opt_AKAControlDelegate)delegate;

#pragma mark - Configuration

@property(nonatomic, weak, readonly) id<AKAControlDelegate> delegate;

@end
