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

@interface AKAGroupOperation() <AKAOperationQueueDelegate>

@property(nonatomic, readonly) AKAOperation* startOperation;
@property(nonatomic, readonly) AKAOperation* finishOperation;

@end


@implementation AKAGroupOperation

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
        _startOperation = [self.class createStartOperationForGroup:self];
        self.startOperation.name = [NSString stringWithFormat:@"Group start operation"];
        _finishOperation = [self.class createFinishOperationForGroup:self];
        self.finishOperation.name = [NSString stringWithFormat:@"Group finish operation"];

        _internalQueue = [AKAOperationQueue new];
        self.internalQueue.suspended = YES;
        self.internalQueue.delegate = self;

        [self.startOperation addToOperationQueue:self.internalQueue];
        for (NSOperation* operation in operations)
        {
            [self addOperation:operation];
        }
    }
    return self;
}

#pragma mark - Cancellation

- (void)cancel
{
    [self.internalQueue cancelAllOperations];
    [super cancel];
}

- (void)execute
{
    self.internalQueue.suspended = NO;
    [self addOperation:self.finishOperation];
}

- (void)addOperation:(NSOperation*)operation
{
    [self.internalQueue addOperation:operation];
}

- (void)addOperations:(NSArray<NSOperation*>*)operations
{
    for (NSOperation* operation in operations)
    {
        [self addOperation:operation];
    }
}

- (void)                operation:(NSOperation*__unused)operation
              didFinishWithErrors:(NSArray<NSError*>*__unused)errors
{
    // Can be overridden by subclasses to get notified of child operations finishing execution
}

#pragma mark - Delegate

- (void)operationQueue:(AKAOperationQueue *__unused)operationQueue
      willAddOperation:(NSOperation *)operation
{
    NSAssert(self.internalQueue == operationQueue, @"Unexpected queue");
    NSAssert(!self.finishOperation.isFinished && !self.finishOperation.isExecuting,
             @"cannot add new operations to a group after the group has completed");

    if (operation != self.finishOperation)
    {
        [self.finishOperation addDependency:operation];
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
    }
}

@end
