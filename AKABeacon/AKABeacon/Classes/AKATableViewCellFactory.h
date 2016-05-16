//
//  AKATableViewCellFactory.h
//  AKABeacon
//
//  Created by Michael Utech on 04.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;

#import "AKABindingContextProtocol.h"

@interface AKATableViewCellFactory : NSObject<NSCopying>

@property(nonatomic, nullable) NSString*    cellIdentifier;
@property(nonatomic, nullable) Class        cellType;
@property(nonatomic) UITableViewCellStyle   cellStyle;

- (opt_UITableViewCell)tableView:(req_UITableView)tableView
           cellForRowAtIndexPath:(req_NSIndexPath)indexPath;

@end
