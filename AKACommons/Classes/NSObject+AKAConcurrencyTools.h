//
//  NSObject+ConcurrencyTools.h
//  proReport
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AKAConcurrencyTools)

/**
 * If called form the main thread, the block is executed right away
 * and otherwise dispatched to the main queue.
 *
 * @warning Please note that if @c waitForCompletion is set to YES and
 *      the block needs to be dispatched to the main queue, a dead lock
 *      can occur if the main thread (the block or other activities
 *      scheduled in the main queue) perform an action that requires
 *      waiting for the current (original) thread.
 *
 * @param block the block to execute.
 * @param waitForCompletion specifies whether, if the current thread is not
 *      the main thread, the block should be dispatched synchronously (@c YES)
 *      or asynchronously (@c NO).
 */
- (void)aka_performBlockInMainThreadOrQueue:(void (^)())block
                          waitForCompletion:(BOOL)waitForCompletion;
@end
