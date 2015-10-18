//
//  AKADynamicPlaceholderTableViewCell.h
//  AKAControls
//
//  Created by Michael Utech on 29.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKATableViewCell.h"


IB_DESIGNABLE
/**
 * Acts as a placeholder for table view cells originating from an additional
 * dynamic table view data source. To function properly, the root of the controls
 * data context has to be an instance of AKAFormTableViewController, which provides
 * the supporting methods to replace the placeholder with the cells specified in
 * the binding configuration.
 *
 * @note The placeholder cell is not excluded even the specified cells are
 * included in the target table view. To hide the placeholder, configure it to
 * have an effective height of zero (using autolayout or other means).
 *
 * @note Hiding the placeholder using the AKAFormTableViewController will also
 * hide (exclude) the dynamically inserted cells.
 */
@interface AKADynamicPlaceholderTableViewCell : AKATableViewCell

@property(nonatomic) IBInspectable NSString* placeholderBinding;

#pragma mark - Content Rendering

- (void)renderItem:(id)item;

@end


#import "AKABinding.h"

@interface AKABinding_AKADynamicPlaceholderTableViewCell_dataSourceBinding: AKABinding

@property(nonatomic) id<UITableViewDataSource>  placeholderDataSource;

@property(nonatomic) id<UITableViewDelegate>    placeholderDelegate;

@property(nonatomic) NSNumber*                  dataSourceSectionIndex;

@property(nonatomic) NSNumber*                  dataSourceRowIndex;

@property(nonatomic) NSNumber*                  dataSourceNumberOfRows;

@end
