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

/**
 * Initializes a new unbound control with the specified owner control.
 * The data context (model value) of the new control is derived from the owners data
 * context by querying the value at the specified @c keyPath.
 *
 * @note The initializer should only be used by inheriting classes. Please use the public factory methods +controlWithOwner: or +controlWithOwner:keyPath: instead.
 *
 * @param owner the composite control owning the new control (not nil).
 * @param keyPath a valid key path used to derive the controls data context from that of the owner.
 *
 * @return the new control.
 */
- (instancetype)initWithOwner:(AKACompositeControl*)owner
                      keyPath:(NSString*)keyPath;

/**
 * Initializes a new toplevel control using the specified data context
 * queried with the specified key path.
 *
 * @note The initializer should only be used by inheriting classes. Please use the public factory methods +controlWithDataContext: or +controlWithDataContext:keyPath: instead.
 *
 * @param dataContext the data context providing the model value at the specified @c keyPath
 * @param keyPath a valid key path
 *
 * @return the new control
 */
- (instancetype)initWithDataContext:(id)dataContext
                            keyPath:(NSString*)keyPath;

#pragma mark - View Binding

/**
 * The binding connecting this control to its view.
 *
 * @note This property should only be used by inheriting classes. Use the methods provided by AKAControl and its subclasses instead of calling binding methods directly. Please file a bug report if functionality is missing.
 *
 */
@property(nonatomic, strong, readonly) AKAViewBinding* viewBinding;

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
