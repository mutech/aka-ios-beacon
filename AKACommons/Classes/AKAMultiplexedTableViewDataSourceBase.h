//
//  AKAMultiplexedTableViewDataSourceBase.h
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AKATVCoordinateMappingProtocol.h"
@class AKATVDataSource;

#pragma mark - AKAMultiplexedTableViewDataSourceBase
#pragma mark -

/**
 * Base class for multiplexed table view data sources which derive their sections and
 * rows from other data sources.
 *
 * This base class provides the interface for implementing multiplexed data sources
 * to map source rows and sections to the resulting structure and implements the data source
 * protocol using this mapping.
 *
 * Source data sources have to be registered and (should be) associated with their corresponding
 * delegates. This class provides a proxy for delegates that implements all delegate methods
 * that at least one of the registered delegates respond to. For each call to a delegate method,
 * the multiplexer uses the row or section coordinates to forward the delegate call to the
 * delegate associated with the data source providing the row or section.
 *
 * @note that in cases where one source delegate responds to a delegate method while another doesn't,
 *      you will have to either provide your own delegate implementation or overwrite the problematic
 *      methods and handle these cases manually.
 *
 * @warning Source delegate methods receive the coordinates (index paths and section indexes) of the
 *      table view (which equal those of the multiplexing data source) and not those of the data
 *      source. If a delegate method implementation needs the coordinates for its data source
 *      you will have to write a custom delegate (subclass the multiplexer or use your own delegate
 *      instead of the automatic proxy implementation of the multiplexer.
 */
@interface AKAMultiplexedTableViewDataSourceBase: NSObject<
    UITableViewDataSource,
    UITableViewDelegate
>

#pragma mark - Initialization

/**
 * Creates a new instance that acts as proxy for the dataSource and
 * delegate of the specified table view (replacing them). The original
 * data source is available at the specified dataSourceKey.
 *
 * @note that the tableView is not reloaded or updated, because its
 *      contents does not change.
 *
 * @param tableView the table view in which to install the new instance
 * @param dataSourceKey the key for which the original dataSource will be registered.
 * @return the new instance
 */
+ (nullable instancetype)proxyDataSourceAndDelegateForKey:(NSString*__nonnull)dataSourceKey
                                             inTableView:(UITableView*__nonnull)tableView;

/**
 * Creates a new instance that acts as proxy for the dataSource and
 * delegate of the specified table view (replacing them). The original
 * data source is available at the specified dataSourceKey.
 *
 * The second dataSource and delegate are registered and the corresponding
 * sections are added following the sections of the primary data source.
 *
 * @note the tableView will be reloaded after the sections of the second
 *      data source have been added. You can manually add data sources
 *      and insert their sections if you don't want reloadData to be
 *      called.
 *
 * @param dataSourceKey the key for which the original dataSource will be registered.
 * @param tableView the table view in which to install the new instance
 * @param dataSource the key identifying the table views original data source
 * @param delegate the delegate for the second data source
 * @param additionalDataSourceKey the key identifying the second data source
 *
 * @return the new instance
 */
+ (nullable instancetype)proxyDataSourceAndDelegateForKey:(NSString* __nonnull)dataSourceKey
                                              inTableView:(UITableView* __nonnull)tableView                                  andAppendDataSource:(id<UITableViewDataSource>__nonnull)dataSource
                                             withDelegate:(id<UITableViewDelegate>__nullable)delegate
                                                   forKey:(NSString*__nonnull)additionalDataSourceKey;

#pragma mark - Managing Data Sources and associated Delegates

/**
 * Registers the specified @c dataSource for the specified @c key and associates
 * the specified @c delegate with it.
 *
 * @note Both delegate and dataSource are weakly referenced. You have to make sure that they are retained during the life time of this instance.
 *
 * @warning Attempts to register a data source with an already existing key result in
 *      undefined behaviour.
 *
 * @param dataSource the data source to add
 * @param delegate the delegate to use for rows and sections using the data source
 * @param key the key identifying the data source
 */
- (nonnull AKATVDataSource*)addDataSource:(id<UITableViewDataSource>__nonnull)dataSource
                             withDelegate:(id<UITableViewDelegate>__nullable)delegate
                                   forKey:(NSString*__nonnull)key;

/**
 * Registers the specified @c dataSource which also acts as delegate 
 * for the specified @c key.
 *
 * @note The dataSource is weakly referenced. You have to make sure that it is retained during the life time of this instance.
 *
 * @warning Attempts to register a data source with an already existing key result in
 *      undefined behaviour.
 *
 * @param dataSource the data source and delegae to add
 * @param key the key identifying the data source
 */
- (AKATVDataSource*__nonnull)addDataSourceAndDelegate:(id<UITableViewDataSource, UITableViewDelegate>__nonnull)dataSource
                                               forKey:(NSString*__nonnull)key;

/**
 * Returns the data source information for the specified key.
 *
 * @param key the key
 *
 * @return the data source associated with the specified key of nil if no data source information
 *      is associated with the key.
 */
- (AKATVDataSource*__nullable)dataSourceForKey:(NSString*__nonnull)key;

#pragma mark - Adding and Removing Sections
/// @name Adding and Removing Sections

/**
 * Takes the specified @c numberOfSections from the specified @c dataSource
 * starting at the specified @c sourceSectionIndex and inserts them
 * at the specified @c sectionIndex in this data source.
 *
 * @note If a tableView is specified, the table view will be updated using
 *      automatic row animations. You have to call UITableView::beginUpdate and UITableView::endUpdate.
 *      If you do not want to update the table view, use the version of
 *      this method that let's you specify whether to update and which
 *      animation to use.
 *
 * @note It is your responsibility to ensure that rows for which a data source returns
 *      the same instance of a cell (static table views) are not used in more than one
 *      place. (TODO: verify if this is really a problem).
 *
 * @param dataSource the data source providing the sections
 * @param sourceSectionIndex the section index in the source data source
 * @param numberOfSections the number of sections to insert
 * @param targetSectionIndex the section index in this data source at which to insert the specified sections
 * @param useRowsFromSource whether the inserted sections should contain the original rows (YES) or should be left empty (NO)
 * @param tableView the table view which is passed to data sources in queries and
 *          which will be updated.
 */
- (void)insertSectionsFromDataSource:(NSString*__nonnull)dataSourceKey
                  sourceSectionIndex:(NSUInteger)sourceSectionIndex
                               count:(NSUInteger)numberOfSections
                      atSectionIndex:(NSUInteger)targetSectionIndex
                   useRowsFromSource:(BOOL)useRowsFromSource
                           tableView:(UITableView*__nullable)tableView;

/**
 * Takes the specified @c numberOfSections from the specified @c dataSource
 * starting at the specified @c sourceSectionIndex and inserts them
 * at the specified @c sectionIndex in this data source.
 *
 * @note If a tableView is specified and @c update is YES, the table view will be
 *      updated using the specified row animations. You have to call UITableView::beginUpdate and UITableView::endUpdate.
 *
 * @param dataSource the data source providing the sections
 * @param sourceSectionIndex the section index in the source data source
 * @param numberOfSections the number of sections to insert
 * @param targetSectionIndex the section index in this data source at which to insert the specified sections
 * @param useRowsFromSource whether the inserted sections should contain the original rows (YES) or should be left empty (NO)
 * @param tableView the table view which is passed to data sources in queries and
 *          which will be updated.
 */
- (void)insertSectionsFromDataSource:(NSString*__nonnull)dataSourceKey
                  sourceSectionIndex:(NSUInteger)sourceSectionIndex
                               count:(NSUInteger)numberOfSections
                      atSectionIndex:(NSUInteger)targetSectionIndex
                   useRowsFromSource:(BOOL)useRowsFromSource
                           tableView:(UITableView*__nullable)tableView
                              update:(BOOL)updateTableView
                    withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 * Removes the specified numberOfSections starting at the specified sectionIndex.
 *
 * @note If a tableView is specified, it will be updated using
 *      automatic row animations. You have to call begin- and endUpdate.
 *      If you do not want to update the table view, use the version of
 *      this method that let's you specify whether to update and which
 *      animation to use.
 *
 * @param numberOfSections the number of sections to remove
 * @param sectionIndex the index of the first section to remove
 * @param tableView the table view which is passed to data sources in queries and
 *          which will be updated if update is YES.
 */
- (void)        remove:(NSUInteger)numberOfSections
       sectionsAtIndex:(NSUInteger)sectionIndex
             tableView:(UITableView*__nullable)tableView;

/**
 * Removes the specified numberOfSections starting at the specified sectionIndex.
 *
 * @note If a tableView is specified and update is YES, the table view will be
 *      updated using the specified row animations. You have to call begin- and endUpdate.
 *
 * @param numberOfSections the number of sections to remove
 * @param sectionIndex the index of the first section to remove
 * @param tableView the table view which is passed to data sources in queries and
 *          which will be updated if update is YES.
 * @param update If YES, the tableView will be updated (without calling
 *          beginUpdate/endUpdate).
 * @param rowAnimation The row animation to use if update is YES.
 */
- (void)        remove:(NSUInteger)numberOfSections
       sectionsAtIndex:(NSUInteger)sectionIndex
             tableView:(UITableView*__nullable)tableView
                update:(BOOL)updateTableView
      withRowAnimation:(UITableViewRowAnimation)rowAnimation;

#pragma mark - Moving Rows

- (void)moveRowAtIndex:(NSInteger)rowIndex
             inSection:(NSInteger)sectionIndex
            toRowIndex:(NSInteger)targetIndex
             tableView:(UITableView*__nullable)tableView;

- (void)moveRowAtIndex:(NSInteger)rowIndex
             inSection:(NSInteger)sectionIndex
            toRowIndex:(NSInteger)targetIndex
             tableView:(UITableView*__nullable)tableView
                update:(BOOL)updateTableView;

- (void)moveRowAtIndexPath:(NSIndexPath*__nonnull)indexPath
               toIndexPath:(NSIndexPath*__nonnull)targetIndexPath
                 tableView:(UITableView *__nullable)tableView;

- (void)moveRowAtIndexPath:(NSIndexPath*__nonnull)indexPath
               toIndexPath:(NSIndexPath*__nonnull)targetIndexPath
                 tableView:(UITableView *__nullable)tableView
                    update:(BOOL)updateTableView;

#pragma mark - Adding and Removing Rows to/from Sections
/// @name Adding and Removing Rows to or from Sections

/**
 * Takes the specified numberOfRows from the specified dataSource starting
 * at the specified sourceIndexPath and inserts them at the position
 * specified by indexPath.
 *
 * @note The source section has to contain a sufficient amount of rows
 *      and the target indexPath has to reference a valid insertion point.
 *
 * @note If a tableView is specified, it will be updated using
 *      automatic row animations. You have to call begin- and endUpdate.
 *      If you do not want to update the table view, use the version of
 *      this method that let's you specify whether to update and which
 *      animation to use.
 *
 * @param dataSource the data source providing the rows
 * @param sourceIndexPath the indexPath specifying the first row to insert
 * @param numberOfRows the number of rows to insert
 * @param indexPath the location where the rows should be inserted.
 * @param tableView the table view which is passed to data sources in queries and
 *          which will be updated.
 */
- (void)insertRowsFromDataSource:(NSString*__nonnull)dataSourceKey
                 sourceIndexPath:(NSIndexPath*__nonnull)sourceIndexPath
                           count:(NSUInteger)numberOfRows
                     atIndexPath:(NSIndexPath*__nonnull)indexPath
                       tableView:(UITableView*__nullable)tableView;

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
 * @param tableView the table view which is passed to data sources in queries and
 *          which will be updated if update is YES.
 * @param update If YES, the tableView will be updated (without calling
 *          beginUpdate/endUpdate).
 * @param rowAnimation The row animation to use if update is YES.
 */
- (void)insertRowsFromDataSource:(NSString*__nonnull)dataSourceKey
                 sourceIndexPath:(NSIndexPath*__nonnull)sourceIndexPath
                           count:(NSUInteger)numberOfRows
                     atIndexPath:(NSIndexPath*__nonnull)indexPath
                       tableView:(UITableView*__nullable)tableView
                          update:(BOOL)updateTableView
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
 * @param tableView the table view which is passed to data sources in queries and
 *          which will be updated.
 * @param update If YES, the tableView will be updated (without calling
 *          beginUpdate/endUpdate).
 * @param rowAnimation The row animation to use if update is YES.
 *
 * @return 0 if the specified number of rows has been removed or the number of
 *      rows which have not been removed.
 */
- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
       rowsFromIndexPath:(NSIndexPath*__nonnull)indexPath
               tableView:(UITableView*__nullable)tableView
                  update:(BOOL)updateTableView
        withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 * Removes (up to) the specified numberOfRows from the section and row of
 * the specified indexPath and returns the number of rows which could not be
 * removed (due to the section not containing that many rows at and following
 * the indexPath)
 *
 * @note If a tableView is specified, it will be updated using
 *      automatic row animations. You have to call begin- and endUpdate.
 *      If you do not want to update the table view, use the version of
 *      this method that let's you specify whether to update and which
 *      animation to use.
 *
 * @param numberOfRows the number of rows to remove
 * @param indexPath the index path specifying the first row to remove
 * @param tableView the table view which is passed to data sources in queries and
 *          which will be updated.
 * @param update If YES, the tableView will be updated (without calling
 *          beginUpdate/endUpdate).
 * @param rowAnimation The row animation to use if update is YES.
 *
 * @return 0 if the specified number of rows has been removed or the number of
 *      rows which have not been removed.
 */
- (NSUInteger)removeUpTo:(NSUInteger)numberOfRows
       rowsFromIndexPath:(NSIndexPath*__nonnull)indexPath
               tableView:(UITableView*__nullable)tableView;

#pragma mark - Resolve Source Data Sources, Delegates and Coordinates

- (BOOL)resolveIndexPath:(out NSIndexPath*__autoreleasing __nullable* __nullable)indexPathStorage
      forSourceIndexPath:(NSIndexPath* __nonnull)sourceIndexPath
            inDataSource:(AKATVDataSource* __nonnull)dataSource;

- (BOOL)resolveSection:(out NSInteger* __nullable)sectionStorage
      forSourceSection:(NSInteger)sourceSection
          inDataSource:(AKATVDataSource* __nonnull)dataSource;

- (BOOL)resolveAKADataSource:(out AKATVDataSource*__autoreleasing __nullable* __nullable)dataSourceStorage
             sourceIndexPath:(out NSIndexPath*__autoreleasing __nullable* __nullable)indexPathStorage
                forIndexPath:(NSIndexPath* __nonnull)indexPath;

- (BOOL)resolveAKADataSource:(out AKATVDataSource*__autoreleasing __nullable* __nullable)dataSourceStorage
          sourceSectionIndex:(out NSInteger* __nullable)sectionIndexStorage
             forSectionIndex:(NSInteger)sectionIndex;

/**
 * Resolves the source data source, delegate and index of the section with the specified section index
 * and stores the resolved values in the respective specified locations.
 *
 * @param dataSourceStorage A pointer to data source which will be updated if the resolution succeeds.
 * @param delegateStorage A pointer to a delegate which will be updated if the resolution succeeds.
 * @param sectionIndexStorage A pointer to a section index which will be updated if the resolution succeeds.
 * @param sectionIndex The index of the section for which the resolution should be performed.
 *
 * @return YES if the section with the specified sectionIndex exists.
 */
- (BOOL)resolveDataSource:(out __autoreleasing id<UITableViewDataSource>__nullable*__nullable)dataSourceStorage
                 delegate:(out __autoreleasing id<UITableViewDelegate>__nullable*__nullable)delegateStorage
       sourceSectionIndex:(out NSInteger *__nullable)sectionIndexStorage
          forSectionIndex:(NSInteger)sectionIndex;

/**
 * Resolves the source data source, delegate and index path of the row at the specified indexPath
 * and stores the resolved values in the respective specified locations.
 *
 * @param dataSourceStorage A pointer to data source which will be updated if the resolution succeeds.
 * @param delegateStorage A pointer to a delegate which will be updated if the resolution succeeds.
 * @param indexPathStorage A pointer to an index path which will be updated if the resolution succeeds.
 * @param sectionIndex The index of the section for which the resolution should be performed.
 *
 * @return YES if the row at the specified indexPath exists.
 */
- (BOOL)resolveDataSource:(out __autoreleasing id<UITableViewDataSource>__nullable*__nullable)dataSourceStorage
                 delegate:(out __autoreleasing id<UITableViewDelegate>__nullable*__nullable)delegateStorage
          sourceIndexPath:(out NSIndexPath *__autoreleasing __nullable*__nullable)indexPathStorage
             forIndexPath:(NSIndexPath*__nullable)indexPath;

#pragma mark - UITableViewDelegate Support

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
 * Makes this data source stop responding to the specified selector as part of the automatic
 * delegate proxy implementation.
 *
 * @note that if the class implements the corresponding method this will have not effect.
 *
 * @param selector one of the methods specified in the UITableViewDelegate protocol
 */
- (void)removeTableViewDelegateSelector:(SEL __nonnull)selector;

@end
