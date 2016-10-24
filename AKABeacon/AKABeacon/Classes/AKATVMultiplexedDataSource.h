//
//  AKAMultiplexedTableViewDataSourceBase.h
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKANullability.h"
#import "AKATVCoordinateMappingProtocol.h"
#import "AKATVDataSourceSpecification.h"

#pragma mark - AKAMultiplexedTableViewDataSourceBase
#pragma mark -

/**
 Provides a UITableViewDataSource and UITableViewDelegate by multiplexing one or more data sources.
 
 The typical use case is to start with a UITableViewController for a static table view and make it more dynamic by adding rows from other data sources (or data source/delegate pairs).

 The multiplexer dispatches delegate calls to the source delegate (if possible) and maps coordinates such that is transparent for the source delegate, that the rows or sections are actually somewhere else. Table view parameters are proxied when passed to delegate methods, so that the delegate can call table view methods with its own coordinate system.

 @remarks Following are some notes that you should be aware of when using multiplexers:

 @note A multiplexed data source can only serve the table view for which it was created.
 
 @note The multiplexer will restore the original table view data source and delegate when it's released.

 @note This mechanism works fine in many cases, but fails for some non trivial delegates. It often helps to enable verbose logging on delegate calls to identify problems: @code [AKATVMultiplexer setLevel:DDLogLevelAll forClass:[AKATVMultiplexedDataSource class]]@endcode

 @note A good example for how to use the multiplexer are dynamic place holder cells used in AKAFormTableViewController's (in the AKAControls binding library). If this covers your requirements you should use it in favor to directly using the multiplexer.
 */
@interface AKATVMultiplexedDataSource: NSObject<UITableViewDataSource, UITableViewDelegate, AKATVDataSourceSpecificationDelegate>

#pragma mark - Initialization

/**
 Creates a new instance that acts as proxy for the dataSource and delegate of the specified table view (replacing them). The original data source is available at the specified dataSourceKey.

 @note that the tableView is not reloaded or updated, because its contents does not change, the proxy is transparent until its configuration is modified by inserting, moving or removing rows or sections.

 @param tableView       the table view in which to install the new instance
 @param dataSourceKey   the key for which the original dataSource will be registered.
 @return the new instance
 */
+ (opt_instancetype)     proxyDataSourceAndDelegateForKey:(req_NSString)dataSourceKey
                                              inTableView:(req_UITableView)tableView;

/**
 Creates a new instance that acts as proxy for the dataSource and delegate of the specified table view (replacing them). The original data source is available at the specified dataSourceKey.
 The second dataSource and delegate are registered and the corresponding sections are added following the sections of the primary data source.
 @note the tableView will be reloaded after the sections of the second data source have been added. You can manually add data sources and insert their sections if you don't want reloadData to be called.

 @param dataSourceKey the key for which the original dataSource will be registered.
 @param tableView the table view in which to install the new instance
 @param dataSource the key identifying the table views original data source
 @param delegate the delegate for the second data source
 @param additionalDataSourceKey the key identifying the second data source
 @return the new instance
 */
+ (opt_instancetype)     proxyDataSourceAndDelegateForKey:(req_NSString)dataSourceKey
                                              inTableView:(req_UITableView)tableView
                                      andAppendDataSource:(req_UITableViewDataSource)dataSource
                                             withDelegate:(opt_UITableViewDelegate)delegate
                                                   forKey:(req_NSString)additionalDataSourceKey;

#pragma mark - Configuration

/**
 The table view for which this instance was created.
 */
@property(nonatomic, readonly, weak) opt_UITableView tableView;

/**
 The name of the default data source referencing the tableView's original data source and delegate.
 */
@property(nonatomic, readonly) req_NSString defaultDataSourceKey;


#pragma mark - Managing Data Sources and associated Delegates

/**
 Registers the specified @c dataSource for the specified @c key and associates the specified @c delegate with it.
 
 @note Both delegate and dataSource are weakly referenced. You have to make sure that they are retained during the life time of this instance.
 @warning Attempts to register a data source with an already existing key result in  undefined behaviour.

 @param dataSource the data source to add
 @param delegate the delegate to use for rows and sections using the data source
 @param key the key identifying the data source
 */
- (nonnull AKATVDataSourceSpecification*)addDataSource:(req_UITableViewDataSource)dataSource
                                          withDelegate:(opt_UITableViewDelegate)delegate
                                                forKey:(req_NSString)key;

/**
 Registers the specified @c dataSource which also acts as delegate for the specified @c key.

 @note The dataSource is weakly referenced. You have to make sure that it is retained during the life time of this instance.

 @warning Attempts to register a data source with an already existing key result in undefined behaviour.

 @param dataSource the data source and delegae to add
 @param key the key identifying the data source
 */
- (nonnull AKATVDataSourceSpecification*)addDataSourceAndDelegate:(nonnull id<UITableViewDataSource, UITableViewDelegate>)dataSource
                                               forKey:(req_NSString)key;

/**
 Returns the data source information for the specified key.

 @param key the key

 @return the data source associated with the specified key of nil if no data source information is associated with the key.
 */
- (nullable AKATVDataSourceSpecification*)dataSourceForKey:(req_NSString)key;

#pragma mark - Batch Table View Updates

- (void)beginUpdates;

- (void)endUpdates;

#pragma mark - Adding and Removing Sections
/// @name Adding and Removing Sections

/**
 Takes the specified @c numberOfSections from the specified @c dataSource starting at the specified @c sourceSectionIndex and inserts them at the specified @c sectionIndex in this data source.

 @param dataSource the data source providing the sections
 @param sourceSectionIndex the section index in the source data source
 @param numberOfSections the number of sections to insert
 @param targetSectionIndex the section index in this data source at which to insert the specified sections
 @param useRowsFromSource whether the inserted sections should contain the original rows (YES) or should be left empty (NO)
 */
- (void)insertSectionsFromDataSource:(NSString*__nonnull)dataSourceKey
                  sourceSectionIndex:(NSUInteger)sourceSectionIndex
                               count:(NSUInteger)numberOfSections
                      atSectionIndex:(NSUInteger)targetSectionIndex
                   useRowsFromSource:(BOOL)useRowsFromSource
                    withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 Removes the specified numberOfSections starting at the specified sectionIndex.

 @param numberOfSections the number of sections to remove
 @param sectionIndex the index of the first section to remove
 @param rowAnimation The row animation to use if update is YES.
 */
- (void)        remove:(NSUInteger)numberOfSections
       sectionsAtIndex:(NSUInteger)sectionIndex
      withRowAnimation:(UITableViewRowAnimation)rowAnimation;


#pragma mark - Adding and Removing Rows to/from Sections
/// @name Adding and Removing Rows to or from Sections

/**
 * Takes the specified numberOfRows from the specified dataSource starting
 * at the specified sourceIndexPath and inserts them at the position
 * specified by indexPath.
 *
 * @note The source section has to contain a sufficient amount of rows
 * and the target indexPath has to reference a valid insertion point.
 *
 * @note If a tableView is specified and update is YES, the table view will be
 *      updated using the specified row animations. You have to call begin- and endUpdate.
 *
 * @param dataSource the data source providing the rows
 * @param sourceIndexPath the indexPath specifying the first row to insert
 * @param numberOfRows the number of rows to insert
 * @param indexPath the location where the rows should be inserted.
 * @param rowAnimation The row animation to use if update is YES.
 */
- (void)insertRowsFromDataSource:(NSString*__nonnull)dataSourceKey
                 sourceIndexPath:(NSIndexPath*__nonnull)sourceIndexPath
                           count:(NSUInteger)numberOfRows
                     atIndexPath:(NSIndexPath*__nonnull)indexPath
                withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 * Removes (up to) the specified numberOfRows from the section and row of
 * the specified indexPath and returns the number of rows which could not be
 * removed (due to the section not containing that many rows at and following
 * the indexPath)
 *
 * @note If a tableView is specified and update is YES, the table view will be
 *      updated using the specified row animations. You have to call begin- and endUpdate.
 *
 * @param numberOfRows the number of rows to remove
 * @param indexPath the index path specifying the first row to remove
 * @param rowAnimation The row animation to use if update is YES.
 *
 * @return 0 if the specified number of rows has been removed or the number of
 *      rows which have not been removed.
 */
- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
       rowsFromIndexPath:(NSIndexPath*__nonnull)indexPath
        withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 * Removes the row originating from the specified data source at the specified index path
 * temporarily from the table view. The excluded row will leave a marker and can be included
 * at the same logical position. Subsequent insertions or removals will at preceeding
 * locations will affect an excluded row as if it was still there.
 *
 * @param sourceIndexPath the rows index path in its original data source
 * @param dataSource the data source from which the row orignated
 * @param rowAnimation the animation used for removal from the table view
 *
 * @return YES if the row was found and could be excluded
 */
- (BOOL)excludeRowFromSourceIndexPath:(NSIndexPath*__nonnull)sourceIndexPath
                         inDataSource:(AKATVDataSourceSpecification*__nonnull)dataSource
                     withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 * Undoes the effect of a previous exclusion of the row specified by its data source and
 * source index path.
 *
 * @param sourceIndexPath the rows index path in its original data source
 * @param dataSource the data source from which the row orignated
 * @param rowAnimation the animation used for insertion to the table view
 *
 * @return YES if the row was found, previously excluded and could be included
 */
- (BOOL)includeRowFromSourceIndexPath:(NSIndexPath*__nonnull)sourceIndexPath
                         inDataSource:(AKATVDataSourceSpecification*__nonnull)dataSource
                     withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 * Experimental: determines if the specified row has been excluded.
 */
- (BOOL)isRowExcludedAtSourceIndexPath:(NSIndexPath*)sourceIndexPath
                          inDataSource:(AKATVDataSourceSpecification*)dataSource;

#pragma mark - Updating rows

- (void)reloadRowsAtIndexPaths:(NSArray*__nonnull)indexPaths
              withRowAnimation:(UITableViewRowAnimation)rowAnimation;

#pragma mark - Moving Rows

- (void)moveRowAtIndex:(NSInteger)rowIndex
             inSection:(NSInteger)sectionIndex
            toRowIndex:(NSInteger)targetIndex;

- (void)moveRowAtIndexPath:(NSIndexPath*__nonnull)indexPath
               toIndexPath:(NSIndexPath*__nonnull)targetIndexPath;

#pragma mark - Source Coordiante Changes

- (void)          dataSourceWithKey:(req_NSString)key
             insertedRowAtIndexPath:(req_NSIndexPath)indexPath;
- (void)          dataSourceWithKey:(req_NSString)key
              removedRowAtIndexPath:(req_NSIndexPath)indexPath;
- (void)          dataSourceWithKey:(req_NSString)key
              movedRowFromIndexPath:(req_NSIndexPath)fromIndexPath
                        toIndexPath:(req_NSIndexPath)toIndexPath;

/**
 * This announces to the tableview that the row moved as specified but does not make
 * any changes to the index path mapping of the multiplexer. Update batches are however
 * aware of the moved row and will correct index paths accordingly.
 *
 * @param indexPath the previous index path of the moved row.
 * @param targetIndexPath the new index path of the moved row.
 */
- (void)rowAtIndexPath:(NSIndexPath*__nonnull)indexPath
    didMoveToIndexPath:(NSIndexPath*__nonnull)targetIndexPath;

#pragma mark - Resolve Source Data Sources, Delegates and Coordinates

- (BOOL)resolveIndexPath:(out NSIndexPath*__strong __nullable* __nullable)indexPathStorage
      forSourceIndexPath:(NSIndexPath* __nonnull)sourceIndexPath
            inDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource;

- (BOOL)resolveSection:(out NSInteger* __nullable)sectionStorage
      forSourceSection:(NSInteger)sourceSection
          inDataSource:(AKATVDataSourceSpecification* __nonnull)dataSource;

- (BOOL)resolveAKADataSource:(out AKATVDataSourceSpecification*__autoreleasing __nullable* __nullable)dataSourceStorage
             sourceIndexPath:(out NSIndexPath*__autoreleasing __nullable* __nullable)indexPathStorage
                forIndexPath:(NSIndexPath* __nonnull)indexPath;

- (BOOL)resolveAKADataSource:(out AKATVDataSourceSpecification*__autoreleasing __nullable* __nullable)dataSourceStorage
          sourceSectionIndex:(out NSInteger* __nullable)sectionIndexStorage
             forSectionIndex:(NSInteger)sectionIndex;

#pragma mark - UITableViewDelegate Support

/**
 * Inspects the specified delegate instance and identifies all methods conforming to the
 * UITableViewDelegate that have been overridden by the delegates class relative to the specified
 * type. Does nothing if the delegates class is not a subclass of the specified type or if
 * it's class is the specified type.
 *
 * For all registered methods, the multiplexer will not dispatch table view delegate messages to
 * the specified delegate without performing section or indexPath resolution and it will pass the
 * original table view instead of proxy. Consequently, method implementations have to be aware of
 * the multiplexer and it's implications.
 *
 * @param type a base class of the specified delegates class
 * @param delegate the delegate to inspect.
 */
- (void)registerTableViewDelegateOverridesTo:(req_Class)type
                                fromDelegate:(id<UITableViewDelegate>_Nonnull)delegate;

/**
 * Makes this data source respond to all selectors to which the specified delegate
 * responds. The delegate implementation will resolve the delegate actually implementing
 * the message (using the delegate associated with a data source that provides
 * the row or section subject to the delegate message.
 *
 * @param delegate the delegate used to identify which messages to implement.
 */
- (void)addTableViewDelegateSelectorsRespondedBy:(id<UITableViewDelegate>__nullable)delegate;

/**
 * Makes this data source respond to the specified selector. The delegate implementation will
 * resolve the delegate actually implementing the message (using the delegate associated with
 * a data source that provides the row or section subject to the delegate message.
 *
 * @note that if the class implements the corresponding method, this will have no effect.
 *
 * @param selector one of the methods specified in the UITableViewDelegate protocol
 */
- (void)addTableViewDelegateSelector:(SEL __nonnull)selector;

/**
 * Keeps this data source from responding to the specified selector as part of the automatic
 * delegate proxy implementation.
 *
 * @note that if the class implements the corresponding method this will have not effect.
 *
 * @param selector one of the methods specified in the UITableViewDelegate protocol
 */
- (void)removeTableViewDelegateSelector:(SEL __nonnull)selector;

@end
