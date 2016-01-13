//
//  AKATableViewCellFactoryPropertyBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 08.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"

/**
 Applies table view cell factory specifications defined in table view data source bindings to cell factories.
 
 The binding does not support a primary expression, instead it will create a new instance of AKATableViewCellFactory. It supports the attributes "predicate" (see AKAPredicatePropertyBinding), "cellIdentifier" (the reuse identifier used to dequeue or create table view cells), "cellType" and "cellStyle" (used when creating table view cells). All attributes are optional.
 */
@interface AKATableViewCellFactoryPropertyBinding: AKAPropertyBinding
@end