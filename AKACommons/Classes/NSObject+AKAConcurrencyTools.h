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
 * If called form the main thread, the block is executed right away
 * and otherwise dispatched to the main queue.
 *
 * @param block the block to execute.
 */
- (void)aka_performBlockInMainThreadOrQueue:(void(^)())block;

@end
