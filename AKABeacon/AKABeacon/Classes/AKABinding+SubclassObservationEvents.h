//
//  AKABinding+SubclassObservationEvents.h
//  AKABeacon
//
//  Created by Michael Utech on 29.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"

@interface AKABinding (SubclassObservationEvents)

// These methods are entry points that sub classes can override to perform additional actions during
// the observation start process. When overriding these methods, you should always call the corresponding
// super implementation.

#pragma mark - Observation Stop

/**
 Called before the binding will start observing changes.
 
 Overriding methods have to call the super implementation.
 */
- (void)willStartObservingChanges;

/**
 Called before the binding's sub bindings targeting binding properties will start observing changes.

 Overriding methods have to call the super implementation.
 */
- (void)willStartObservingBindingPropertyBindings;

/**
 Called after the binding's sub bindings targeting binding properties change observation started.

 Overriding methods have to call the super implementation.
 */
- (void)didStartObservingBindingPropertyBindings;

/**
 Called before the binding's target property starts observing changes.

 Overriding methods have to call the super implementation.
 */
- (void)willStartObservingBindingTarget;

/**
 Called after the binding's target properties change observation started.

 Overriding methods have to call the super implementation.
 */
- (void)didStartObservingBindingTarget;

/**
 Called before the binding's source property starts observing changes.

 Overriding methods have to call the super implementation.
 */
- (void)willStartObservingBindingSource;

/**
 Called after the binding's source properties change observation started.

 Overriding methods have to call the super implementation.
 */
- (void)didStartObservingBindingSource;

/**
 Called before the bindings target value will be initialized as part of the observation start process.

 Overriding methods have to call the super implementation.
 */
- (void)willInitializeTargetValueForObservationStart;

/**
 Called after the bindings target value has been initialized as part of the observation start process.

 Overriding methods have to call the super implementation.
 */
- (void)didInitializeTargetValueForObservationStart;

/**
 Called before the binding's sub bindings targeting the binding target's properties start observing changes.

 Overriding methods have to call the super implementation.
 */
- (void)willStartObservingBindingTargetPropertyBindings;

/**
 Called after the binding's sub bindings targeting the binding target's properties change observation started.

 Overriding methods have to call the super implementation.
 */
- (void)didStartObservingBindingTargetPropertyBindings;

/**
 Called after the bindings change observation started.

 Overriding methods have to call the super implementation.
 */
- (void)didStartObservingChanges;

#pragma mark - Observation Stop

- (void)willSopObservingChanges;

- (void)willStopObservingBindingPropertyBindings;

- (void)didStopObservingBindingPropertyBindings;

- (void)willStopObservingBindingTarget;

- (void)didStopObservingBindingTarget;

- (void)willStopObservingBindingSource;

- (void)didStopObservingBindingSource;

- (void)willStopObservingBindingTargetPropertyBindings;

- (void)didStopObservingBindingTargetPropertyBindings;

- (void)didStopObservingChanges;

@end
