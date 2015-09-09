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

#pragma mark - View Binding

/**
 * The binding connecting this control to its view.
 *
 * @note This property should only be used by inheriting classes. Use the methods provided by AKAControl and its subclasses instead of calling binding methods directly. Please file a bug report if functionality is missing.
 *
 */
@property(nonatomic, strong) AKAViewBinding* viewBinding;

#pragma mark - Value Properties

/**
 * The AKAProperty providing access to the controls data context.
 *
 * @note This property should only be used by inheriting classes. Use the modelValue property instead to access the model value.
 */
@property(nonatomic, strong, readonly) AKAProperty* dataContextProperty;

/**
 * Creates a new property instance accessing the control's data context's property at the
 * specified <keyPath>.
 *
 * @note The key path may use extensions, for example to access the root data context,
 * the key path can be prefixed with '$root'.
 *
 * @param keyPath the key path relative to the control's data context.
 * @param changeObserver the change observer for the value at the specified key path.
 *
 * @return a property providing access to the specified value.
 */
- (AKAProperty*)dataContextPropertyAtKeyPath:(NSString*)keyPath
                          withChangeObserver:(void(^)(id oldValue, id newValue))changeObserver;

/**
 * Returns the value of the control'data context for the specified key path.
 *
 * @param keyPath the key path relative to the control's data context
 *
 * @return the value for the specified key in the control's data context.
 */
- (id)dataContextValueAtKeyPath:(NSString*)keyPath;

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
