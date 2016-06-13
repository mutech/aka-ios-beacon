//
//  AKAOperationCondition.m
//  AKABeacon
//
//  Created by Michael Utech on 08.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperationCondition.h"
#import "AKAOperationErrors.h"


@implementation AKAOperationCondition

+ (BOOL)isMutuallyExclusive
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (BOOL)requireAsynchronousEvaluation
{
    return YES;
}

- (void)evaluateForOperation:(AKAOperation *__unused)operation
                  completion:(void (^__unused)(BOOL, NSError *))completion
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (nullable NSOperation*)dependencyForOperation:(nonnull NSOperation* __unused)operation
{
    return nil;
}

@end


@interface AKAKVOOperationCondition()

@property(nonatomic, nonnull) NSObject* target;
@property(nonatomic, nonnull) NSString* keyPath;
@property(nonatomic, nonnull) NSPredicate* predicate;
@property(nonatomic, nullable) NSOperation*_Nullable(^dependencyForOperationBlock)(NSOperation*_Nonnull);
@property(nonatomic, nullable) NSMutableArray* completions;
@property(nonatomic, nonnull) dispatch_queue_t queue;
@property(nonatomic) BOOL isObserving;

@end

@implementation AKAKVOOperationCondition

+ (BOOL)isMutuallyExclusive
{
    return NO;
}

- (instancetype)initWithTarget:(NSObject *)target
                       keyPath:(NSString *)keyPath
                     predicate:(NSPredicate *)predicate
   dependencyForOperationBlock:(NSOperation*_Nullable(^_Nullable)(NSOperation*_Nonnull))dependencyForOperationBlock
{
    if (self = [self init])
    {
        self.target = target;
        self.keyPath = keyPath;
        self.predicate = predicate;
        self.dependencyForOperationBlock = dependencyForOperationBlock;
        self.completions = [NSMutableArray new];
        self.queue = dispatch_queue_create("KVOCondition", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (instancetype)initWithTarget:(NSObject *)target keyPath:(NSString *)keyPath
                predicateBlock:(BOOL (^)(id _Nullable))predicateBlock
   dependencyForOperationBlock:(NSOperation * _Nullable (^)(NSOperation * _Nonnull))dependencyForOperationBlock
{
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings __unused) {
        return predicateBlock(evaluatedObject);
    }];
    return [self initWithTarget:target
                        keyPath:keyPath
                      predicate:predicate
    dependencyForOperationBlock:dependencyForOperationBlock];
}

- (void)dealloc
{
    if (self.isObserving)
    {
        [self stopObserving];
    }
}

- (void)evaluateForOperation:(AKAOperation *__unused)operation
                  completion:(void (^)(BOOL, NSError * _Nullable))completion
{
    dispatch_async(self.queue, ^{
        [self.completions addObject:completion];

        [self startObserving];
    });
}

- (NSOperation *)dependencyForOperation:(NSOperation *)operation
{
    NSOperation* result = nil;

    if (self.dependencyForOperationBlock != NULL)
    {
        result = self.dependencyForOperationBlock(operation);
    }

    return result;
}

- (void)evaluateAndNotify
{
    id value = [self.target valueForKeyPath:self.keyPath];
    if ([self.predicate evaluateWithObject:value])
    {
        [self stopObserving];
        for (void (^completion)(BOOL, NSError * _Nullable) in self.completions)
        {
            completion(YES, nil);
        }
        [self.completions removeAllObjects];
    }
}

- (void)startObserving
{
    if (self.isObserving)
    {
        [self evaluateAndNotify];
    }
    else
    {
        [self.target addObserver:self
                      forKeyPath:self.keyPath
                         options:NSKeyValueObservingOptionInitial
                         context:nil];
    }
}

- (void)stopObserving
{
    if (self.isObserving)
    {
        [self.target removeObserver:self
                         forKeyPath:self.keyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *__unused)change
                       context:(void *)context
{
    NSAssert([self.keyPath isEqualToString:keyPath] &&
             object == self.target &&
             context == nil, @"Unexpected change notification");

    dispatch_async(self.queue, ^{
        [self evaluateAndNotify];
    });
}

@end
