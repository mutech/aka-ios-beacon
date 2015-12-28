//
//  AKADynamicFormTableViewController.h
//  AKABeacon
//
//  Created by Michael Utech on 14.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

@import AKACommons.AKANullability;

@interface AKADynamicFormTableViewController : UITableViewController

/**
 Renders the cell by applying bindings defined in the content view hierarchy in a binding context
 based on the specified data context.

 @param cell the cell to be rendered
 @param dataContext the data context used for ad hoc bindings
 @param error set to error details if rendering the cell fails
 
 @return YES if rendering the cell succeeded, NO otherwise
 */
- (BOOL)renderCell:(req_UITableViewCell)cell
   withDataContext:(opt_id)dataContext
             error:(out_NSError)error;

@end
