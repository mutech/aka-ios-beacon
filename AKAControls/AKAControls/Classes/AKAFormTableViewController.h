//
//  AKAFormTableViewController.h
//  AKAControls
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKAFormControl.h"
#import <AKACommons/AKATVDataSourceSpecification.h>

@class AKAReference;
@class AKATableViewCellCompositeControl;

@interface AKAFormTableViewController : UITableViewController<AKAControlDelegate>

@property(nonatomic) id model;
@property(nonatomic, readonly) AKAFormControl* formControl;
@property(nonatomic, readonly) AKATVDataSourceSpecification* defaultDataSource;

#pragma mark - Configuration

/**
 * Returns the data source specification for the specified key. The
 * default implementation delegates the message to the multiplexed
 * data source. This can be overridden to provide data sources on
 * demand. The implementation has to ensure that the data source
 * specification returned is defined in the multiplexed
 * data source for the same key.
 *
 * @param key the data source key
 * @param multiplexedDataSource the multiplexer containing the data source
 *
 * @return A data source specification
 */
- (AKATVDataSourceSpecification*)dataSourceForKey:(NSString*)key
                                    inMultiplexer:(AKATVMultiplexedDataSource*)multiplexedDataSource;

#pragma mark - Accessing tagged controls

/**
 * Returns an array containing all row controls which are
 * tagged with the specified value.
 *
 * @param tag a tag value
 *
 * @return An array containing all row controls which are tagged with the specified value.
 */
- (NSArray*)rowControlsTaggedWith:(NSString*)tag;

#pragma mark - Hiding and Unhinding Rows

/**
 * Hides all rows bound to controls contained in the specified rowControls array.
 *
 * @param rowControls an array containing row controls
 * @param rowAnimation the animation to be used
 */
- (void)hideRowControls:(NSArray*)rowControls
       withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 * Unhides all rows bound to controls contained in the specified rowControls array.
 *
 * @param rowControls an array containing row controls
 * @param rowAnimation the animation to use
 */
- (void)unhideRowControls:(NSArray*)rowControls
         withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 * Updates data sources and table views for changes in the
 * dynamic table view cell placeholder control's data source.
 * This will delete all rows previously shown for the dynamic
 * placeholder cell and insert rows for its current content.
 *
 * @param placeholder the place holder control
 *
 * @return YES if the dynamic placeholder control was mapped
 *      in the multiplexed data source (e.g. not hidden).
 */
- (BOOL)updateDynamicRowsForPlaceholderControl:(AKATableViewCellCompositeControl*)placeholder;

@end
