//
//  AKAGroupOperation.h
//  AKABeacon
//
//  Created by Michael Utech on 29.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperation.h"
#import "AKAOperationQueue.h"

/**
 A subclass of `AKAOperation` that executes zero or more operations as part of its
 own execution. This class of operation is very useful for abstracting several
 smaller operations into a larger operation. As an example, the `GetEarthquakesOperation`
 is composed of both a `DownloadEarthquakesOperation` and a `ParseEarthquakesOperation`.

 Additionally, `AKAGroupOperation`s are useful if you establish a chain of dependencies,
 but part of the chain may "loop". For example, if you have an operation that
 requires the user to be authenticated, you may consider putting the "login"
 operation inside a group operation. That way, the "login" operation may produce
 subsequent operations (still within the outer `AKAGroupOperation`) that will all
 be executed before the rest of the operations in the initial chain of operations.
 */
@interface AKAGroupOperation : AKAOperation

- (nonnull instancetype)initWithOperations:(nullable NSArray<NSOperation*>*)operations;

- (void)addOperation:(nonnull NSOperation*)operation;

- (void)addOperations:(nullable NSArray<NSOperation*>*)operations;

@end

@interface AKAGroupOperation()

#pragma mark - Sub class support

@property(nonatomic, readonly) AKAOperationQueue* internalQueue;

/**
 * Sub classes can override this class method to provide a custom start operation.
 *
 * All group member operation will depend on the returned start operation.
 */
+ (nonnull AKAOperation*)createStartOperationForGroup:(nonnull AKAGroupOperation*)operation;

/**
 * Sub classes can override this class method to provide a custom finish operation.
 *
 * The returned finish operation will depend on all group member operations.
 */
+ (nonnull AKAOperation*)createFinishOperationForGroup:(nonnull AKAGroupOperation*)operation;

/**
 Called when a member operation finished. The default implementation does nothing. This can be overridden by sub classes as an alternative to adding observers to all member operations to monitor all finished operations.

 @param operation the finished operation
 @param errors    errors or nil if the operation succeeded.
 */
- (void)                operation:(NSOperation*__unused)operation
              didFinishWithErrors:(NSArray<NSError*>*__unused)errors;

@end
