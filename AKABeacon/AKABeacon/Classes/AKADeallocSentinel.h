//
//  AKADeallocSentinel.h
//  AKABeacon
//
//  Created by Michael Utech on 21.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKANullability.h"

@interface AKADeallocSentinel: NSObject

+ (req_instancetype)observeObjectLifeCycle:(req_id)object
                              deallocation:(void(^_Nonnull)())deallocNotificationBlock;


- (void)cancel;

@end