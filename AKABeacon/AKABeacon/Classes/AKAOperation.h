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

- (nonnull instancetype)initWithWorkload:(CGFloat)workload;

#pragma mark - Conditions

- (void)                               addCondition:(AKAOperationCondition*_Nonnull)condition;

- (void)              enumerateConditionsUsingBlock:(void(^_Nonnull)(AKAOperationCondition*_Nonnull condition,
                                                                     outreq_BOOL stop))block;

#pragma mark - Progress

/**
 * A number in range 0 .. 1.0 determining the progress of the operation.
 */
@property (nonatomic, readonly) CGFloat progress;

/**
 * Indicator for the amount of work to be performed by the operation. This is used by AKAGroupOperation (and possibly other parties) to estimate the contribution of an operation to the overall progress.
 *
 * The default implementation returns 1.0. Composite operations (f.e. AKAGroupOperation) are expected to add up the work loads of their constituents.
 *
 * Please note that the absolute value is by itself arbitrary, however the relative workload values of operations grouped together determines how steady the progress grows with time. Values should ideally be adjusted such that the growth is constant to provide users with a meaningful feedback when the progress is displayed (f.e. as UIProgressBar).
 */
@property (nonatomic, readonly) CGFloat workload;


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

- (void)      addDidUpdateProgressObserverWithBlock:(void(^_Nonnull)(AKAOperation*_Nonnull operation,
                                                                     CGFloat progressDifference,
                                                                     CGFloat workloadDifference))block;

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

#pragma mark - Updating progress and workload

/**
 * Calls the specified block that may update either or both of the progress and workload references (which are referring to the respective current values of progress and workload).
 *
 * The block is executed exclusively and may not directly or indirectly trigger a nested call of this method (for this operation).
 */
- (void)updateProgressAndWorkloadUsingBlock:(void(^_Nonnull)(CGFloat*_Nonnull progressReference,
                                                             CGFloat*_Nonnull workloadReference))block;
#pragma mark - Collection errors

- (void)addError:(nonnull NSError*)error;

- (void)addErrors:(nullable NSArray<NSError*>*)errors;

@end
