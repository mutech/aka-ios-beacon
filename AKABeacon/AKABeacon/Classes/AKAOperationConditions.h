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

@end
