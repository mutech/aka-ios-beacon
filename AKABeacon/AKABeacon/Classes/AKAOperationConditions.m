//
//  AKAOperationConditions.m
//  AKABeacon
//
//  Created by Michael Utech on 08.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperationConditions.h"
#import "AKAOperationConditions_SubConditions.h"

#import "AKAOperationErrors.h"


@implementation AKAOperationConditions

- (instancetype)init
{
    if (self = [super init])
    {
        _conditions = [NSMutableArray new];
    }
    return self;
}

- (instancetype)initWithConditions:(NSArray<AKAOperationCondition*>*)conditions
{
    if (self = [self init])
    {
        for (AKAOperationCondition* condition in conditions)
        {
            [self addCondition:condition];
        }
    }
    return self;
}

- (void)addCondition:(AKAOperationCondition *)condition
{
    [self.conditions addObject:condition];
}


- (void)enumerateConditionsUsingBlock:(void(^)(AKAOperationCondition* _Nonnull condition,
                                               outreq_BOOL stop))block
{
    BOOL stop = NO;
    [self enumerateConditionsUsingBlock:block stop:&stop];
}

- (void)enumerateConditionsUsingBlock:(void(^)(AKAOperationCondition* _Nonnull condition,
                                               outreq_BOOL stop))block
                                 stop:(outreq_BOOL)stop
{
    for (NSUInteger i=0; !*stop && i < self.conditions.count; ++i)
    {
        AKAOperationCondition* condition = self.conditions[i];
        if ([condition isKindOfClass:[AKAOperationConditions class]])
        {
            AKAOperationConditions* conditions = (id)condition;

            [conditions enumerateConditionsUsingBlock:block stop:stop];
        }
        else
        {
            block(condition, stop);
        }
    }
}

- (void)evaluateForOperation:(AKAOperation *)operation
                  completion:(void (^)(BOOL, NSError *))completion
{
    dispatch_group_t dispatchGroup = dispatch_group_create();

    NSMutableArray* results = [NSMutableArray new];

    NSArray* conditions = self.conditions;

    for (NSUInteger i=0; i < conditions.count; ++i)
    {
        AKAOperationCondition* condition = self.conditions[i];
        [results addObject:[NSNull null]];

        dispatch_group_enter(dispatchGroup);
        [condition evaluateForOperation:operation
                             completion:^(BOOL satisfied, NSError *error) {
                                 NSAssert(satisfied ? error == nil : YES, @"If condition is satisfied, error has to be nil");
                                 if (satisfied)
                                 {
                                     results[i] = @(YES);
                                 }
                                 else if (error)
                                 {
                                     results[i] = error;
                                 }
                                 else
                                 {
                                     results[i] = @(NO);
                                 }
                                 dispatch_group_leave(dispatchGroup);
                             }];
    }

    dispatch_group_notify(dispatchGroup,
                          dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0),
                          ^{
                              NSMutableArray* failures = nil;
                              BOOL satisfied = YES;
                              for (id result in results)
                              {
                                  if (result != [NSNull null])
                                  {
                                      if ([result isKindOfClass:[NSNumber class]])
                                      {
                                          if (satisfied)
                                          {
                                              satisfied = [result boolValue];
                                          }
                                      }
                                      else if ([result isKindOfClass:[NSError class]])
                                      {
                                          satisfied = NO;
                                          if (failures == nil)
                                          {
                                              failures = [NSMutableArray new];
                                          }
                                          [failures addObject:result];
                                      }
                                  }
                              }

                              if (operation.cancelled)
                              {
                                  if (failures == nil)
                                  {
                                      failures = [NSMutableArray new];
                                  }
                                  [failures addObject:[NSError errorWithDomain:kAKAOperationErrorDomain
                                                                          code:AKAOperationErrorConditionFailed
                                                                      userInfo:nil]];
                              }

                              NSError* error = nil;
                              if (failures.count > 1)
                              {
                                  error = [NSError errorWithDomain:kAKAOperationErrorDomain
                                                              code:AKAOperationErrorConditionFailed
                                                          userInfo:@{ @"errors": failures }];
                              }
                              else if (failures.count == 1)
                              {
                                  error = failures.firstObject;
                              }
                              completion(satisfied, error);
                              
                          });
}

- (NSOperation *)dependencyForOperation:(NSOperation* __unused)operation
{
    NSAssert(NO, @"`AKAOperationConditions` does not support `dependencyForOperation:`. Use `enumerateConditionsUsingBlock:` to collect the dependencies for contained conditions.");

    return nil;
}

@end
