//
//  AKAGroupOperation.h
//  AKABeacon
//
//  Created by Michael Utech on 29.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperation.h"

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

+ (AKAOperation*)createFinishOperationForGroup:(AKAGroupOperation*)operation;

- (instancetype)initWithOperations:(NSArray<NSOperation*>*)operations;

- (void)addOperation:(NSOperation*)operation;

@end
