//
//  AKAProperty.h
//  AKACommons
//
//  Created by Michael Utech on 13.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKAProperty : NSObject

#pragma mark - Initialization

+ (AKAProperty*)propertyOfKeyValueTarget:(NSObject*)target
                                 keyPath:(NSString*)keyPath
                          changeObserver:(void(^)(id oldValue, id newValue))valueDidChange;

/**
 * Creates a new custom property with the specified block implementations.
 *
 * Please note that the observationStarter is responsible of both notifying the
 * property of value changes (required for dependent properties) and to notify
 * interested parties about changes (to prevent the implementation from
 * unnecessarily having to store and retain another block)
 *
 * @param getter a block returning the value of the property
 * @param setter a block changing the value of the property
 * @param observationStarter block starting the observation of changes.
 * @param observationStopper block stopping the observation of changes.
 *
 * @return a new property.
 */
+ (AKAProperty*)propertyWithGetter:(id(^)())getter
                            setter:(void(^)(id value))setter
                observationStarter:(BOOL(^)(void(^notifyPropertyOfChange)(id oldValue, id newValue)))observationStarter
                observationStopper:(BOOL(^)())observationStopper;

#pragma mark - Value Access

@property(nonatomic) id value;

#pragma mark - Notifications

@property(nonatomic, readonly) BOOL isObservingChanges;

- (BOOL)startObservingChanges;

- (BOOL)stopObservingChanges;

#pragma mark - Dependent Properties

@property(nonatomic, readonly) NSSet* dependentProperties;

- (AKAProperty*)propertyAtKeyPath:(NSString*)keyPath
               withChangeObserver:(void(^)(id oldValue, id newValue))valueDidChange;

- (AKAProperty*)propertyComputedBy:(id(^)(id value))computation;

@end
