//
//  AKAProperty.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKANullability.h"

@class AKAProperty;
@class AKAUnboundProperty;

#ifndef opt_AKAUnboundProperty
#define opt_AKAUnboundProperty AKAUnboundProperty* _Nullable
#endif
#ifndef req_AKAUnboundProperty
#define req_AKAUnboundProperty AKAUnboundProperty* _Nonnull
#endif
#ifndef opt_AKAProperty
#define opt_AKAProperty AKAProperty* _Nullable
#endif
#ifndef req_AKAProperty
#define req_AKAProperty AKAProperty* _Nonnull
#endif

typedef void(^AKAPropertySetter)(req_id target, opt_id value);
#ifndef opt_AKAPropertySetter
#define opt_AKAPropertySetter AKAPropertySetter _Nullable
#endif
#ifndef req_AKAPropertySetter
#define req_AKAPropertySetter AKAPropertySetter _Nonnull
#endif

typedef opt_id(^AKAPropertyGetter)(req_id target);
#ifndef opt_AKAPropertyGetter
#define opt_AKAPropertyGetter AKAPropertyGetter _Nullable
#endif
#ifndef req_AKAPropertyGetter
#define req_AKAPropertyGetter AKAPropertyGetter _Nonnull
#endif

typedef void(^AKAPropertyChangeObserver)(opt_id oldValue, opt_id newValue);
#ifndef opt_AKAPropertyChangeObserver
#define opt_AKAPropertyChangeObserver AKAPropertyChangeObserver _Nullable
#endif
#ifndef req_AKAPropertyChangeObserver
#define req_AKAPropertyChangeObserver AKAPropertyChangeObserver _Nonnull
#endif

typedef BOOL(^AKAPropertyObservationStarter)(req_id target);
#ifndef opt_AKAPropertyObservationStarter
#define opt_AKAPropertyObservationStarter AKAPropertyObservationStarter _Nullable
#endif

typedef BOOL(^AKAPropertyObservationStopper)(req_id target);
#ifndef opt_AKAPropertyObservationStopper
#define opt_AKAPropertyObservationStopper AKAPropertyObservationStopper _Nullable
#endif

typedef opt_id(^AKAPropertyComputation)(opt_id value);
#ifndef req_AKAPropertyComputation
#define req_AKAPropertyComputation AKAPropertyComputation _Nonnull
#endif


#pragma mark - AKAUnboundProperty
#pragma mark -

/**
 A property that defines access methods for its value relative to some target object, but
 does not reference the target itself.
 */
@interface AKAUnboundProperty: NSObject

#pragma mark - Initialization

+ (req_AKAUnboundProperty)  unboundPropertyWithKeyPath:(req_NSString)keyPath;

+ (req_AKAUnboundProperty)   unboundPropertyWithGetter:(opt_AKAPropertyGetter)getter
                                                setter:(opt_AKAPropertySetter)setter;

#pragma mark - Value Access

/**
 * Returns the value of the property in the specified target. This can also be used
 * in bound properties to query the property value of an object different from the
 * bound target.
 *
 * @param target the object to query for the property value.
 *
 * @return the value of the property in the specified target.
 */
- (opt_id)                              valueForTarget:(req_id)target;

/**
 * Changes the value of the property in the specified target to the specified new value.
 *
 * @param value the new value
 * @param target the target object in which to change the property.
 */
- (void)                                      setValue:(opt_id)value
                                             forTarget:(req_id)target;

@end


#pragma mark - AKAProperty
#pragma mark -

@interface AKAProperty: AKAUnboundProperty

#pragma mark - Initialization

+ (req_AKAProperty)       propertyOfWeakKeyValueTarget:(opt_NSObject)target
                                               keyPath:(opt_NSString)keyPath
                                        changeObserver:(opt_AKAPropertyChangeObserver)valueDidChange;

/**
 * Creates a new custom property with the specified block implementations.
 *
 * Please note that the observationStarter is responsible to call
 * notifiyPropertyValueDidChangeFrom:to: (required for dependent properties) and to notify
 * interested parties about changes. This is a bit clumsy, but we didn't find a
 * safer and more elegant interface for custom properties.
 *
 * @param getter a block returning the value of the property
 * @param setter a block changing the value of the property
 * @param observationStarter block starting the observation of changes.
 * @param observationStopper block stopping the observation of changes.
 *
 * @return a new property.
 */
+ (req_AKAProperty)               propertyOfWeakTarget:(opt_id)target
                                                getter:(opt_AKAPropertyGetter)getter
                                                setter:(opt_AKAPropertySetter)setter
                                    observationStarter:(opt_AKAPropertyObservationStarter)observationStarter
                                    observationStopper:(opt_AKAPropertyObservationStopper)observationStopper;

#pragma mark - Value Access

/**
 * The value of the property in the target bound to this instance.
 */
@property(nonatomic) opt_id value;

/**
 * If the property is bound (has a defined target), then this function returns
 * the property value of this target. Otherwise it will return the property value
 * of the specified defaultTarget.
 *
 * @param defaultTarget The target to query for the value if this property instance is not bound.
 *
 * @return the property value of this target if bound, otherwise the property value of the default target.
 */
- (opt_id)                      valueWithDefaultTarget:(req_id)defaultTarget;

- (opt_id)                           targetValueForKey:(req_NSString)key;

- (opt_id)                       targetValueForKeyPath:(req_NSString)keyPath;

#pragma mark - Validation

- (BOOL)                                 validateValue:(inout_id)ioValue
                                                 error:(out_NSError)outError;

#pragma mark - Notifications

@property(nonatomic, readonly) BOOL                    isObservingChanges;

- (BOOL)                         startObservingChanges;

- (BOOL)                          stopObservingChanges;

/**
 * Notifies the property, that its value changed. This is only used for custom properties
 * (those using getters and setters) and has no effect for KVO property types.
 */
- (void)              notifyPropertyValueDidChangeFrom:(opt_id)oldValue
                                                    to:(opt_id)newValue;

#pragma mark - Dependent Properties

@property(nonatomic, readonly, nullable) NSSet* dependentProperties;

- (req_AKAProperty)                  propertyAtKeyPath:(req_NSString)keyPath
                                    withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange;

- (req_AKAProperty)                    propertyAtIndex:(NSInteger)index
                                    withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange;

- (req_AKAProperty)                 propertyWithGetter:(opt_id(^_Nonnull)(req_id target))getter
                                                setter:(void(^_Nonnull)(opt_id target, opt_id value))setter
                                    observationStarter:(BOOL(^_Nonnull)(opt_id target))observationStarter
                                    observationStopper:(BOOL(^_Nonnull)(opt_id target))observationStopper;

@end


#pragma mark - AKAIndexedProperty
#pragma mark -

@interface AKAIndexedProperty: AKAProperty

#pragma mark - Initialization

+ (req_AKAProperty)       propertyOfWeakIndexedTarget:(opt_NSObject)target
                                                index:(NSInteger)index
                                       changeObserver:(void(^_Nullable)(opt_id oldValue, opt_id newValue))valueDidChange;

#pragma mark - Configuration

/**
 The index of the item referenced by this property.
 
 It's possible to change the index to support reordering of items and adaptation of properties
 to account for relocations. Please note that no change notifications are send as result of an
 index change. It's up to the caller to notify observers using propertyValueDidChangeFrom:to: if
 the index change results in a changed value.
 */
@property(nonatomic) NSInteger index;

@end
