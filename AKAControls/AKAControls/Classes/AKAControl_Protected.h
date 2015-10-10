//
//  AKAControl_Protected.h
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl.h"

@interface AKAControl () <AKAViewBindingDelegate>

#pragma mark - Initialization
/// @name Initialization

- (instancetype)initWithOwner:(AKACompositeControl*)owner
                configuration:(id<AKAControlConfigurationProtocol>)configuration;

- (instancetype)initWithDataContext:(id)dataContext
                      configuration:(id<AKAControlConfigurationProtocol>)configuration;

#pragma mark - Value Properties

#pragma mark - Obsolete
// TODO: remove when new binding mechanism is ready:

/**
 * The binding connecting this control to its view.
 *
 * @note This property should only be used by inheriting classes. Use the methods provided by AKAControl and its subclasses instead of calling binding methods directly. Please file a bug report if functionality is missing.
 *
 */
@property(nonatomic, strong) AKAObsoleteViewBinding * viewBinding;

/**
 * The AKAProperty providing access to the controls modelValue.
 *
 * @note This property should only be used by inheriting classes. Use the modelValue property instead to access the model value.
 */
@property(nonatomic, strong, readonly) AKAProperty* modelValueProperty;

/**
 * The AKAProperty providing access to the controls viewValue.
 *
 * @note This property should only be used by inheriting classes. Use the viewValue property instead to access the model value.
 */
@property(nonatomic, readonly) AKAProperty* viewValueProperty;

@property(nonatomic, readonly) AKAProperty* converterProperty;

@property(nonatomic, readonly) AKAProperty* validatorProperty;

@end
