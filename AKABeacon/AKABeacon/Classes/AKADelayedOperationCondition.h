//
//  AKADelayedOperationCondition.h
//  AKABeacon
//
//  Created by Michael Utech on 25/09/2016.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperationCondition.h"


@interface AKADelayedOperationCondition: AKAOperationCondition

#pragma mark - Conveniences

/**
 Delays the execution of the specified operation by adding an instance of AKADeleayOperationCondition to the operation.

 @note the timer is activated when the condition is evaluated.

 @param operation the operation to be delayed
 @param delay     the delay in seconds.
 */
+ (void)       delayOperation:(AKAOperation *)operation
                 withDuration:(NSTimeInterval)delay;

#pragma mark - Initialization

/**
 Creates a new instance of this condition configured with the specified interval.
 
 @param delay the delay in seconds.

 @return A condition that will delay the execution of operations by the number of seconds configured in -delay.
 */
- (instancetype)initWithDelay:(NSTimeInterval)delay;

#pragma mark - Configuration

/**
 The number of seconds counted from the beginning of the condition's evaluation after which an operation using this condition can be started.
 */
@property(nonatomic, readonly) NSTimeInterval delay;

@end
