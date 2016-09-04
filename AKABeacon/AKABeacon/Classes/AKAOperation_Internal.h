//
//  AKAOperation_Internal.h
//  AKABeacon
//
//  Created by Michael Utech on 29.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperation.h"
#import "AKAOperationState.h"

@interface AKAOperation ()

/**
 Perform additional tasks when adding an AKAOperation to an operation queue.

 @param operationQueue operationQueue the queue to which this operation will be added.
 */
- (void)prepareToAddToOperationQueue:(NSOperationQueue*)operationQueue;

/**
 Evaluates the specified predicate block and if satisfied, performs the specified block.

 Both blocks are performed while the operation state is locked.

 @param block          The block to be executed if the predicate block returns YES.
 @param predicateBlock A block evaluating a predicate based on the current state

 @return The result of the predicate evaluation indicating whether the specified block has been performed.
 */
- (BOOL)                   performSynchronizedBlock:(void(^)())block
                            ifCurrentStateSatisfies:(BOOL(^)(AKAOperationState state))predicateBlock;

@end
