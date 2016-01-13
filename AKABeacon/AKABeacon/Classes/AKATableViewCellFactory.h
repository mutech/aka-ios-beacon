//
//  AKATableViewCellFactory.h
//  AKABeacon
//
//  Created by Michael Utech on 04.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKABindingContextProtocol.h"

@interface AKATableViewCellFactory : NSObject

@property(nonatomic, nullable) NSPredicate* predicate;

@property(nonatomic, nullable) NSString*    cellIdentifier;
@property(nonatomic, nullable) Class        cellType;
@property(nonatomic) UITableViewCellStyle   cellStyle;

- (BOOL)dataContextSatisfiesPredicate:(opt_id)dataContext;

- (opt_UITableViewCell)tableView:(req_UITableView)tableView
           cellForRowAtIndexPath:(req_NSIndexPath)indexPath;

@end
