//
//  AKAGroupOperation.m
//  AKABeacon
//
//  Created by Michael Utech on 29.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAGroupOperation.h"
#import "AKABlockOperation.h"
#import "AKAOperationQueue.h"



@interface AKAGroupOperationProgressRecord: NSObject

@property(nonatomic, readonly, weak) NSOperation* operation;
@property(nonatomic) CGFloat recordedWorkload;
@property(nonatomic) CGFloat workloadFactor;

@end


@implementation AKAGroupOperationProgressRecord: NSObject

+ (AKAGroupOperationProgressRecord*)recordForOperation:(NSOperation*)operation
                                    withWorkloadFactor:(CGFloat)workloadFactor
{
    AKAGroupOperationProgressRecord* result = [AKAGroupOperationProgressRecord new];
    result->_operation = operation;
    result->_workloadFactor = workloadFactor;
    result->_recordedWorkload = 0.0;

    return result;
}

- (NSString *)description
{
    return self.operation.description;
}

@end


@interface AKAGroupOperationMembersFinishedCondition: AKAOperationCondition

- (instancetype)initWithGroupOperation:(AKAGroupOperation*)groupOperation;

@property(nonatomic, readonly, weak) AKAGroupOperation* groupOperation;
@property(nonatomic, readonly) dispatch_group_t dispatchGroup;

@end


@interface AKAGroupOperation() <AKAOperationQueueDelegate>

@property(nonatomic, readonly) AKAOperation* startOperation;
@property(nonatomic, readonly) AKAOperation* finishOperation;

// TODO: this array is not needed (addOperation:withWorkloadFactor captures the records), this is used to help debugging. Remove it once the code is stable.
@property(nonatomic, readonly) NSMutableArray<AKAGroupOperationProgressRecord*>* progressRecords;

@property(nonatomic, readonly) AKAGroupOperationMembersFinishedCondition* finishedCondition;

@end


@implementation AKAGroupOperationMembersFinishedCondition

- (instancetype)initWithGroupOperation:(AKAGroupOperation*)groupOperation
{
    if (self = [super init])
    {
        _groupOperation = groupOperation;
        _dispatchGroup = dispatch_group_create();
    }
    return self;
}

- (void)groupWillAddOperation:(NSOperation*)operation
{
    dispatch_group_enter(self.dispatchGroup);
}

- (void)groupMemberOperationDidFinish:(NSOperation*)operation
{
    dispatch_group_leave(self.dispatchGroup);
}

- (void)evaluateForOperation:(AKAOperation *)operation completion:(void (^)(BOOL, NSError * _Nullable))completion
{
    NSAssert(operation == self.groupOperation.finishOperation,
             @"Internal inconsistency, AKAGroupOperationMembersFinishedCondition can only be evaluated for its group operation");
    __weak AKAGroupOperationMembersFinishedCondition* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_wait(weakSelf.dispatchGroup, DISPATCH_TIME_FOREVER);
        completion(YES, nil);
    });
}

+ (BOOL)isMutuallyExclusive
{
    return NO;
}

@end


@implementation AKAGroupOperation

@dynamic progress;

#pragma mark - Initialization


+ (AKAOperation*)createStartOperationForGroup:(AKAGroupOperation*__unused)operation

{
    return [[AKABlockOperation alloc] initWithBlock:^(void (^ _Nonnull finish)()) {
        finish();
    }];
}

+ (AKAOperation*)createFinishOperationForGroup:(AKAGroupOperation*__unused)operation

{
    return [[AKABlockOperation alloc] initWithBlock:^(void (^ _Nonnull finish)()) {
        finish();
    }];
}

- (instancetype)initWithOperations:(NSArray<NSOperation*>*)operations
{
    if (self = [self init])
    {
        for (NSOperation* operation in operations)
        {
            [self addOperation:operation];
        }
    }
    return self;
}

- (instancetype)init
{
    return [self initWithWorkload:0];
}

- (instancetype)initWithWorkload:(CGFloat)workload
{
    if (self = [super initWithWorkload:workload])
    {
        _progressRecords = [NSMutableArray new];
        
        _startOperation = [self.class createStartOperationForGroup:self];
        if (self.startOperation.name.length == 0)
        {
            self.startOperation.name = [NSString stringWithFormat:@"Group start operation"];
        }
        _finishOperation = [self.class createFinishOperationForGroup:self];
        if (self.finishOperation.name.length == 0)
        {
            self.finishOperation.name = [NSString stringWithFormat:@"Group finish operation"];
        }
        _finishedCondition = [[AKAGroupOperationMembersFinishedCondition alloc] initWithGroupOperation:self];
        [self.finishOperation addCondition:self.finishedCondition];

        _internalQueue = [AKAOperationQueue new];
        self.internalQueue.suspended = YES;
        self.internalQueue.delegate = self;

        [self.startOperation addToOperationQueue:self.internalQueue];
    }
    return self;
}

#pragma mark - Adding Member Operations

- (void)addOperation:(NSOperation*)operation
{
    [self addOperation:operation withWorkloadFactor:1.0];
}

- (void)addOperation:(NSOperation*)operation
  withWorkloadFactor:(CGFloat)workloadFactor
{
    __weak NSOperation* weakOperation = operation;
    AKAGroupOperationProgressRecord* progressRecord =
        [AKAGroupOperationProgressRecord recordForOperation:operation withWorkloadFactor:workloadFactor];
    [self.progressRecords addObject:progressRecord];

    __weak AKAGroupOperation* weakSelf = self;
    if ([operation isKindOfClass:[AKAOperation class]])
    {
        AKAOperation* akaOperation = (AKAOperation*)operation;
        [akaOperation addDidUpdateProgressObserverWithBlock:
         ^(AKAOperation * _Nonnull op, CGFloat progressDifference, CGFloat workloadDifference)
         {
             NSParameterAssert(weakOperation == op);

             [weakSelf updateProgressForOperation:op
                               withProgressRecord:progressRecord
                               progressDifference:progressDifference
                               workloadDifference:workloadDifference];
         }];
    }
    else
    {
        // Non-AKAOperation instances transition from 0 -> 1.0 progress once they are finished:
        void (^completion)() = ^{
            __strong NSOperation* strongOperation = weakOperation;
            __strong AKAGroupOperation* strongSelf = weakSelf;

            if (strongOperation && strongSelf)
            {
                [weakSelf updateProgressForOperation:strongOperation
                                  withProgressRecord:progressRecord
                                  progressDifference:1.0
                                  workloadDifference:0.0];
            }
        };

        if (operation.completionBlock == NULL)
        {
            operation.completionBlock = completion;
        }
        else
        {
            void (^previousCompletionBlock)() = operation.completionBlock;
            operation.completionBlock = ^{
                previousCompletionBlock();
                completion();
            };
        }
    }

    // Update workload for added operation
    CGFloat workload = [self workloadForOperation:operation] * progressRecord.workloadFactor;
    CGFloat progress = [self progressOfOperation:operation];
    NSAssert(progress == 0.0, nil);

    [self updateProgressForOperation:operation
                  withProgressRecord:progressRecord
                  progressDifference:progress   // 0->progress (=0 in this state)
                  workloadDifference:workload]; // 0->workload

    [self.internalQueue addOperation:operation];
}

- (void)addOperations:(NSArray<NSOperation*>*)operations
{
    for (NSOperation* operation in operations)
    {
        [self addOperation:operation];
    }
}

#pragma mark - Progress

- (CGFloat)progressOfOperation:(NSOperation*)operation
{
    CGFloat result;

    if ([operation isKindOfClass:[AKAOperation class]])
    {
        result = ((AKAOperation*)operation).progress;
    }
    else
    {
        result = operation.isFinished ? 1.0 : 0.0;
    }

    return result;
}

- (CGFloat)workloadForGroupStartOperation
{
    return 0.0;
}

- (CGFloat)workloadForGroupFinishOperation
{
    return 0.0;
}

- (CGFloat)workloadForOperation:(NSOperation*)operation
{
    CGFloat result;
    if (operation == self.startOperation)
    {
        result = [self workloadForGroupStartOperation];
    }
    else if (operation == self.finishOperation)
    {
        result = [self workloadForGroupFinishOperation];
    }
    else if ([operation isKindOfClass:[AKAOperation class]])
    {
        result = ((AKAOperation*)operation).workload;
        NSAssert(result >= 0, nil);
    }
    else
    {
        result = 1.0;
    }
    return result;
}

- (void)updateProgressForOperation:(nonnull NSOperation*)operation
                withProgressRecord:(AKAGroupOperationProgressRecord*)progressRecord
                progressDifference:(CGFloat)progressDifference
                workloadDifference:(CGFloat)workloadDifference
{
    if (progressRecord)
    {
        [self updateProgressAndWorkloadUsingBlock:
         ^(CGFloat * _Nonnull progressReference, CGFloat * _Nonnull workloadReference)
         {
             CGFloat oldGroupProgress = *progressReference;
             CGFloat oldGroupWorkload = *workloadReference;
             CGFloat oldGroupWorkloadDone = oldGroupProgress * oldGroupWorkload;

             CGFloat newGroupProgress = oldGroupProgress;
             CGFloat newGroupWorkload = oldGroupWorkload;
             CGFloat newGroupWorkloadDone = oldGroupWorkloadDone;

             if (workloadDifference != 0.0)
             {
                 CGFloat weightedWorkloadDifference = (workloadDifference * progressRecord.workloadFactor);
                 newGroupWorkload += weightedWorkloadDifference;
                 progressRecord.recordedWorkload += weightedWorkloadDifference;
             }

             if (progressDifference != 0.0)
             {
                 newGroupWorkloadDone += (progressDifference * progressRecord.recordedWorkload);
             }

             if (newGroupWorkload > 0)
             {
                 newGroupProgress = newGroupWorkloadDone / newGroupWorkload;
                 if (newGroupProgress < 0)
                 {
                     newGroupProgress = 0;
                 }
                 else if (newGroupProgress > 1.0)
                 {
                     newGroupProgress = 1.0;
                 }
             }

             *progressReference = newGroupProgress;
             *workloadReference = newGroupWorkload;
         }];
    }
}

#pragma mark - Cancellation

- (void)cancel
{
    [self.internalQueue cancelAllOperations];
    [super cancel];
}

#pragma mark - Execution

- (void)execute
{
    [self addOperation:self.finishOperation];
    self.internalQueue.suspended = NO;
}

#pragma mark - Execution Events

- (void)        operationDidStart:(NSOperation*__unused)operation __attribute__((objc_requires_super))
{
    // Can be overridden by subclasses to get notified of child operations finishing execution
}

- (void)                operation:(NSOperation*__unused)operation
              didFinishWithErrors:(NSArray<NSError*>*__unused)errors __attribute__((objc_requires_super))
{
    // Can be overridden by subclasses to get notified of child operations finishing execution
}

#pragma mark - Operation Queue Delegate

- (void)operationQueue:(AKAOperationQueue *__unused)operationQueue
      willAddOperation:(NSOperation *)operation
{
    NSAssert(self.internalQueue == operationQueue, @"Unexpected queue");
    NSAssert(!self.finishOperation.isFinished && !self.finishOperation.isExecuting,
             @"cannot add new operations to a group after the group has completed");

    if (operation != self.finishOperation)
    {
        if ([operation isKindOfClass:[AKAOperation class]] && self.finishedCondition)
        {
            if (operation != self.startOperation && operation != self.finishOperation)
            {
                [self.finishedCondition groupWillAddOperation:operation];
            }
        }
        else
        {
            [self.finishOperation addDependency:operation];
        }
    }

    // Finish operation already depends on start operation:
    if (operation != self.startOperation && operation != self.finishOperation)
    {
        [operation addDependency:self.startOperation];
    }

}

- (void)operationQueue:(AKAOperationQueue *__unused)operationQueue
    operationDidFinish:(NSOperation *)operation
            withErrors:(NSArray<NSError *> *)errors
{
    NSAssert(self.internalQueue == operationQueue, @"Unexpected queue");
    if (errors.count)
    {
        [self addErrors:errors];
    }

    if (operation == self.finishOperation)
    {
        self.internalQueue.suspended = YES;
        [self finishWithErrors:errors];

    }
    else if (operation != self.startOperation)
    {
        [self operation:operation didFinishWithErrors:errors];
        if ([operation isKindOfClass:[AKAOperation class]] && self.finishedCondition)
        {
            if (operation != self.startOperation && operation != self.finishOperation)
            {
                [self.finishedCondition groupMemberOperationDidFinish:operation];
            }
        }
    }
}

@end


@implementation AKASerializedGroupOperation

- (void)addOperation:(NSOperation*)operation withWorkloadFactor:(CGFloat)workloadFactor
{
    NSOperation* lastOperation = self.progressRecords.lastObject.operation;
    if (lastOperation && lastOperation != self.startOperation && operation != self.finishOperation)
    {
        [operation addDependency:lastOperation];
    }
    [super addOperation:operation withWorkloadFactor:workloadFactor];
}

@end
