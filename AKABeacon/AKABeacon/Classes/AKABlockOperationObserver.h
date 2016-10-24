//
//  AKABlockOperationObserver.h
//  AKABeacon
//
//  Created by Michael Utech on 29.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
#import "AKAOperationObserver.h"
#import "AKAOperation.h"

@interface AKABlockOperationObserver : NSObject<AKAOperationObserver>

@property(nonatomic, readonly) void(^didStartBlock)(AKAOperation* operation);
@property(nonatomic, readonly) void(^didProduceOperationBlock)(AKAOperation* operation,NSOperation* producedOperation);
@property(nonatomic, readonly) void(^didUpdateProgressBlock)(AKAOperation* operation, CGFloat progressDifference, CGFloat workloadDifference);
@property(nonatomic, readonly) void(^didFinishBlock)(AKAOperation* operation, NSArray<NSError*>* errors);

- (instancetype)initWithDidStartBlock:(void(^)(AKAOperation*))didStartBlock
             didProduceOperationBlock:(void(^)(AKAOperation*, NSOperation*))didProduceOperationBlock
                       didFinishBlock:(void(^)(AKAOperation*, NSArray<NSError*>*))didFinishBlock;

- (instancetype)initWithDidStartBlock:(void (^)(AKAOperation *))didStartBlock
             didProduceOperationBlock:(void (^)(AKAOperation *, NSOperation *))didProduceOperationBlock
               didUpdateProgressBlock:(void (^)(AKAOperation *, CGFloat progressDifference, CGFloat workloadDifference))didUpdateProgressBlock
                       didFinishBlock:(void (^)(AKAOperation *, NSArray<NSError *> *))didFinishBlock;

+ (instancetype)didFinishBlockObserver:(void(^)(AKAOperation*, NSArray<NSError*>*))didFinishBlock;

@end
