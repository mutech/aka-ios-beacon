//
//  AKADynamicPlaceholderTableViewCell.h
//  AKAControls
//
//  Created by Michael Utech on 29.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKATVMultiplexedDataSource;

#import "AKATableViewCell.h"
#import "AKACollectionControlViewBinding.h"

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

#pragma mark - Interface Builder Properties

@property(nonatomic) IBInspectable NSString* collectionBinding;

#pragma mark - Content Rendering

- (void)renderItem:(id)item;

@end


#import "AKABinding.h"

@interface AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding: AKACollectionControlViewBinding

#pragma mark - Convenience

@property(nonatomic, readonly) AKADynamicPlaceholderTableViewCell* placeholderCell;

#pragma mark - Configuration

@property(nonatomic) id<UITableViewDataSource>  placeholderDataSource;

@property(nonatomic) id<UITableViewDelegate>    placeholderDelegate;

@property(nonatomic) NSNumber*                  dataSourceSectionIndex;

@property(nonatomic) NSNumber*                  dataSourceRowIndex;

@property(nonatomic) NSNumber*                  dataSourceNumberOfRows;

#pragma mark - Configuration provided by controls

#pragma mark - Configuration

/**
 * The multipled data source managing insertion and deletion of dynamic rows
 */
@property(nonatomic, weak) AKATVMultiplexedDataSource*   multiplexer;

/**
 * The key of the data source specification providing dynamic rows for the placeholder. The key
 * is assigned at the time when the placehoder control is added to its container. It identifies
 * the data source specification in the scope of the multiplexer.
 */
@property(nonatomic)       NSString*                     multiplexedDataSourceKey;

/**
 * The data source specification providing dynamic rows for the placeholder.
 */
@property(nonatomic, weak) AKATVDataSourceSpecification* multiplexedDataSourceSpecification;

/**
 * The data source specification of the data source which provided the placeholder cell. This is
 * required to identify the target location where dynamic rows should be inserted.
 */
@property(nonatomic, weak) AKATVDataSourceSpecification* placeholderOriginDataSourceSpecification;

/**
 * The index path of the placeholder cell in the placeholderOriginDataSourceSpecification
 */
@property(nonatomic)       NSIndexPath*                  placeholderIndexPath;

@end
