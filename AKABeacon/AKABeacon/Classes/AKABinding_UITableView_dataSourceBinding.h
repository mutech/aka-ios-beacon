//
//  AKABinding_UITableView_dataSourceBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 03.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKAViewBinding.h"

@class AKABinding_UITableView_dataSourceBinding;

@protocol AKABindingDelegate_UITableView_dataSourceBinding <AKABindingDelegate>

@optional
- (void)bindingWillUpdateDynamicBindings:(nonnull AKABinding_UITableView_dataSourceBinding*)binding;

@optional
- (void)bindingDidUpdateDynamicBindings:(nonnull AKABinding_UITableView_dataSourceBinding*)binding;

@optional
- (void)                    binding:(nonnull AKABinding_UITableView_dataSourceBinding*)binding
          addDynamicBindingsForCell:(req_UITableViewCell)cell
                          indexPath:(req_NSIndexPath)indexPath
                        dataContext:(opt_id)dataContext;

@optional
- (void)                    binding:(nonnull AKABinding_UITableView_dataSourceBinding*)binding
       removeDynamicBindingsForCell:(req_UITableViewCell)cell
                          indexPath:(req_NSIndexPath)indexPath;

@optional
- (void)                    binding:(nonnull AKABinding_UITableView_dataSourceBinding*)binding
       addDynamicBindingsForSection:(NSInteger)section
                         headerView:(req_UIView)headerView
                        dataContext:(opt_id)dataContext;

@optional
- (void)                    binding:(nonnull AKABinding_UITableView_dataSourceBinding*)binding
    removeDynamicBindingsForSection:(NSInteger)section
                         headerView:(req_UIView)headerView
                        dataContext:(opt_id)dataContext;
@optional
- (void)                    binding:(nonnull AKABinding_UITableView_dataSourceBinding*)binding
       addDynamicBindingsForSection:(NSInteger)section
                         footerView:(req_UIView)headerView
                        dataContext:(opt_id)dataContext;

@optional
- (void)                    binding:(nonnull AKABinding_UITableView_dataSourceBinding*)binding
    removeDynamicBindingsForSection:(NSInteger)section
                         footerView:(req_UIView)headerView
                        dataContext:(opt_id)dataContext;


@end


@interface AKABinding_UITableView_dataSourceBinding : AKAViewBinding

@property(nonatomic, weak, nullable) id<AKABindingDelegate_UITableView_dataSourceBinding> delegate;


@property(nonatomic, readonly, weak, nullable) UITableView*                                 tableView;

@end
