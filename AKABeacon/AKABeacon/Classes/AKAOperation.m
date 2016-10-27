//
//  AKAOperation.m
//  AKABeacon
//
//  Created by Michael Utech on 06.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperation.h"
#import "AKAOperationErrors.h"
#import "AKAOperationState.h"
#import "AKAOperationConditions.h"
#import "AKAOperationConditions_SubConditions.h"
#import "AKAOperationExclusivityController.h"
#import "AKAOperationQueue.h"
#import "AKABlockOperationObserver.h"
#import "AKABlockOperation.h"

@interface AKAOperation() {
    AKAOperationState _state;
}

#pragma mark - Operation State

@property(nonatomic) AKAOperationState              state;

@property(nonatomic, readonly) NSLock*              stateLock;

- (BOOL)              canTransitionFromCurrentState:(AKAOperationState)currentState
                                            toState:(AKAOperationState)state;

@property(nonatomic, getter=isUserInitiated) BOOL   userInitiated;

@property(nonatomic) NSMutableArray*                internalErrors;

@property(nonatomic) BOOL                           isFinishing;

#pragma mark - Progress

@property(nonatomic, readonly) NSLock*              progressLock;

#pragma mark - Conditions

// Note: multiple conditions are implemented using (private) AKAOperationConditions
@property(nonatomic) AKAOperationCondition*         condition;

@property(nonatomic) BOOL                           conditionsSatisfied;

#pragma mark - Observers

@property(nonatomic) NSMutableArray<id<AKAOperationObserver>>* observers;

#pragma mark - Operation Queues

@property(nonatomic, weak) NSOperationQueue*        operationQueue;

@end


@implementation AKAOperation

#pragma mark - Initialization

- (instancetype)                               init
{
    return [self initWithWorkload:1.0];
}

- (instancetype)                               initWithWorkload:(CGFloat)workload
{
    if (self = [super init])
    {
        _stateLock = [NSLock new];
        _state = AKAOperationStateInitialized;
        _internalErrors = [NSMutableArray new];
        _workload = workload;
        _progress = 0.0;
        _progressLock = [NSLock new];

        self.conditionsSatisfied = YES;
    }
    return self;
}

+ (AKAOperation*)operationWithBlock:(void(^_Nonnull)(void(^_Nonnull finish)()))block
{
    return [[AKABlockOperation alloc] initWithBlock:block];
}

+ (AKAOperation*)operationFailingWithError:(nonnull NSError*)error
{
    AKABlockOperation* result;
    __weak AKABlockOperation* weakResult = result;
    result = [self operationWithBlock:^(void (^ _Nonnull finish)()) {
        [weakResult cancelWithError:error];
        finish();
    }];
    return result;
}

#pragma mark - Diagnostics

- (NSString *)description
{
    NSString* stateText = @"unknown";
    switch (_state)
    {
        case AKAOperationStateInitialized:
            stateText = @"initialized";
            break;

        case AKAOperationStateEnqueuing:
            stateText = @"enqueuing";
            break;

        case AKAOperationStatePending:
            stateText = @"pending";
            break;

        case AKAOperationStateEvaluatingConditions:
            stateText = @"evaluating conditions";
            break;

        case AKAOperationStateReady:
            stateText = @"ready";
            break;

        case AKAOperationStateExecuting:
            stateText = @"executing";
            break;

        case AKAOperationStateFinishing:
            stateText = @"finishing";
            break;

        case AKAOperationStateFinished:
            stateText = @"finished";
            break;
    }
    return [NSString stringWithFormat:@"<%@:%p>{name = '%@'; state = %@}", self.class, self, self.name, stateText];
}

#pragma mark - Final State

- (BOOL)failed
{
    return self.isFinished && self.internalErrors.count > 0;
}

- (NSArray<NSError*>*)errors
{
    NSArray<NSError*>* result = nil;

    if (self.internalErrors.count > 0)
    {
        result = [NSArray arrayWithArray:self.internalErrors];
    }

    return result;
}

#pragma mark - Operation State

- (BOOL)              canTransitionFromCurrentState:(AKAOperationState)currentState
                                            toState:(AKAOperationState)state
{
    BOOL result = NO;

    switch (currentState)
    {
        case AKAOperationStateInitialized:
            result = state & AKAOperationStateInitializedSuccessors;
            break;

        case AKAOperationStateEnqueuing:
            result = state & AKAOperationStateEnqueuingSuccessors;
            break;

        case AKAOperationStatePending:
            result = state & AKAOperationStatePendingSuccessors;
            break;

        case AKAOperationStateEvaluatingConditions:
            result = state & AKAOperationStateEvaluatingConditionsSuccessors;
            break;

        case AKAOperationStateReady:
            result = state & AKAOperationStateReadySuccessors;
            break;

        case AKAOperationStateExecuting:
            result = state & AKAOperationStateExecutingSuccessors;
            break;

        case AKAOperationStateFinishing:
            result = state & AKAOperationStateFinishingSuccessors;
            break;

        case AKAOperationStateFinished:
            result = state & AKAOperationStateFinishedSuccessors;
            break;

        default:
            NSAssert(NO, @"Invalid unknown state %@", currentState);
            result = NO;
    }

    switch (state)
    {
        case AKAOperationStateInitialized:
        case AKAOperationStateEnqueuing:
        case AKAOperationStatePending:
        case AKAOperationStateEvaluatingConditions:
        case AKAOperationStateReady:
        case AKAOperationStateExecuting:
        case AKAOperationStateFinishing:
        case AKAOperationStateFinished:
            break;

        default:
            NSAssert(NO, @"Invalid unknown state %@", state);
            result = NO;
            break;
    }

    return result;
}

- (AKAOperationState)                         state
{
    [self.stateLock lock];
    AKAOperationState result = _state;
    [self.stateLock unlock];

    return result;
}

- (void)                                   setState:(AKAOperationState)state
{
    [self                       setState:state
                    ifPredicateSatisfied:NULL
             andPerformSynchronizedBlock:NULL];
}

- (BOOL)                                   setState:(AKAOperationState)state
                        andPerformSynchronizedBlock:(void(^)())block
{
    return [self                setState:state
                    ifPredicateSatisfied:NULL
             andPerformSynchronizedBlock:block];
}

- (BOOL)                                   setState:(AKAOperationState)state
                               ifPredicateSatisfied:(BOOL(^)(AKAOperationState state))predicateBlock
                        andPerformSynchronizedBlock:(void(^)())block
{
    BOOL result = NO;
    [self willChangeValueForKey:@"state"];

    [self.stateLock lock];
    if (predicateBlock == NULL || predicateBlock(_state))
    {
        result = YES;
        NSAssert([self canTransitionFromCurrentState:_state toState:state],
                 @"Invalid state transition from %lu to %lu",
                 (unsigned long)_state, (unsigned long)state);
        _state = state;
        if (block != NULL)
        {
            block();
        }
    }
    [self.stateLock unlock];

    [self didChangeValueForKey:@"state"];

    return result;
}

/**
 Evaluates the specified predicate block and if satisfied, performs the specified block.
 
 Both blocks are performed while the operation state is locked.

 @param block          The block to be executed if the predicate block returns YES.
 @param predicateBlock A block evaluating a predicate based on the current state

 @return The result of the predicate evaluation indicating whether the specified block has been performed.
 */
- (BOOL)                   performSynchronizedBlock:(void(^)())block
                            ifCurrentStateSatisfies:(BOOL(^)(AKAOperationState state))predicateBlock
{
    BOOL result = NO;
    [self.stateLock lock];
    if (predicateBlock == NULL || predicateBlock(_state))
    {
        block();
        result =  YES;
    }
    [self.stateLock unlock];
    return result;
}

- (BOOL)                                    isReady
{
    BOOL result;

    switch(self.state)
    {
        case AKAOperationStateInitialized:
        case AKAOperationStateEnqueuing:
            result = self.cancelled;
            break;

        case AKAOperationStatePending:
            if (self.cancelled)
            {
                result = YES;
            }
            else if ([super isReady])
            {
                result = NO;

                if (self.condition)
                {
                    __weak typeof(self) weakSelf = self;
                    [weakSelf evaluateConditionsCompletion:^(BOOL satisfied, NSError *error)
                     {
                         // This block is called when all conditions evaluated to its
                         // final state (if a condition is not yet satisfied, it will
                         // defer calling the completion block until a final result is
                         // available).
                         if (satisfied)
                         {
                             [weakSelf              setState:AKAOperationStateReady
                                        ifPredicateSatisfied:
                              ^BOOL(AKAOperationState state)
                              {
                                  return state == AKAOperationStateEvaluatingConditions;
                              }
                                andPerformSynchronizedBlock:
                              ^void()
                              {
                                  //__strong typeof(weakSelf) strongSelf = weakSelf;

                                  // If a condition is not satisfied, the operation will be
                                  // cancelled (because it will then never be satisfied).
                                  weakSelf.conditionsSatisfied = satisfied;
                              }];
                         }
                         else
                         {
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             if (error)
                             {
                                 [strongSelf cancelWithError:error];
                             }
                             else
                             {
                                 [strongSelf cancel];
                             }
                         }
                     }];
                }
                else
                {
                    [self                   setState:AKAOperationStateReady
                                ifPredicateSatisfied:^BOOL(AKAOperationState state) {
                                    // if isReady is triggered from multiple sources, it's possible
                                    // that the state has already been set to ready (and then maybe advanced)
                                    return state == AKAOperationStatePending;
                                }
                         andPerformSynchronizedBlock:NULL];
                }
            }
            else
            {
                result = NO;
            }
            break;

        case AKAOperationStateReady:
            result = [super isReady] || self.cancelled;
            break;

        default:
            result = self.state < AKAOperationStateExecuting && self.cancelled;
            break;
    }

    return result;
}

+ (NSSet *)       keyPathsForValuesAffectingIsReady
{
    static NSSet* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [NSSet setWithObjects:@"state", @"isCancelled", nil];
    });

    return result;
}

- (BOOL)                                isExecuting
{
    return self.state == AKAOperationStateExecuting;
}

+ (NSSet *)   keyPathsForValuesAffectingIsExecuting
{
    static NSSet* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [NSSet setWithObject:@"state"];
    });

    return result;
}

- (BOOL)                                 isFinished
{
    return self.state == AKAOperationStateFinished;
}

+ (NSSet *)    keyPathsForValuesAffectingIsFinished
{
    static NSSet* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [NSSet setWithObject:@"state"];
    });

    return result;
}

- (BOOL)                            isUserInitiated
{
    return self.qualityOfService == NSQualityOfServiceUserInitiated;
}

- (void)                           setUserInitiated:(BOOL)userInitiated
{
    NSAssert(self.state < AKAOperationStateExecuting,
             @"Cannot modify userInitiated after execution has begun");

    self.qualityOfService = userInitiated ? NSQualityOfServiceUserInitiated : NSQualityOfServiceDefault;
}

+ (NSSet *) keyPathsForValuesAffectingUserInitiated
{
    static NSSet* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [NSSet setWithObject:@"qualityOfService"];
    });

    return result;
}

#pragma mark - Conditions

- (void)                               addCondition:(AKAOperationCondition*)condition
{
    [self performSynchronizedBlock:
     ^{
         self.conditionsSatisfied = NO;
         if (self.condition == nil)
         {
             self.condition = condition;
         }
         else if ([self.condition isKindOfClass:[AKAOperationConditions class]])
         {
             AKAOperationConditions* conditions = (id)self.condition;
             [conditions addCondition:condition];
         }
         else
         {
             AKAOperationConditions* conditions = [AKAOperationConditions new];
             [conditions addCondition:self.condition];
             [conditions addCondition:condition];
             self.condition = conditions;
         }

         if (self->_state >= AKAOperationStatePending)
         {
             // If alread enqueued, we need to add dependencies for the condition, if it defines any.
             NSOperation* conditionDependency = [condition dependencyForOperation:self];
             if (conditionDependency)
             {
                 [self addDependency:conditionDependency];

                 NSOperationQueue* operationQueue = self.operationQueue;
                 NSAssert(operationQueue != nil, @"Inconsistency: if operation state is `AKAOperationStatePending`, an AKAOperation has to have a valid reference to an operation queue. Since it references queues weakly, it might have been released, which is an error; the calling code has to ensure that the queue is kept alive.");
                 [AKAOperation addOperation:conditionDependency toOperationQueue:operationQueue];
             }
         }
     } ifCurrentStateSatisfies:^BOOL(AKAOperationState state) {
         return state < AKAOperationStateEvaluatingConditions;
     }];
}

- (void)              enumerateConditionsUsingBlock:(void(^)(AKAOperationCondition*_Nonnull condition,
                                                             outreq_BOOL stop))block
{
    BOOL stop = NO;
    AKAOperationCondition* condition = self.condition;
    if ([condition isKindOfClass:[AKAOperationConditions class]])
    {
        [((AKAOperationConditions*)condition) enumerateConditionsUsingBlock:block];
    }
    else
    {
        block(condition, &stop);
    }
    (void)stop;
}

/**
 Evaluates conditions determining whether the operation is ready to be executed.
 
 Please note that this evaluation might be performed asynchronously in which case NO will be returned (meaning not yet ready).

 @return YES if the operation is ready to run, NO if the evaluation is performed asynchronously or if the operation is not yet ready.
 */
- (void)               evaluateConditionsCompletion:(void(^)(BOOL satisfied, NSError* error))completion
{
    [self                       setState:AKAOperationStateEvaluatingConditions
                    ifPredicateSatisfied:^BOOL(AKAOperationState state) {
                        return state != AKAOperationStateEvaluatingConditions;
                    }
             andPerformSynchronizedBlock:NULL];
    if (!self.condition)
    {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            self.state = AKAOperationStateReady;
        });
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            [self.condition evaluateForOperation:self
                                      completion:completion];
        });
    }
}

#pragma mark - Observers

- (void)               addDidStartObserverWithBlock:(void(^_Nonnull)(AKAOperation*_Nonnull operation))block
{
    [self addObserverWithDidStartBlock:block
              didProduceOperationBlock:NULL
                        didFinishBlock:NULL];
}

- (void)              addDidProduceOperationObserverWithBlock:(void(^_Nonnull)(AKAOperation*_Nonnull operation,
                                                                               NSOperation*_Nonnull producedOperation))block
{
    [self addObserverWithDidStartBlock:NULL
              didProduceOperationBlock:block
                        didFinishBlock:NULL];
}

- (void)              addDidFinishObserverWithBlock:(void(^_Nonnull)(AKAOperation*_Nonnull operation,
                                                                     NSArray<NSError*>*_Nullable errors))block
{
    [self addObserverWithDidStartBlock:NULL
              didProduceOperationBlock:NULL
                        didFinishBlock:block];
}

- (void)               addObserverWithDidStartBlock:(void (^_Nullable)(AKAOperation *))didStartBlock
                           didProduceOperationBlock:(void (^_Nullable)(AKAOperation *, NSOperation *))didProduceOperationBlock
                                     didFinishBlock:(void (^_Nullable)(AKAOperation *, NSArray<NSError *> *))didFinishBlock
{
    [self addObserverWithDidStartBlock:didStartBlock
              didProduceOperationBlock:didProduceOperationBlock
                didUpdateProgressBlock:NULL
                        didFinishBlock:didFinishBlock];
}

- (void)               addObserverWithDidStartBlock:(void (^_Nullable)(AKAOperation *))didStartBlock
                           didProduceOperationBlock:(void (^_Nullable)(AKAOperation *, NSOperation *))didProduceOperationBlock
                             didUpdateProgressBlock:(void (^_Nullable)(AKAOperation *, CGFloat progress, CGFloat workload))didUpdateProgressBlock
                                     didFinishBlock:(void (^_Nullable)(AKAOperation *, NSArray<NSError *> *))didFinishBlock
{
    [self addObserver:[[AKABlockOperationObserver alloc] initWithDidStartBlock:didStartBlock
                                                      didProduceOperationBlock:didProduceOperationBlock
                                                        didUpdateProgressBlock:didUpdateProgressBlock
                                                                didFinishBlock:didFinishBlock]];
}

- (void)addDidUpdateProgressObserverWithBlock:(void (^)(AKAOperation * _Nonnull, CGFloat, CGFloat))block
{
    [self addObserverWithDidStartBlock:NULL
              didProduceOperationBlock:NULL
                didUpdateProgressBlock:block
                        didFinishBlock:NULL];
}

- (void)                                addObserver:(id<AKAOperationObserver>)observer
{
    BOOL added = [self performSynchronizedBlock:
                  ^{
                      NSAssert(![self.observers containsObject:observer], @"Cannot add observer multiple times.");
                      if (!self.observers)
                      {
                          _observers = [NSMutableArray new];
                      }
                      [self.observers addObject:observer];
                  }
                        ifCurrentStateSatisfies:
                  ^BOOL(AKAOperationState state)
                  {
                      return state < AKAOperationStateExecuting;
                  }];
    (void)added; // unused if assertions are disabled.
    NSAssert(added, @"Cannot add observer after execution has begun.");
}

- (void)notifyObserversOperationDidStart
{
    for (id<AKAOperationObserver> observer in self.observers)
    {
        if ([observer respondsToSelector:@selector(operationDidStart:)])
        {
            [observer operationDidStart:self];
        }
    }
}

- (void)notifyObserversOperationDidProduceOperation:(NSOperation*)operation
{
    for (id<AKAOperationObserver> observer in self.observers)
    {
        if ([observer respondsToSelector:@selector(operation:didProduceOperation:)])
        {
            [observer operation:self didProduceOperation:operation];
        }
    }
}

- (void)notifyObserversOperationDidUpdateProgress:(CGFloat)progress andWorkload:(CGFloat)workload
{
    for (id<AKAOperationObserver> observer in self.observers)
    {
        if ([observer respondsToSelector:@selector(operation:didUpdateProgress:workload:)])
        {
            [observer operation:self didUpdateProgress:progress workload:workload];
        }
    }
}

- (void)notifyObserversOperationDidFinish
{
    for (id<AKAOperationObserver> observer in self.observers)
    {
        if ([observer respondsToSelector:@selector(operation:didFinishWithErrors:)])
        {
            [observer operation:self didFinishWithErrors:self.errors];
        }
    }
}

#pragma mark - Progress

- (CGFloat)workloadDone
{
    return self.progress * self.workload;
}
- (void)updateProgressAndWorkloadUsingBlock:(void(^_Nonnull)(CGFloat*_Nonnull progressReference,
                                                             CGFloat*_Nonnull workloadReference))block
{
    NSParameterAssert(block != NULL);

    BOOL progressChanged = NO;
    BOOL workloadChanged = NO;

    [self.progressLock lock];

    CGFloat progress = self.progress;
    CGFloat workload = self.workload;
    block (&progress, &workload);
    NSAssert(progress >= 0.0 && progress <= 1.0,
             @"%@: Invalid progress update to %f, expect value in range 0 .. 1.0", self, progress);
    NSAssert(workload >= 0.0,
             @"%@: Invalid workload update to %f, expected a value greater than or equal to 0", self, workload);

    CGFloat progressDifference = progress - self.progress;
    CGFloat workloadDifference = workload - self.workload;

    progressChanged = progressDifference != 0.0;
    workloadChanged = workloadDifference != 0.0;

    if (workloadChanged || progressChanged)
    {
        [self willChangeValueForKey:@"workloadDone"];
        if (workloadChanged)
        {
            [self willChangeValueForKey:@"workload"];
            _workload = workload;
        }
        if (progressChanged)
        {
            [self willChangeValueForKey:@"progress"];
            _progress = progress;
        }
    }

    // Unlock before KVO or operation observers are notified about the change!
    [self.progressLock unlock];

    if (workloadChanged || progressChanged)
    {
        if (workloadChanged)
        {
            [self didChangeValueForKey:@"workload"];
        }
        if (progressChanged)
        {
            [self didChangeValueForKey:@"progress"];
        }
        [self didChangeValueForKey:@"workloadDone"];
        [self notifyObserversOperationDidUpdateProgress:progressDifference
                                            andWorkload:workloadDifference];
    }
}

#pragma mark - Dependencies

- (void)                              addDependency:(NSOperation *)operation
{
    NSAssert(self.state < AKAOperationStateExecuting, @"Cannot add dependency after execution has begun.");
    NSAssert(![self.dependencies containsObject:operation], @"Cannot add dependency multiple times.");

    [super addDependency:operation];
}

#pragma mark - Producing Operations

- (void)                           produceOperation:(NSOperation*)operation
{
    NSOperationQueue* operationQueue = self.operationQueue;
    NSAssert(operationQueue != nil, @"Cannot produce a new operation from an operation that is not enqueued. Please verify that you used [AKAOperation addToOperationQueue:] to enqueue an instance of AKAOperationQueue.");
    if (![operationQueue isKindOfClass:[AKAOperationQueue class]])
    {
        // AKAOperationQueues are aware of produced operations and will add them automatically.
        // Standard opertion queues won't and need this:
        [AKAOperation addOperation:operation toOperationQueue:operationQueue];
    }
    [self notifyObserversOperationDidProduceOperation:operation];
}

#pragma mark - Execution

- (void)                                      start
{
    // TODO: documentation says: must not call super at any time. However, code in advanced operations and most or all derived frameworks do just that. Their comment is that [super start] does important work that should not be left out. Nobody mentions what it does and why you're not supposed to do it or what excatly has to be done. 
    [super start];

    if (self.cancelled)
    {
        [self finish];
    }
}

- (void)                                       main
{
    NSAssert(self.state == AKAOperationStateReady,
             @"The operation is not ready to be executed. Please ensure that this operation is processed on an operation queue.");

    __block BOOL isExecuting = NO;
    [self           setState:AKAOperationStateExecuting
        ifPredicateSatisfied:^BOOL(AKAOperationState state __unused) {
            return !self.cancelled && self.conditionsSatisfied && self.errors.count == 0;
        } andPerformSynchronizedBlock:^{
            isExecuting = YES;
        }];

    if (isExecuting)
    {
        [self willExecute];
        [self notifyObserversOperationDidStart];
        [self execute];
    }
    else
    {
        [self finish];
    }
}

- (void)                                willExecute
{
}

- (void)                                    execute
{
    AKAErrorAbstractMethodImplementationMissing();
}

#pragma mark - Canncellation

- (void)cancel
{
    [super cancel];
}

- (void)                            cancelWithError:(NSError*)error
{
    if (error)
    {
        [self cancelWithErrors:@[error]];
    }
    else
    {
        [self cancel];
    }
}

- (void)                           cancelWithErrors:(NSArray<NSError*>*)errors
{
    [self performSynchronizedBlock:^{
        [self addErrors:errors];
    } ifCurrentStateSatisfies:NULL];

    [self cancel];
}

#pragma mark - Finishing

- (void)willFinish
{
}

- (void)didFinish
{
}

- (void)finish
{
    [self finishWithError:nil];
}

- (void)finishWithError:(NSError*)error
{
    __weak typeof(self) weakSelf = self;
    BOOL isFinishing = [self setState:AKAOperationStateFinishing
                 ifPredicateSatisfied:^BOOL(AKAOperationState state) {
                     return state < AKAOperationStateFinishing;
                 } andPerformSynchronizedBlock:^{
                     __strong typeof(self) strongSelf = weakSelf;
                     if (error)
                     {
                         [strongSelf addError:error];
                     }
                 }];
    if (isFinishing)
    {
        self.isFinishing = YES;
        [self willFinish];
        [self notifyObserversOperationDidFinish];
        [self setState:AKAOperationStateFinished andPerformSynchronizedBlock:^{
            self.isFinishing = NO;
        }];
        [self updateProgressAndWorkloadUsingBlock:^(CGFloat * _Nonnull progressReference, CGFloat * _Nonnull workloadReference) {
            *progressReference = 1.0;
        }];
        [self didFinish];
    }
}


- (void)finishWithErrors:(NSArray<NSError*>*)errors
{
    __weak typeof(self) weakSelf = self;
    BOOL isFinishing = [self setState:AKAOperationStateFinishing
                 ifPredicateSatisfied:^BOOL(AKAOperationState state) {
                     return state < AKAOperationStateFinishing;
                 } andPerformSynchronizedBlock:^{
                     __strong typeof(self) strongSelf = weakSelf;
                     [strongSelf addErrors:errors];
                 }];
    if (isFinishing)
    {
        self.isFinishing = YES;
        [self willFinish];
        [self notifyObserversOperationDidFinish];
        [self setState:AKAOperationStateFinished andPerformSynchronizedBlock:^{
            self.isFinishing = NO;
        }];
        [self updateProgressAndWorkloadUsingBlock:^(CGFloat * _Nonnull progressReference, CGFloat * _Nonnull workloadReference) {
            *progressReference = 1.0;
        }];
        [self didFinish];
    }
}

- (void)anitPatternNoticeForWaitUntilFinished
{
    NSAssert(NO, @"Waiting on operations is almost NEVER the right thing to do. It is usually superior to use proper locking constructs, such as `dispatch_semaphore_t` or `dispatch_group_notify`, or even `NSLocking` objects. Many developers use waiting when they should instead be chaining discrete operations together using dependencies.\n\n To reinforce this idea, invoking `waitUntilFinished()` will crash your app, as incentive for you to find a more appropriate way to express the behavior you're wishing to create. Override `anitPatternNoticeForWaitUntilFinished` to disable this assertion.");

}

- (void)waitUntilFinished
{
    //[self anitPatternNoticeForWaitUntilFinished];
    [super waitUntilFinished];
}

#pragma mark - Operation Queues

+ (void)addOperation:(NSOperation*)operation
    toOperationQueue:(NSOperationQueue*)operationQueue
{
    if ([operation isKindOfClass:[AKAOperation class]])
    {
        [((AKAOperation*)operation) addToOperationQueue:operationQueue];
    }
    else
    {
        [operationQueue addOperation:operation];
    }
}

- (void)addToOperationQueue:(NSOperationQueue*)operationQueue
{
    if (![operationQueue isKindOfClass:[AKAOperationQueue class]])
    {
        // AKAOperationQueue will call prepareToAddToOperationQueue: itself on addOperation: so we skip it here
        [self prepareToAddToOperationQueue:operationQueue];
    }
    [operationQueue addOperation:self];
}

- (void)prepareToAddToOperationQueue:(NSOperationQueue*)operationQueue
{
    self.state = AKAOperationStateEnqueuing;
    self.operationQueue = operationQueue;

    // Conditions have to be added before the state is set to pending, because updating the state
    // will trigger a call to isReady which needs dependencies added by conditions.
    [self enumerateConditionsUsingBlock:^(AKAOperationCondition * _Nonnull condition,
                                          BOOL * _Nonnull stop __unused)
     {
         if ([condition.class isMutuallyExclusive])
         {
             NSArray* categories = @[ NSStringFromClass(condition.class)];
             [[AKAOperationExclusivityController sharedInstance] addOperation:self
                                                                 toCategories:categories];
             [self addObserver:[[AKABlockOperationObserver alloc] initWithDidStartBlock:nil
                                                               didProduceOperationBlock:nil
                                                                         didFinishBlock:
                                ^(AKAOperation *operation, NSArray<NSError *> *errors)
                                {
                                    [[AKAOperationExclusivityController sharedInstance] removeOperation:operation
                                                                                         fromCategories:categories];
                                }]];
         }

         NSOperation* conditionDependency = [condition dependencyForOperation:self];
         if (conditionDependency)
         {
             [self addDependency:conditionDependency];
             [AKAOperation addOperation:conditionDependency toOperationQueue:operationQueue];
         }
     }];

    self.state = AKAOperationStatePending;
}

@end


@implementation AKAOperation(Subclasses)

- (void)addError:(NSError *)error
{
    [self willChangeValueForKey:@"errors"];
    if (self.internalErrors == nil)
    {
        self.internalErrors = [NSMutableArray arrayWithObject:error];
    }
    else
    {
        [self.internalErrors addObject:error];
    }
    [self didChangeValueForKey:@"errors"];
}

- (void)addErrors:(NSArray<NSError *> *)errors
{
    if (errors.count > 0)
    {
        [self willChangeValueForKey:@"errors"];
        if (self.internalErrors == nil)
        {
            self.internalErrors = [NSMutableArray arrayWithArray:errors];
        }
        else
        {
            [self.internalErrors addObjectsFromArray:errors];
        }
        [self didChangeValueForKey:@"errors"];
    }
}

@end
