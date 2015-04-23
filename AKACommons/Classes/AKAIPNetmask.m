//
//  AKAIPNetmask.m
//  proReport
//
//  Created by Michael Utech on 26.02.15.
//  Copyright (c) 2015 Trinomica GmbH. All rights reserved.
//

#import "AKAIPNetmask.h"

@implementation AKAIPNetmask

#pragma mark - Initialization

+ (instancetype)ipAddressWithSocketAddress:(struct sockaddr*)address
{
    return [[AKAIPNetmask alloc] initWithIntegerValueInNetworkByteOrder:((struct sockaddr_in*)address)->sin_addr.s_addr];
}

- (instancetype)initWithLength:(NSUInteger)length
{
    NSUInteger v = 0;
    if (length > 0)
    {
        for (int i=0; i < length; ++i)
        {
            v = (v << 1) | 1;
        }
        v = v << (32 - length);
    }
    in_addr_t address = htonl(v);

    self = [self initWithIntegerValueInNetworkByteOrder:address];
    return self;
}

#pragma mark - Properties

- (NSString *)description
{
    // Use length if netmask is valid:
    NSString* result = super.description;
    if (result && self.isValid)
    {
        result = @(self.length).stringValue;
    }
    return result;
}

- (NSUInteger)length
{
    NSUInteger result = 0;
    for (uint8_t i=0; i < 32 && [self bitAtIndex:i]; ++i)
    {
        ++result;
    }
    return result;
}

- (NSUInteger)networkSize
{
    NSUInteger result = 0;
    // The host mask (inverted netmask) is equivalent to the number
    // of addresses in this network (including network and broadcast
    // address).
    if (self.isValid)
    {
        result = ~((uint32_t)self.unsignedIntegerValue);
        if (result == 0)
        {
            // TODO: check if this special case really makes sense
            // A netmask of 32 means that there is a single host on the network
            result = 1;
        }
    }
    return result;
}

- (BOOL)isValid
{
    return [self isMaskContiguous:self.address];
}

#pragma mark - Implementation

- (BOOL) bitAtIndex:(uint8_t)index
{
    NSUInteger value = self.unsignedIntegerValue;
    value = value >> (31 - index);
    value = value & 1;
    return value == 1;
}

- (BOOL)isMaskContiguous:(uint32_t)mask
{
    BOOL result = YES;
    for (uint8_t i = (uint8_t)self.length; result && i < 32; ++i)
    {
        BOOL set = [self bitAtIndex:i];
        result = !set;
    }
    return result;
}

@end
