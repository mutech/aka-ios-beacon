//
//  AKADynamicFormTableViewController.h
//  AKABeacon
//
//  Created by Michael Utech on 14.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

@import AKACommons.AKANullability;

#import "AKAFormControl.h"

/**
 UITableViewController that allows cells to use data bindinging.
 
 @warning This class has been superceeded by AKABinding_UITableView_dataSourceBinding and the corresponding UITableView.dataSourceBinding_aka property. You should not need to use this class in favor to data source bindings. If you have a use case that justifies its usage, please let us know. If we don't get feedback, we will most likely remove this class in the upcoming release.
 */
@interface AKADynamicFormTableViewController: UITableViewController

@property(nonatomic, readonly, nonnull) AKAFormControl* formControl;

#pragma mark - View Controller Life Cycle

/**
 Initializes the view controller's data binding support. Overriding subclasses have to call this implementation.
 
 @see [UITableViewController viewDidLoad]
 */
- (void)viewDidLoad;

/**
 Activates data bindings. Overriding subclasses have to call this implementation.
 
 @see [UITableViewController viewWillAppear:]
 */
- (void)viewWillAppear:(BOOL)animated;

/**
 Deactivates data bindings. Overriding subclasses have to call this implementation.

 @see [UITableViewController viewDidDisappear:]
 */
- (void)viewWillDisappear:(BOOL)animated;

#pragma mark - UITableViewDataSource

- (req_UITableViewCell)tableView:(req_UITableView)tableView
           cellForRowAtIndexPath:(req_NSIndexPath)indexPath;

#pragma mark - Abstract Methods - Data Context Mapping

- (req_NSString)                            tableView:(req_UITableView)tableView
                         cellIdentifierForDataContext:(req_id)dataContext;

- (opt_id)                                  tableView:(req_UITableView)tableView
                              dataContextForIndexPath:(req_NSIndexPath)indexPath;

#pragma mark - Abstract Methods - UITableViewDataSource

- (NSInteger)             numberOfSectionsInTableView:(req_UITableView)tableView;

- (NSInteger)                               tableView:(req_UITableView)tableView
                                numberOfRowsInSection:(NSInteger)section;

#pragma mark - Temporary Interface (subject of change)

- (void)removeAllRowControls;

@end
