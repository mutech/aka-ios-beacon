//
//  NSObject+ConcurrencyTools.h
//  proReport
//
//  Created by Michael Utech on 10.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AKAConcurrencyTools)

/**
 * Executes the block as early as possible in the main thread (or
 * dispatches it in the main queue). If the calling code is execute in
 * the main thread, the block will be executed immediately. Otherwise it
 * will be dispatched asynchronuously in the main queue.
 *
 * @param block the block to execut.
 */
- (void)performBlockInMainThreadOrQueue:(void(^)())block;

@end
