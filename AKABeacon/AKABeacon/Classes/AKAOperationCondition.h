//
//  AKAOperationCondition.h
//  AKABeacon
//
//  Created by Michael Utech on 08.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

@class AKAOperation;


@interface AKAOperationCondition: NSObject

+ (BOOL)isMutuallyExclusive;

- (void)evaluateForOperation:(nonnull AKAOperation*)operation
                  completion:(void(^_Nonnull)(BOOL satisfied, NSError* _Nullable error))completion;

/**
 If the condition supports it, this method will create a dependency for the specified operation that is intended to ensure that the condition will be satisfied.
 
 For example, such a dependency could ask the user for a confirmation of an action.

 The default implementation returns nil.

 @param operation The operation for which a dependency should be provided.

 @return An operation ensuring that the condition is satisfied or nil if the condition does not support providing such a dependency operation.
 */
- (nullable NSOperation*)dependencyForOperation:(nonnull NSOperation* __unused)operation;

@end


@interface AKAKVOOperationCondition: AKAOperationCondition

- (nonnull instancetype)initWithTarget:(nonnull NSObject*)target
                               keyPath:(nonnull NSString*)keyPath
                             predicate:(nonnull NSPredicate*)predicate
           dependencyForOperationBlock:(NSOperation*_Nullable(^_Nullable)(NSOperation*_Nonnull))dependencyForOperationBlock;

- (nonnull instancetype)initWithTarget:(nonnull NSObject*)target
                               keyPath:(nonnull NSString*)keyPath
                        predicateBlock:(BOOL(^_Nonnull)(id _Nullable value))predicateBlock
           dependencyForOperationBlock:(NSOperation*_Nullable(^_Nullable)(NSOperation*_Nonnull))dependencyForOperationBlock;

@end
