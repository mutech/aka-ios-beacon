//
//  AKAOperationExclusivityController.m
//  AKABeacon
//
//  Created by Michael Utech on 11.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperationExclusivityController.h"


@interface AKAOperationExclusivityController()

@property(nonatomic, readonly) dispatch_queue_t queue;
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSMutableArray<AKAOperation*>*>* operationsByCategory;

@end


@implementation AKAOperationExclusivityController

#pragma mark - Initialization

+ (instancetype)             allocSharedInstance
{
    return [super alloc];
}

- (instancetype)              initSharedInstance
{
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("AKAOperations.ExclusivityController",
                                       DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (instancetype)                  sharedInstance
{
    static AKAOperationExclusivityController* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[AKAOperationExclusivityController allocSharedInstance] initSharedInstance];
    });
    return nil;
}

#pragma mark - Operations

- (void)                            addOperation:(AKAOperation *)operation
                                    toCategories:(NSArray<NSString *> *)categories
{
    dispatch_sync(self.queue, ^{
        [self _addOperation:operation toCategories:categories];
    });
}

- (void)                           _addOperation:(AKAOperation *)operation
                                    toCategories:(NSArray<NSString *> *)categories
{
    for (NSString* category in categories)
    {
        NSMutableArray* operations = self.operationsByCategory[category];
        if (!operations)
        {
            operations = [NSMutableArray new];
            self.operationsByCategory[category] = operations;
        }

        AKAOperation* last = operations.lastObject;
        if (last)
        {
            [operation addDependency:last];
        }

        [operations addObject:operation];
    }
}

- (void)                         removeOperation:(AKAOperation *)operation
                                  fromCategories:(NSArray<NSString *> *)categories
{
    dispatch_async(self.queue, ^{
        [self _removeOperation:operation fromCategories:categories];
    });
}

- (void)                        _removeOperation:(AKAOperation *)operation
                                  fromCategories:(NSArray<NSString *> *)categories
{
    for (NSString* category in categories)
    {
        NSMutableArray* operations = self.operationsByCategory[category];
        [operations removeObject:operation];
    }
}


@end
