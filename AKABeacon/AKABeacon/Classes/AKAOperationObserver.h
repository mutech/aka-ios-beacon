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
- (void)operationDidStart:(AKAOperation*)operation;

@optional
- (void)operation:(AKAOperation*)operation didProduceOperation:(NSOperation*)newOperation;

@optional
- (void)operation:(AKAOperation*)operation didFinishWithErrors:(NSArray<NSError*>*)errors;

@end
