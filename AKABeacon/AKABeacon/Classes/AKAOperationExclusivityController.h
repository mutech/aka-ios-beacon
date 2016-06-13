//
//  AKAOperationExclusivityController.h
//  AKABeacon
//
//  Created by Michael Utech on 11.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//


@import Foundation;

#import "AKAOperation.h"


@interface AKAOperationExclusivityController : NSObject

+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

+ (instancetype)  sharedInstance;

- (void)            addOperation:(AKAOperation*)operation
                    toCategories:(NSArray<NSString*>*)categories;


- (void)         removeOperation:(AKAOperation*)operation
                  fromCategories:(NSArray<NSString*>*)categories;

@end
