//
//  AKAInterfaceInfo.m
//  proReport
//
//  Created by Michael Utech on 25.02.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAInterfaceInfo.h"
#import "AKANetworkingErrors.h"

#import <ifaddrs.h>
#import <arpa/inet.h>

#if 0
#import "getgateway.h"
#endif

@implementation AKAInterfaceInfo

@synthesize name = _name;
@synthesize address = _address;
@synthesize netmask = _netmask;
@synthesize broadcastAddress = _broadcastAddress;
@synthesize flags = _flags;

#pragma mark - Initialization

+ (AKAInterfaceInfo *)wlanInterface
{
    return [self getInterfaceInfoForName:@"en0" errror:nil];
}

+ (NSArray*)getInterfaceInfosForName:(NSString*)name error:(NSError*__autoreleasing*)error
{
    return [self getInterfaceInfosMatching:^BOOL(struct ifaddrs *ifaddr)
            {
        return ifaddr->ifa_addr->sa_family == AF_INET && [name isEqualToString:[NSString stringWithUTF8String:ifaddr->ifa_name]];
            } error:error];
}

+ (AKAInterfaceInfo *)getInterfaceInfoForName:(NSString *)interfaceName errror:(NSError *__autoreleasing *)error
{
    return [self getInterfaceInfosForName:interfaceName error:error].firstObject;
}

+ (NSArray *)getAllInterfaceInfos:(NSError *__autoreleasing *)error
{
    return [self getInterfaceInfosMatching:^BOOL(struct ifaddrs *ifaddr) {
        return ifaddr->ifa_addr->sa_family == PF_INET;
    }
                                     error:error];
}

+ (NSArray *)getInterfaceInfosMatching:(BOOL(^)(struct ifaddrs* ifaddr))predicate
                                 error:(NSError *__autoreleasing *)error
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    [self enumerateNetworkInterfacesMatching:predicate
                                   withBlock:^(struct ifaddrs *ifaddr, BOOL *stop)
     {
         (void)stop; // not needed
         NSString* name = [NSString stringWithUTF8String:ifaddr->ifa_name];
         AKAIPAddress* address = [AKAIPAddress ipAddressWithSocketAddress:ifaddr->ifa_addr];
         AKAIPNetmask* netmask = ifaddr->ifa_netmask != NULL ? [AKAIPNetmask ipAddressWithSocketAddress:ifaddr->ifa_netmask] : nil;
         AKAIPAddress* broadcastAddress = ifaddr->ifa_dstaddr != NULL ? [AKAIPAddress ipAddressWithSocketAddress:ifaddr->ifa_dstaddr] : nil;
         NSUInteger flags = ifaddr->ifa_flags;

         [result addObject:[[AKAInterfaceInfo alloc] initWithName:name
                                                          address:address
                                                          netmask:netmask
                                                 broadcastAddress:broadcastAddress
                                                            flags:flags]];
     }
                                       error:error];
    return result;
}

+ (BOOL)enumerateNetworkInterfacesMatching:(BOOL(^)(struct ifaddrs* ifaddr))predicate
                                 withBlock:(void(^)(struct ifaddrs* ifaddr, BOOL* stop))block
                                      error:(NSError*__autoreleasing*)error
{
    struct ifaddrs *interfaces = NULL;
    BOOL result = getifaddrs(&interfaces) == 0;
    if (result)
    {
        BOOL stop = NO;
        for (struct ifaddrs* ifaddr = interfaces;
             ifaddr != NULL && !stop;
             ifaddr = ifaddr->ifa_next)
        {
            if (predicate(ifaddr))
            {
                block(ifaddr, &stop);
            }
        }
        freeifaddrs(interfaces);
    }
    else if (error)
    {
        NSString* reason = [NSString stringWithUTF8String:strerror(errno)];
        *error = [NSError errorWithDomain:[AKANetworkingErrors errorDomain]
                                     code:GetIfAddrsFailed
                                 userInfo:@{ NSLocalizedDescriptionKey: @"Failed to read interface information",
                                             NSLocalizedFailureReasonErrorKey: reason }];
    }
    return result;
}

- (instancetype)initWithName:(NSString*)name
                     address:(AKAIPAddress*)address
                     netmask:(AKAIPNetmask*)netmask
            broadcastAddress:(AKAIPAddress*)broadcastAddress
                       flags:(NSUInteger)flags
{
    self = [super init];
    if (self)
    {
        _name = name;
        _address = address;
        _netmask = netmask;
        _broadcastAddress = broadcastAddress;
        _flags = flags;
    }
    return self;
}

#pragma mark - Derived Properties

- (NSUInteger)networkSize
{
    return self.netmask.networkSize;
}

- (AKAIPAddress*)networkAddress
{
    in_addr_t resultAddress = self.address.address & self.netmask.address;
    AKAIPAddress* result = [[AKAIPAddress alloc] initWithIntegerValueInNetworkByteOrder:resultAddress];
    return result;
}

- (AKAIPAddress*)gateway
{
    AKAIPAddress* result = nil;
    if (self.name)
    {
#if 0
        in_addr_t gatewayAddress;
        const char* interfaceName = [self.name cStringUsingEncoding:NSUTF8StringEncoding];
        if (getgateway(interfaceName, &gatewayAddress) == 0)
        {
            result = [[AKAIPAddress alloc] initWithIntegerValueInNetworkByteOrder:gatewayAddress];
        }
#endif
    }
    return result;
}

- (AKAIPAddress*)computedBroadcastAddress
{
    in_addr_t hostmask = ~((uint32_t)self.netmask.address);
    in_addr_t broadcast = self.networkAddress.address | hostmask;
    AKAIPAddress* result = [[AKAIPAddress alloc] initWithIntegerValueInNetworkByteOrder:broadcast];
    return result;
}

#pragma mark - Iterating over addresses in the connected network

- (AKAIPAddress*)addressAtIndexedSubscript:(NSUInteger)index
{
    AKAIPAddress* result = nil;
    if (index < self.networkSize)
    {
        in_addr_t address = htonl(self.networkAddress.unsignedIntegerValue + index);
        result = [[AKAIPAddress alloc] initWithIntegerValueInNetworkByteOrder:address];
    }
    return result;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return [self addressAtIndexedSubscript:index];
}

#pragma mark - Implementation

+ (NSString*)stringFromSockaddr:(struct sockaddr*)sain
{
    NSString* result = nil;
    if (sain != NULL)
    {
        char* cadr = inet_ntoa(((struct sockaddr_in *)sain)->sin_addr);
        result = [NSString stringWithUTF8String:cadr];
    }
    return result;
}

@end
