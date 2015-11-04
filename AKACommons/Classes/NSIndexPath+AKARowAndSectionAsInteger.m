//
//  NSIndexPath+AKARowAndSectionAsInteger.m
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "NSIndexPath+AKARowAndSectionAsInteger.h"

@implementation NSIndexPath (AKARowAndSectionAsInteger)

- (NSUInteger)aka_unsignedIntegerValue
{
    NSUInteger result = 0;
#if __LP64__
    if ((self.row != NSNotFound && ((NSUInteger)self.row) > 0xffffffff - 2) ||
        (self.section != NSNotFound && ((NSUInteger)self.section) > 0xffffffff - 2))
    {
        @throw [NSException exceptionWithName:@"NSIndexPath cannot be encoded in an NSUInteger" reason:@"Rrow or section out of encoding range (0..2^32-2)" userInfo:nil];
    }
    NSUInteger row = self.row == NSNotFound ? 0xffffffff : (NSUInteger)self.row;
    NSUInteger section = self.section == NSNotFound ? 0xffffffff : (NSUInteger)self.section;

    result = (row & 0xffffffff) + ((section & 0xffffffff) << 32);
#else
    if ((self.row != NSNotFound && ((NSUInteger)self.row) > 0xfffff - 2) ||
        (self.section != NSNotFound && ((NSUInteger)self.section) > 0xfff - 2))
    {
        @throw [NSException exceptionWithName:@"NSIndexPath cannot be encoded in an NSUInteger" reason:@"Rrow or section out of encoding range (0..2^20-2 or 0..2^12-2 respectively)" userInfo:nil];
    }
    NSUInteger row = self.row == NSNotFound ? 0xfffff : (NSUInteger)self.row;
    NSUInteger section = self.section == NSNotFound ? 0xfff : (NSUInteger)self.section;

    result = (row & 0xfffff) + ((section & 0xfff) << 20);
#endif
    return result;
}

+ (NSIndexPath *)aka_indexPathFromUnsignedIntegerValue:(NSUInteger)unsignedIntegerValue
{
    NSIndexPath* result = nil;
    if (sizeof(NSUInteger) == 4)
    {
        NSInteger row = unsignedIntegerValue & 0xfffff;
        if (row == 0xfffff)
        {
            row = NSNotFound;
        }
        NSInteger section = unsignedIntegerValue >> 20;
        if (section == 0xfff)
        {
            section = NSNotFound;
        }
        result = [NSIndexPath indexPathForRow:row inSection:section];
    }
    else
    {
        NSAssert(sizeof(NSUInteger) == 8, @"Unexpected size %lu of NSUInteger, expected 4 or 8", sizeof(NSUInteger));
        NSInteger row = (NSInteger)(unsignedIntegerValue & 0xffffffffu);
        if (row == 0xffffffff)
        {
            row = NSNotFound;
        }
        NSInteger section = unsignedIntegerValue >> 32;
        if (section == 0xffffffff)
        {
            section = NSNotFound;
        }
        result = [NSIndexPath indexPathForRow:row inSection:section];
    }
    return result;
}

@end
