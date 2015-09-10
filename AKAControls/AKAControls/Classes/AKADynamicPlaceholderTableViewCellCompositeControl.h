//
//  AKADynamicPlaceholderTableViewCellCompositeControl.h
//  AKAControls
//
//  Created by Michael Utech on 05.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKATableViewCellCompositeControl.h"

@interface AKADynamicPlaceholderTableViewCellCompositeControl : AKATableViewCellCompositeControl

@property(nonatomic, strong) NSArray* actualItems;
@property(nonatomic) NSUInteger actualNumberOfRows;

@end

@interface AKADynamicPlaceholderTableViewCellCompositeControl(Internal)

@end