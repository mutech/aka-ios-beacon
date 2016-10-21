//
//  AKAOperation.h
//  AKABeacon
//
//  Created by Michael Utech on 06.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

#import "AKANullability.h"
#import "AKAOperationObserver.h"
#import "AKAOperationCondition.h"

// This is yet another rewrite of Operation from the 2015 WWDC session about advanced operations.
// We chose to re-reinvent it so that we won't add a dependency to AKABeacon.

/**
 This is yet another rewrite of the Advanced Operations sample (2015 WWDC).
 
 We choose to do our own because we didn't want to add a dependency which might conflict with App dependencies and rather implement the subset of that we needed.
 
 There are some differences in our implementation:

 - We do not override NSOperationQueue and instead require operations to be added via addToOperationQueue.

 - We use our framework prefix for not to conflict with others.

 - We fixed some bugs and certainly introduced some new.

 */
@interface AKAOperation : NSOperation

#pragma mark - Initialization

+ (nonnull AKAOperation*)operationWithBlock:(void(^_Nonnull)(void(^_Nonnull finish)()))block;

+ (nonnull AKAOperation*)operationFailingWithError:(nonnull NSError*)error;

#pragma mark - Conditions

- (void)                               addCondition:(AKAOperationCondition*_Nonnull)condition;

- (void)              enumerateConditionsUsingBlock:(void(^_Nonnull)(AKAOperationCondition*_Nonnull condition,
                                                                     outreq_BOOL stop))block;

#pragma mark - Final State

/**
 Determines whether the execution of the operation finished with errors.

 This is equivalent to @code (op.isFinished && op.errors.count) > 0 @endcode
 */
@property (nonatomic, readonly) BOOL failed;

@property (nullable, nonatomic, readonly) NSArray<NSError*>* errors;

#pragma mark - Observers

- (void)                                addObserver:(nonnull id<AKAOperationObserver>)observer;

- (void)               addObserverWithDidStartBlock:(void (^_Nullable)(AKAOperation*_Nonnull op))didStartBlock
                           didProduceOperationBlock:(void (^_Nullable)(AKAOperation*_Nonnull op,
                                                                      NSOperation*_Nonnull producedOp))didProduceOperationBlock
                                     didFinishBlock:(void (^_Nullable)(AKAOperation*_Nonnull op,
                                                                      NSArray<NSError*>*_Nullable errors))didFinishBlock;

- (void)               addDidStartObserverWithBlock:(void(^_Nonnull)(AKAOperation*_Nonnull operation))block;

- (void)    addDidProduceOperationObserverWithBlock:(void(^_Nonnull)(AKAOperation*_Nonnull operation,
                                                                     NSOperation*_Nonnull producedOperation))block;

- (void)              addDidFinishObserverWithBlock:(void(^_Nonnull)(AKAOperation*_Nonnull operation,
                                                                     NSArray<NSError*>*_Nullable errors))block;

#pragma mark - Dependencies

- (void)                              addDependency:(nonnull NSOperation*)operation;

#pragma mark - Producing Operations

- (void)                           produceOperation:(nonnull NSOperation*)operation;

#pragma mark - Execution

- (void)                                      start NS_REQUIRES_SUPER;

- (void)                                       main NS_REQUIRES_SUPER;

/**
 Called before execution will begin (and also before operation observers will be notified).
 */
- (void)                                willExecute;

/**
 Called by main. This has to be overridden by subclasses to implement the operation
 */
- (void)                                    execute;

#pragma mark - Cancellation

- (void)                            cancelWithError:(nullable NSError*)error;

- (void)                           cancelWithErrors:(nullable NSArray<NSError*>*)errors;

#pragma mark - Finishing

/**
 * This is true while the operation notified observers that the operation did finish. Not that isFinished will be true after the observers are notified and before didFinish is called.
 */
@property(nonatomic, readonly) BOOL                isFinishing;

- (void)                                 willFinish;

- (void)                                     finish __attribute__((objc_requires_super));

- (void)                            finishWithError:(nullable NSError*)error __attribute__((objc_requires_super));

- (void)                           finishWithErrors:(nullable NSArray<NSError*>*)errors __attribute__((objc_requires_super));

#pragma mark - Operation Queues

+ (void)                               addOperation:(nonnull NSOperation*)operation
                                   toOperationQueue:(nonnull NSOperationQueue*)operationQueue;

- (void)                        addToOperationQueue:(nonnull NSOperationQueue*)queue;

@end


@interface AKAOperation(Subclasses)

#pragma mark - Collection errors

- (void)addError:(nonnull NSError*)error;

- (void)addErrors:(nullable NSArray<NSError*>*)errors;

@end
