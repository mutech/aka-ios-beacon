//
//  AKAOperationConditions.h
//  AKABeacon
//
//  Created by Michael Utech on 08.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperationCondition.h"

@interface AKAOperationConditions: AKAOperationCondition

- (nonnull instancetype)initWithConditions:(nonnull NSArray<AKAOperationCondition*>*)conditions;

/**
 Determines whether operations using conditions of this type are exclusive, in the sense that only one such operation can be executed at any time.

 @return YES if operations using instances of this condition type have to be executed mutually exclusive.
 */
+ (BOOL)isMutuallyExclusive;

@end
