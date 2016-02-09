//
//  AKAInterfaceInfo.h
//  proReport
//
//  Created by Michael Utech on 25.02.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;

#import "AKANullability.h"
#import "AKAIPAddress.h"
#import "AKAIPNetmask.h"

@interface AKAInterfaceInfo: NSObject

#pragma mark - Initialization

+ (AKAInterfaceInfo* __nullable)wlanInterface;

/**
 *  Uses getifaddrs(3) to query for all interfaces.
 *
 *  @param error set if getifaddrs fails.
 *
 *  @return AKAInterfaceInfo instances for all interfaces visible through getifaddrs(3).
 */
+ (NSArray* __nullable)getAllInterfaceInfos:(NSError*__nullable*__nullable)error;

/**
 *  Returns information about the interface with the specified
 *  name using getifaddrs(3).
 *
 *  @param name the interface name (f.e. en0)
 *  @param error set if getifaddrs fails.
 *
 *  @return an AKAInterfaceInfo instance or nil if no matching interface was found or if an error occured.
 */
+ (AKAInterfaceInfo*__nullable)getInterfaceInfoForName:(NSString*__nonnull)interfaceName errror:(NSError*__nullable*__nullable)error;

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
- (opt_instancetype)     initWithName:(NSString*__nonnull)name
                              address:(AKAIPAddress*__nonnull)address
                              netmask:(AKAIPNetmask*__nonnull)netmask
                     broadcastAddress:(AKAIPAddress*__nonnull)broadcastAddress
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
@property (nonatomic, readonly) NSString* __nonnull name;

/**
 *  Interface address
 */
@property (nonatomic, readonly) AKAIPAddress* __nonnull address;

/**
 *  Netmask of the connected network
 */
@property (nonatomic, readonly) AKAIPNetmask* __nonnull netmask;

/**
 *  The network address computed from address and netmask
 */
@property (nonatomic, readonly) AKAIPAddress* __nonnull networkAddress;

/**
 *  The broadcast address (from dstaddr)
 */
@property (nonatomic, readonly) AKAIPAddress* __nonnull broadcastAddress;

/**
 *  The broadcast address computed from address and netmask
 */
@property (nonatomic, readonly) AKAIPAddress* __nonnull computedBroadcastAddress;

/**
 *  The gateway
 */
@property (nonatomic, readonly) AKAIPAddress* __nullable gateway;

/**
 *  flags (see ifconfig(8), even though you won't find a documentation of values there either - sorry)
 */
@property (nonatomic, readonly) NSUInteger flags;

/**
 * The SSID of the interface, if the interface is a WLAN interface, otherwise nil
 */
@property (nonnull, readonly) NSString* SSID;

#pragma mark - Iterating over addresses in the connected network

- (id __nonnull)objectAtIndexedSubscript:(NSUInteger)index;

- (AKAIPAddress* __nonnull)addressAtIndexedSubscript:(NSUInteger)index;

@end
