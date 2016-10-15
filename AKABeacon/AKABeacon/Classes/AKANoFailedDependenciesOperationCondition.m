//
//  AKANoFailedDependenciesOperationCondition.m
//  AKABeacon
//
//  Created by Michael Utech on 31.07.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKANoFailedDependenciesOperationCondition.h"
#import "AKAOperationErrors.h"
#import "AKAOperation.h"

@implementation AKANoFailedDependenciesOperationCondition

+ (BOOL)isMutuallyExclusive
{
    return NO;
}

+ (instancetype)sharedInstance
{
    static AKANoFailedDependenciesOperationCondition* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [AKANoFailedDependenciesOperationCondition new];
    });
    return result;
}

- (NSOperation *)dependencyForOperation:(NSOperation*__unused)operation
{
    return nil;
}

- (void)evaluateForOperation:(AKAOperation *)operation
                  completion:(void (^)(BOOL, NSError * _Nullable))completion
{
    BOOL satisfied = YES;
    NSError* error = nil;

    NSMutableArray<NSError*>* dependencyFailures = nil;

    for (NSOperation* dependency in operation.dependencies)
    {
        if ([dependency isKindOfClass:[AKAOperation class]])
        {
            AKAOperation* akaOperation = (AKAOperation*)dependency;
            if (akaOperation.failed)
            {
                NSError* dependencyError = [AKAErrors errorForMultipleErrors:akaOperation.errors];
                NSString* description = [NSString stringWithFormat:@"Dependency %@ failed with error: %@", akaOperation, dependencyError.localizedDescription];
                if (!dependencyFailures)
                {
                    dependencyFailures = [NSMutableArray new];
                }
                [dependencyFailures addObject:[NSError errorWithDomain:[AKAOperationErrors errorDomain]
                                                                  code:AKAOperationErrorDependencyFailed
                                                              userInfo:
                                               @{ NSLocalizedDescriptionKey: description,
                                                  @"dependency": dependency,
                                                  NSUnderlyingErrorKey: dependencyError }]];
            }
        }
        if (dependency.cancelled)
        {
            NSString* description = [NSString stringWithFormat:@"Dependency %@ was cancelled", dependency];
            if (!dependencyFailures)
            {
                dependencyFailures = [NSMutableArray new];
            }
            [dependencyFailures addObject:[NSError errorWithDomain:[AKAOperationErrors errorDomain]
                                                              code:AKAOperationErrorDependencyFailed
                                                          userInfo:
                                           @{ NSLocalizedDescriptionKey: description,
                                              @"dependency": dependency }]];
        }
    }

    if (dependencyFailures.count > 0)
    {
        satisfied = NO;
        error = [AKAErrors errorForMultipleErrors:dependencyFailures];
    }

    completion(satisfied, error);
}

@end
