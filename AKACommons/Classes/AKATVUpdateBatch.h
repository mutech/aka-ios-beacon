//
//  AKATVUpdateBatch.h
//  AKACommons
//
//  Created by Michael Utech on 24.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKATVUpdateBatch: NSObject

#pragma mark - Initialization

- (instancetype)init;

#pragma mark - Properties

@property(nonatomic, readonly, weak) UITableView* tableView;

#pragma mark Begin and End Updates

- (void)beginUpdatesForTableView:(UITableView*)tableView;
- (void)endUpdatesForTableView:(UITableView*)tableView;

#pragma mark Recording Table View Updates

- (NSInteger)insertionIndexForSection:(NSInteger)sectionIndex
            forBatchUpdateInTableView:(UITableView*)tableView
                recordAsInsertedIndex:(BOOL)recordAsInserted;

- (NSInteger)deletionIndexForSection:(NSInteger)sectionIndex
           forBatchUpdateInTableView:(UITableView*)tableView
               recordAsInsertedIndex:(BOOL)recordAsDeleted;

- (NSIndexPath*)insertionIndexPathForRow:(NSInteger)rowIndex
                               inSection:(NSInteger)sectionIndex
               forBatchUpdateInTableView:(UITableView*)tableView
                   recordAsInsertedIndex:(BOOL)recordAsInserted;

- (NSIndexPath*)deletionIndexPathForRow:(NSInteger)rowIndex
                              inSection:(NSInteger)sectionIndex
              forBatchUpdateInTableView:(UITableView*)tableView
                   recordAsDeletedIndex:(BOOL)recordAsDeleted;

- (void)    movementSourceRowIndex:(inout NSIndexPath*__autoreleasing*)sourceRowIndex
                    targetRowIndex:(inout NSIndexPath*__autoreleasing*)targetRowIndex
         forBatchUpdateInTableView:(UITableView*)tableView
                  recordAsMovedRow:(BOOL)recordAsMovedRow;

- (NSArray*)correctedIndexPaths:(NSArray*)indexPaths;
- (NSIndexPath*)correctedIndexPath:(NSIndexPath*)indexPath;

@end

@interface AKATVUpdateBatch()

@property(nonatomic)NSUInteger depth;
@property(nonatomic, readonly) NSMutableIndexSet* insertedSections;
@property(nonatomic, readonly) NSMutableIndexSet* deletedSections;
@property(nonatomic, readonly) NSMutableDictionary* insertedRows;
@property(nonatomic, readonly) NSMutableDictionary* deletedRows;

@end
