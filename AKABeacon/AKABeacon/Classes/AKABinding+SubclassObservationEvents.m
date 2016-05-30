//
//  AKABinding+SubclassObservationEvents.m
//  AKABeacon
//
//  Created by Michael Utech on 29.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding+SubclassObservationEvents.h"

@implementation AKABinding (SubclassObservationEvents)

#pragma mark - Observation Start

- (void)willStartObservingChanges {}

- (void)didStartObservingChanges {}

- (void)willStartObservingBindingPropertyBindings {}

- (void)didStartObservingBindingPropertyBindings {}

- (void)willStartObservingBindingTarget {}

- (void)didStartObservingBindingTarget {}

- (void)willStartObservingBindingSource {}

- (void)didStartObservingBindingSource {}

- (void)willInitializeTargetValueForObservationStart {}

- (void)didInitializeTargetValueForObservationStart {}

- (void)willStartObservingBindingTargetPropertyBindings {}

- (void)didStartObservingBindingTargetPropertyBindings {}

#pragma mark - Observation Stop

- (void)willSopObservingChanges {}

- (void)didStopObservingChanges {}

- (void)willStopObservingBindingPropertyBindings {}

- (void)didStopObservingBindingPropertyBindings {}

- (void)willStopObservingBindingTarget {}

- (void)didStopObservingBindingTarget {}

- (void)willStopObservingBindingSource {}

- (void)didStopObservingBindingSource {}

- (void)willStopObservingBindingTargetPropertyBindings {}

- (void)didStopObservingBindingTargetPropertyBindings {}


@end
