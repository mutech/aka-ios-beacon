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

@property(nonatomic, readonly) void(^didStartBlock)(AKAOperation*);
@property(nonatomic, readonly) void(^didProduceOperationBlock)(AKAOperation*, NSOperation*);
@property(nonatomic, readonly) void(^didFinishBlock)(AKAOperation*, NSArray<NSError*>*);

- (instancetype)initWithDidStartBlock:(void(^)(AKAOperation*))didStartBlock
             didProduceOperationBlock:(void(^)(AKAOperation*, NSOperation*))didProduceOperationBlock
                       didFinishBlock:(void(^)(AKAOperation*, NSArray<NSError*>*))didFinishBlock;

+ (instancetype)didFinishBlockObserver:(void(^)(AKAOperation*, NSArray<NSError*>*))didFinishBlock;

@end
