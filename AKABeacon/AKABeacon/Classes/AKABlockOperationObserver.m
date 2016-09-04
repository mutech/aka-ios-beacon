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

+ (instancetype)didFinishBlockObserver:(void (^)(AKAOperation *, NSArray<NSError *> *))didFinishBlock
{
    return [[AKABlockOperationObserver alloc] initWithDidStartBlock:NULL
                                           didProduceOperationBlock:NULL
                                                     didFinishBlock:didFinishBlock];
}

- (instancetype)initWithDidStartBlock:(void (^)(AKAOperation *))didStartBlock
             didProduceOperationBlock:(void (^)(AKAOperation *, NSOperation *))didProduceOperationBlock
                       didFinishBlock:(void (^)(AKAOperation *, NSArray<NSError *> *))didFinishBlock
{
    if (self = [self init])
    {
        _didStartBlock = didStartBlock;
        _didProduceOperationBlock = didProduceOperationBlock;
        _didFinishBlock = didFinishBlock;
    }
    return self;
}

#pragma mark - AKAOperationObserver

- (void)operationDidStart:(AKAOperation *)operation
{
    if (self.didStartBlock != NULL)
    {
        self.didStartBlock(operation);
    }
}

- (void)operation:(AKAOperation *)operation didProduceOperation:(NSOperation *)newOperation
{
    if (self.didProduceOperationBlock != NULL)
    {
        self.didProduceOperationBlock(operation, newOperation);
    }
}

- (void)operation:(AKAOperation *)operation didFinishWithErrors:(NSArray<NSError *> *)errors
{
    if (self.didFinishBlock != NULL)
    {
        self.didFinishBlock(operation, errors);
    }
}

@end
