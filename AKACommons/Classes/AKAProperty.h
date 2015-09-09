//
//  AKAProperty.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKAUnboundProperty: NSObject

+ (AKAUnboundProperty*)unboundPropertyWithKeyPath:(NSString*)keyPath;

+ (AKAUnboundProperty*)unboundPropertyWithGetter:(id(^)(id target))getter
                                          setter:(void(^)(id target, id value))setter;

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
- (id)valueForTarget:(id)target;

/**
 * Changes the value of the property in the specified target to the specified new value.
 *
 * @param value the new value
 * @param target the target object in which to change the property.
 */
- (void)setValue:(id)value forTarget:(id)target;

@end

@interface AKAProperty: AKAUnboundProperty

#pragma mark - Initialization

+ (AKAProperty*)propertyOfWeakKeyValueTarget:(NSObject*)target
                                 keyPath:(NSString*)keyPath
                          changeObserver:(void(^)(id oldValue, id newValue))valueDidChange;

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
+ (AKAProperty*)propertyOfWeakTarget:(id)target
                            getter:(id(^)(id target))getter
                            setter:(void(^)(id target, id value))setter
                observationStarter:(BOOL(^)(id target))observationStarter
                observationStopper:(BOOL(^)(id target))observationStopper;

#pragma mark - Value Access

/**
 * The value of the property in the target bound to this instance.
 */
@property(nonatomic) id value;

/**
 * If the property is bound (has a defined target), then this function returns
 * the property value of this target. Otherwise it will return the property value
 * of the specified defaultTarget.
 *
 * @param defaultTarget The target to query for the value if this property instance is not bound.
 *
 * @return the property value of this target if bound, otherwise the property value of the default target.
 */
- (id)valueWithDefaultTarget:(id)defaultTarget;

#pragma mark - Validation

- (BOOL)    validateValue:(inout __autoreleasing id *)ioValue
                    error:(out NSError *__autoreleasing *)outError;

#pragma mark - Notifications

@property(nonatomic, readonly) BOOL isObservingChanges;

- (BOOL)startObservingChanges;

- (BOOL)stopObservingChanges;

/**
 * Notifies the property, that its value changed. This is only used for custom properties
 * (those using getters and setters) and has no effect for other property types.
 */
- (void)notifyPropertyValueDidChangeFrom:(id)oldValue to:(id)newValue;

#pragma mark - Dependent Properties

@property(nonatomic, readonly) NSSet* dependentProperties;

- (AKAProperty*)propertyAtKeyPath:(NSString*)keyPath
               withChangeObserver:(void(^)(id oldValue, id newValue))valueDidChange;

- (AKAProperty *)propertyAtIndex:(NSInteger)index
              withChangeObserver:(void (^)(id, id))valueDidChange;

- (AKAProperty*)propertyComputedBy:(id(^)(id value))computation;

@end
