//
//  AKAIPNetmask.h
//  proReport
//
//  Created by Michael Utech on 26.02.15.
//  Copyright (c) 2015 Trinomica GmbH. All rights reserved.
//

#import "AKAIPAddress.h"

@interface AKAIPNetmask : AKAIPAddress

/**
 * The length of the netmask (number of leading contiguous set bits, for
 * example 24 for netmask 255.255.255.0
 */
@property (nonatomic, readonly) NSUInteger length;

/**
 * The number of hosts (addresses) in the (sub-)network defined by this
 * mask. If the netmask is not valid, a value of 0 is returned.
 */
@property (nonatomic, readonly) NSUInteger networkSize;

/**
 * Determines if the netmask is valid, which it is if it is contiguous
 * (no bits are set following an unset bit).
 */
@property (nonatomic, readonly) BOOL isValid;

/**
 * Initializes the instance with a mask of the specified lenth (having the
 * leading `length' bits set).
 *
 *  @param length the length of the net mask
 *
 *  @return the initialized instance.
 */
- (instancetype)initWithLength:(NSUInteger)length;

@end
