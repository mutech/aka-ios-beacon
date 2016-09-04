//
//  AKAOperationQueue.h
//  AKABeacon
//
//  Created by Michael Utech on 29.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
#import "AKAOperation.h"


@class AKAOperationQueue;

/**
 The delegate of an `AKAOperationQueue` can respond to `AKAOperation` lifecycle
 events by implementing these methods.

 In general, implementing `ALAOperationQueueDelegate` is not necessary; you would
 want to use an `AKAOperationObserver` instead. However, there are a couple of
 situations where using `AKAOperationQueueDelegate` can lead to simpler code.
 For example, `AKAGroupOperation` is the delegate of its own internal
 `AKAOperationQueue` and uses it to manage dependencies.
 */
@protocol AKAOperationQueueDelegate<NSObject>

@optional
- (void)operationQueue:(AKAOperationQueue*)operationQueue
      willAddOperation:(NSOperation*)operation;

@optional
- (void)operationQueue:(AKAOperationQueue*)operationQueue
    operationDidFinish:(NSOperation*)operation
            withErrors:(NSArray<NSError*>*)errors;

@end


/**
 `AKAOperationQueue` is an `NSOperationQueue` subclass that implements a large
 number of "extra features" related to the `AKAOperation` class:

 - Notifying a delegate of all operation completion
 - Extracting generated dependencies from operation conditions
 - Setting up dependencies to enforce mutual exclusivity
 */
@interface AKAOperationQueue : NSOperationQueue

@property(nonatomic) id<AKAOperationQueueDelegate> delegate;

@end
