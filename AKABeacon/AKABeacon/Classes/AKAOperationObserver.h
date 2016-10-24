//
//  AKAOperationObserver.h
//  AKABeacon
//
//  Created by Michael Utech on 29.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

@class AKAOperation;

@protocol AKAOperationObserver <NSObject>

@optional
- (void)        operationDidStart:(AKAOperation*)operation;

@optional
- (void)                operation:(AKAOperation*)operation
              didProduceOperation:(NSOperation*)newOperation;

@optional
/**
 * Notifies the observer that either or both progress and workload have been updated.
 *
 * Please note that the specified values are not the absolute progress and workload values but the difference to their previous values to make it easier and safer for composite operations to calculate their own progress and workload changes based on progress made by their sub operations.
 *
 * @param operation the operation
 * @param progressDifference a value > -1.0 and <= 1.0 specifying the amount by which the progress has changed.
 * @param workloadDifference a value specifying the amount by which the workload has changed.
 */
- (void)                operation:(AKAOperation*)operation
                didUpdateProgress:(CGFloat)progressDifference
                         workload:(CGFloat)workloadDifference;

@optional
- (void)                operation:(AKAOperation*)operation
              didFinishWithErrors:(NSArray<NSError*>*)errors;

@end
