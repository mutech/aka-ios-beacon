//
//  AKATableViewCellFactory.m
//  AKABeacon
//
//  Created by Michael Utech on 04.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKANullability.h"

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

- (id)copyWithZone:(NSZone * __unused)zone
{
    AKATableViewCellFactory* result = [AKATableViewCellFactory new];

    result.cellIdentifier = self.cellIdentifier;
    result.cellType = self.cellType;
    result.cellStyle = self.cellStyle;

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
