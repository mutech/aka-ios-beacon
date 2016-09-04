//
//  AKAOperationQueue.m
//  AKABeacon
//
//  Created by Michael Utech on 29.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperationQueue.h"
#import "AKAOperation.h"
#import "AKAOperation_Internal.h"
#import "AKABlockOperationObserver.h"

@implementation AKAOperationQueue

- (void)addOperation:(NSOperation *)operation
{
    __weak typeof(self) weakSelf = self;

    if ([operation isKindOfClass:[AKAOperation class]])
    {
        AKAOperation* akaOperation = (AKAOperation*)operation;

        id<AKAOperationObserver> observer =
            [[AKABlockOperationObserver alloc] initWithDidStartBlock:NULL
                                            didProduceOperationBlock:
             ^(AKAOperation *observedOperation __unused, NSOperation *newOperation)
             {
                 [weakSelf addOperation:newOperation];
             }
                                                      didFinishBlock:
             ^(AKAOperation *observedOperation, NSArray<NSError *> *errors)
             {
                 __strong typeof(weakSelf) strongSelf = weakSelf;
                 [strongSelf.delegate operationQueue:strongSelf
                                  operationDidFinish:observedOperation
                                          withErrors:errors];
             }];
        [akaOperation addObserver:observer];

        // Puts the operation in pending state, adds dependencies for conditions of the operation and sets up the system for mutual exclusivity constraints (if needed):
        [akaOperation prepareToAddToOperationQueue:self];
    }
    else
    {
        __weak typeof(operation) weakOperation = operation;
        if (operation.completionBlock == NULL)
        {
            operation.completionBlock = ^ {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf.delegate operationQueue:strongSelf
                                 operationDidFinish:weakOperation
                                         withErrors:@[]];
            };
        }
    }

    id<AKAOperationQueueDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(operationQueue:willAddOperation:)])
    {
        [delegate operationQueue:self willAddOperation:operation];
    }

    [super addOperation:operation];
}

- (void)addOperations:(NSArray<NSOperation *> *)operations waitUntilFinished:(BOOL)wait
{
    for (NSOperation* operation in operations)
    {
        [self addOperation:operation];
    }

    if (wait)
    {
        for (NSOperation* operation in operations)
        {
            [operation waitUntilFinished];
        }
    }
}

@end
