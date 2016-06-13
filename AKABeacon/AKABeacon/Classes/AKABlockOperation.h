//
//  AKABlockOperation.h
//  AKABeacon
//
//  Created by Michael Utech on 11.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperation.h"

@interface AKABlockOperation : AKAOperation

- (req_instancetype)initWithBlock:(void(^_Nonnull)(void(^_Nonnull finish)()))block;

- (req_instancetype)initWithMainQueueBlock:(void(^_Nonnull)())mainQueueBlock;

@end
