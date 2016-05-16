//
//  NSIndexPath+AKARowAndSectionAsInteger.h
//  AKACommons
//
//  Created by Michael Utech on 14.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSIndexPath (AKARowAndSectionAsInteger)

/**
 * Encodes the section- and row value of the indexPath as
 * unsigned integer value. On 32bit platforms, 12 bits are
 * used for the section (range 0..4094 + NSNotFound) and
 * 20 bits for the row (range 0..1048574 + NSNotFound). On
 * 64bit platforms, section and row each use 32bit.
 */
@property(nonatomic, readonly)NSUInteger aka_unsignedIntegerValue;

/**
 * Decodes the encoded section- and row value returning an
 * indexPath. On 32bit platforms, 12 bits are
 * used for the section (range 0..4095 + NSNotFound) and
 * 20 bits for the row (range 0..1048574 + NSNotFound). On
 * 64bit platforms, section and row each use 32bit.
 */
+ (NSIndexPath*)aka_indexPathFromUnsignedIntegerValue:(NSUInteger)unsignedIntegerValue;

@end
