//
//  AKADynamicPlaceholderTableViewCellCompositeControl.h
//  AKAControls
//
//  Created by Michael Utech on 05.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKAProperty;

#import "AKATableViewCellCompositeControl.h"


// TODO: create binding hierarchy for collection view bindings
@interface AKATableViewCellCollectionBinding: AKAViewBinding

@property(nonatomic) id<UITableViewDataSource>          tableViewDataSource;
@property(nonatomic) id<UITableViewDelegate>            tableViewDelegate;
@property(nonatomic) NSArray*                           data;
@property(nonatomic) NSInteger                          rowIndex;
@property(nonatomic) NSInteger                          sectionIndex;

@end


@interface AKADynamicPlaceholderTableViewCellCompositeControl : AKATableViewCellCompositeControl

@property(nonatomic, strong) NSArray*                   actualItems;
@property(nonatomic) NSUInteger                         actualNumberOfRows;

@property(nonatomic) AKATableViewCellCollectionBinding* collectionBinding;

@end


@interface AKADynamicPlaceholderTableViewCellCompositeControl(Internal)

@end


