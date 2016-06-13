//
//  AKAOperationDelegate.h
//  AKABeacon
//
//  Created by Michael Utech on 08.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKAOperation;

/**
 Delegate for AKAOperations.
 
 @note AKAOperations strongly references delegates when they are used as observers.
 */
@protocol AKAOperationDelegate <NSObject>

@optional
- (void)     operationDidStart:(nonnull AKAOperation*)operation;

@optional
- (void)            operation:(nonnull AKAOperation*)operation
          didProduceOperation:(nonnull NSOperation*)newOperation;

@optional
- (void)            operation:(nonnull AKAOperation*)operation
          didFinishWithErrors:(nullable NSArray<NSError*>*)errors;

@end
