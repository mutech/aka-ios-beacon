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

/**
 * Key path refering to a table view data source providing the dynamic cells.
 */
@property(nonatomic) IBInspectable NSString* dataSourceKeyPath;

/**
 * Key path refering to a table view delegate to use for dynamic cells.
 */
@property(nonatomic) IBInspectable NSString* delegateKeyPath;

/**
 * The index of the source section from which to include rows. If not
 * specified, the first section will be used.
 */
@property(nonatomic) IBInspectable NSUInteger sectionIndex;

/**
 * The index of the first row to include. If not specified, the section's
 * first row will be used.
 */
@property(nonatomic) IBInspectable NSUInteger rowIndex;

/**
 * The number of rows to include, if 0, all rows from the specified rowIndex
 * until the last row in the specified section will be included.
 */
@property(nonatomic) IBInspectable NSUInteger numberOfRows;

#pragma mark - Content Rendering

- (void)renderItem:(id)item;

@end


@interface AKADynamicPlaceholderTableViewCellBinding: AKATableViewCellBinding
@end


@interface AKADynamicPlaceholderTableViewCellBindingConfiguraton: AKATableViewCellBindingConfiguration

/**
 * Key path refering to a table view data source providing the dynamic cells.
 */
@property(nonatomic) NSString* dataSourceKeyPath;

/**
 * Key path refering to a table view delegate to use for dynamic cells.
 */
@property(nonatomic) NSString* delegateKeyPath;

/**
 * The index of the source section from which to include rows. Defaults to the
 * first section (index 0).
 */
@property(nonatomic) NSUInteger sectionIndex;

/**
 * The index of the first row to include. Defaults to the first row (index 0).
 */
@property(nonatomic) NSUInteger rowIndex;

/**
 * The number of rows to include, if 0, all rows from the specified rowIndex
 * until the last row in the specified section will be included. Defaults to
 * all rows (count 0)
 */
@property(nonatomic) NSUInteger numberOfRows;

@end