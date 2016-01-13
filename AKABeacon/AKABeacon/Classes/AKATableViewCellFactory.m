//
//  AKATableViewCellFactory.m
//  AKABeacon
//
//  Created by Michael Utech on 04.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;

#import "AKATableViewCellFactory.h"

@implementation AKATableViewCellFactory

- (instancetype)init
{
    if (self = [super init])
    {
        self.cellStyle = UITableViewCellStyleDefault;
    }
    return self;
}

- (BOOL)dataContextSatisfiesPredicate:(opt_id)dataContext
{
    BOOL result = self.predicate == nil;

    if (!result)
    {
        result = [self.predicate evaluateWithObject:dataContext];
    }

    return result;
}

- (UITableViewCell*)tableView:(req_UITableView)tableView
        cellForRowAtIndexPath:(req_NSIndexPath)indexPath
{
    UITableViewCell* result = nil;

    if (self.cellIdentifier)
    {
        result = [tableView dequeueReusableCellWithIdentifier:(req_NSString)self.cellIdentifier
                                                 forIndexPath:indexPath];
    }

    if (!result)
    {
        if (self.cellType)
        {
            result = [self.cellType alloc];
            result = [result initWithStyle:self.cellStyle
                           reuseIdentifier:self.cellIdentifier];
        }
    }
    else if (self.cellType)
    {
        NSAssert([result.class isSubclassOfClass:self.cellType],
                 @"Dequed cell %@ is not an instance of configured cell type %@",
                 result, NSStringFromClass((req_Class)self.cellType));
    }

    return result;
}

@end
