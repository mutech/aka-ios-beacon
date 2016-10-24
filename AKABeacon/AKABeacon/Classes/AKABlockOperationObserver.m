//
//  AKABlockOperationObserver.m
//  AKABeacon
//
//  Created by Michael Utech on 29.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABlockOperationObserver.h"

@implementation AKABlockOperationObserver

#pragma mark - Initialization

+ (instancetype)   didFinishBlockObserver:(void (^)(AKAOperation *, NSArray<NSError *> *))didFinishBlock
{
    return [[AKABlockOperationObserver alloc] initWithDidStartBlock:NULL
                                           didProduceOperationBlock:NULL
                                                     didFinishBlock:didFinishBlock];
}

- (instancetype)    initWithDidStartBlock:(void (^)(AKAOperation *))didStartBlock
                 didProduceOperationBlock:(void (^)(AKAOperation *, NSOperation *))didProduceOperationBlock
                           didFinishBlock:(void (^)(AKAOperation *, NSArray<NSError *> *))didFinishBlock
{
    return [self initWithDidStartBlock:didStartBlock
              didProduceOperationBlock:didProduceOperationBlock
                didUpdateProgressBlock:NULL
                        didFinishBlock:didFinishBlock];
}

- (instancetype)    initWithDidStartBlock:(void (^)(AKAOperation* operation))didStartBlock
                 didProduceOperationBlock:(void (^)(AKAOperation* operation, NSOperation *))didProduceOperationBlock
                   didUpdateProgressBlock:(void (^)(AKAOperation* operation, CGFloat progressDifference, CGFloat workloadDifference))didUpdateProgressBlock
                           didFinishBlock:(void (^)(AKAOperation* operation, NSArray<NSError*>* errors))didFinishBlock
{
    if (self = [self init])
    {
        _didStartBlock = didStartBlock;
        _didProduceOperationBlock = didProduceOperationBlock;
        _didUpdateProgressBlock = didUpdateProgressBlock;
        _didFinishBlock = didFinishBlock;
    }
    return self;
}

#pragma mark - AKAOperationObserver

- (void)                operationDidStart:(AKAOperation *)operation
{
    if (self.didStartBlock != NULL)
    {
        self.didStartBlock(operation);
    }
}

- (void)                        operation:(AKAOperation *)operation
                      didProduceOperation:(NSOperation *)newOperation
{
    if (self.didProduceOperationBlock != NULL)
    {
        self.didProduceOperationBlock(operation, newOperation);
    }
}

- (void)                        operation:(AKAOperation *)operation
                        didUpdateProgress:(CGFloat)progressDifference
                                 workload:(CGFloat)workloadDifference
{
    if (self.didUpdateProgressBlock != NULL)
    {
        self.didUpdateProgressBlock(operation, progressDifference, workloadDifference);
    }
}

- (void)                        operation:(AKAOperation *)operation
                      didFinishWithErrors:(NSArray<NSError *> *)errors
{
    if (self.didFinishBlock != NULL)
    {
        self.didFinishBlock(operation, errors);
    }
}

@end
