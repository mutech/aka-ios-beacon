//
//  AKATableViewCellCompositeControl.h
//  AKABeacon
//
//  Created by Michael Utech on 26.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATableViewCellCompositeControl.h"
#import "AKADynamicPlaceholderTableViewCell.h"
#import "AKACompositeControl_Internal.h"

@implementation AKATableViewCellCompositeControl

#pragma mark - Diagnostics

- (NSString *)debugDescriptionDetails
{
    NSString* result = [NSString stringWithFormat:@"cell@[%ld-%ld]: %@, configuration: { %@ }",
                        (long)self.indexPath.section, (long)self.indexPath.row,
                        @"-"/*self.view.description*/,
                        @"-"/*self.viewBinding.configuration.description*/];
    return result;
}

@end
