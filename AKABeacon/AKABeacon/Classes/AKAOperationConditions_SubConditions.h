//
//  AKAOperationConditions_SubConditions.h
//  AKABeacon
//
//  Created by Michael Utech on 08.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperation.h"
#import "AKAOperationConditions.h"
#import "AKANullability.h"


@interface AKAOperationConditions()

@property(nonatomic, nonnull) NSMutableArray<AKAOperationCondition*>* conditions;

/**
 Adds the specified condition.

 @warn This should never be called directly if this condition is referenced from an operation. Use [operation addCondition] instead.

 @param condition the condition to add.
 */
- (void)addCondition:(nonnull AKAOperationCondition*)condition;

- (void)enumerateConditionsUsingBlock:(void(^_Nonnull)(AKAOperationCondition* _Nonnull condition,
                                               outreq_BOOL stop))block;

@end
