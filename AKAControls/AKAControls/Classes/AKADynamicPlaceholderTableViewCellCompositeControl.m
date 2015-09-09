//
//  AKADynamicPlaceholderTableViewCellCompositeControl.m
//  AKAControls
//
//  Created by Michael Utech on 05.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKADynamicPlaceholderTableViewCellCompositeControl.h"

@implementation AKADynamicPlaceholderTableViewCellCompositeControl

- (NSUInteger)autoAddControlsForBoundView
{
    // Do not automatically add controls in the cells contentView hierarchy, because
    // this is only a placeholder (prototype) cell. Adding controlls will be done
    // (dynamically) when the placeholder is connected to its data source.
    return 0;
}

@end
