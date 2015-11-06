//
//  AKADynamicPlaceholderTableViewCellCompositeControl.h
//  AKABeacon
//
//  Created by Michael Utech on 05.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKAProperty;

#import "AKATableViewCellCompositeControl.h"

#import "AKADynamicPlaceholderTableViewCell.h"

@interface AKADynamicPlaceholderTableViewCellCompositeControl : AKATableViewCellCompositeControl

@property(nonatomic, readonly, weak) AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding* collectionBinding;

@end


// HACK: Letting the control implement the table view data source is quite dirty but very convenient
// because it can then create both the views (dynamic cells) and the member controls and bindings.
// This would be difficult to do otherwise. Until I find a cleaner solution, this will hopefully
// work.
@interface AKADynamicPlaceholderTableViewCellCompositeControl(UITableViewDataSourceAndDelegate) <
    UITableViewDataSource,
    UITableViewDelegate
>
@end