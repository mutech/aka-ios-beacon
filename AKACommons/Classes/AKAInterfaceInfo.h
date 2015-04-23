//
//  AKAInterfaceInfo.h
//  proReport
//
//  Created by Michael Utech on 25.02.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKAIPAddress.h"
#import "AKAIPNetmask.h"

@interface AKAInterfaceInfo: NSObject

#pragma mark - Initialization

+ (AKAInterfaceInfo*)wlanInterface;

/**
 *  Uses getifaddrs(3) to query for all interfaces.
 *
 *  @param error set if getifaddrs fails.
 *
 *  @return AKAInterfaceInfo instances for all interfaces visible through getifaddrs(3).
 */
+ (NSArray*)getAllInterfaceInfos:(NSError**)error;

/**
 *  Returns information about the interface with the specified
 *  name using getifaddrs(3).
 *
 *  @param name the interface name (f.e. en0)
 *  @param error set if getifaddrs fails.
 *
 *  @return an AKAInterfaceInfo instance or nil if no matching interface was found or if an error occured.
 */
+ (AKAInterfaceInfo*)getInterfaceInfoForName:(NSString*)interfaceName errror:(NSError**)error;

/**
 *  Initializes the instance with the specified information.
 *
 *  @param name the interface name (f.e. en0)
 *  @param address the interfaces address
 *  @param netmask the netmask of the network connected to the inteface
 *  @param gateway address of the peer in a point-to-point connection
 *  @param flags flags (see ifconfig(8))
 *
 *  @return the instance
 */
- (instancetype)initWithName:(NSString*)name
                     address:(AKAIPAddress*)address
                     netmask:(AKAIPNetmask*)netmask
            broadcastAddress:(AKAIPAddress*)broadcastAddress
                       flags:(NSUInteger)flags;

#pragma mark - Properties

/**
 * Number of addresses connected to the network on this interface.
 * Computed based on the netmask.
 */
@property (nonatomic, readonly) NSUInteger networkSize;

/**
 *  Interface name (f.e. en0)
 */
@property (nonatomic, readonly) NSString* name;

/**
 *  Interface address
 */
@property (nonatomic, readonly) AKAIPAddress* address;

/**
 *  Netmask of the connected network
 */
@property (nonatomic, readonly) AKAIPNetmask* netmask;

/**
 *  The network address computed from address and netmask
 */
@property (nonatomic, readonly) AKAIPAddress* networkAddress;

/**
 *  The broadcast address (from dstaddr)
 */
@property (nonatomic, readonly) AKAIPAddress* broadcastAddress;

/**
 *  The broadcast address computed from address and netmask
 */
@property (nonatomic, readonly) AKAIPAddress* computedBroadcastAddress;

/**
 *  The gateway
 */
@property (nonatomic, readonly) AKAIPAddress* gateway;

/**
 *  flags (see ifconfig(8), even though you won't find a documentation of values there either - sorry)
 */
@property (nonatomic, readonly) NSUInteger flags;

#pragma mark - Iterating over addresses in the connected network

- (id)objectAtIndexedSubscript:(NSUInteger)index;

- (AKAIPAddress*)addressAtIndexedSubscript:(NSUInteger)index;

@end
