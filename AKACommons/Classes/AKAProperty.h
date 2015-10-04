//
//  AKAProperty.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKANullability.h"

@class AKAProperty;
@class AKAUnboundProperty;

typedef AKAUnboundProperty* _Nullable                   opt_AKAUnboundProperty;
typedef AKAUnboundProperty* _Nonnull                    req_AKAUnboundProperty;
typedef AKAProperty* _Nullable                          opt_AKAProperty;
typedef AKAProperty* _Nonnull                           req_AKAProperty;

typedef void(^AKAPropertySetter)(req_id target, opt_id value);
typedef AKAPropertySetter _Nullable                     opt_AKAPropertySetter;
typedef AKAPropertySetter _Nonnull                      req_AKAPropertySetter;

typedef opt_id(^AKAPropertyGetter)(req_id target);
typedef AKAPropertyGetter _Nullable                     opt_AKAPropertyGetter;
typedef AKAPropertyGetter _Nonnull                      req_AKAPropertyGetter;

typedef void(^AKAPropertyChangeObserver)(opt_id oldValue, opt_id newValue);
typedef AKAPropertyChangeObserver _Nullable             opt_AKAPropertyChangeObserver;
typedef AKAPropertyChangeObserver _Nonnull              req_AKAPropertyChangeObserver;

typedef BOOL(^AKAPropertyObservationStarter)(req_id target);
typedef AKAPropertyObservationStarter _Nullable         opt_AKAPropertyObservationStarter;

typedef BOOL(^AKAPropertyObservationStopper)(req_id target);
typedef AKAPropertyObservationStopper _Nullable         opt_AKAPropertyObservationStopper;

typedef opt_id(^AKAPropertyComputation)(opt_id value);
typedef AKAPropertyComputation _Nonnull                 req_AKAPropertyComputation;


#pragma mark - AKAUnboundProperty
#pragma mark -

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

+ (req_AKAProperty)       propertyOfWeakKeyValueTarget:(req_NSObject)target
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
+ (req_AKAProperty)               propertyOfWeakTarget:(req_id)target
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

@property(nonatomic, readonly) BOOL isObservingChanges;

- (BOOL)    startObservingChanges;

- (BOOL)    stopObservingChanges;

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

- (req_AKAProperty)                 propertyComputedBy:(req_AKAPropertyComputation)computation;

@end
