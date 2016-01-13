//
//  AKAPredicatePropertyBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 29.12.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"

/**
 Binds a target property to an instance of NSPredicate. The binding expression can be specified as string (constant or key path) representing an NSPredicate format string and attributes where the attribute name is used as substitution variable and its primary expression the substitution value (using the current data context). Updates of either predicate format or attribute values will trigger an update of the target value.
 */
@interface AKAPredicatePropertyBinding : AKAPropertyBinding

@end
