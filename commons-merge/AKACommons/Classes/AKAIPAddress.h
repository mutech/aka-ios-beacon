//
//  AKAIPAddress.h
//  proReport
//
//  Created by Michael Utech on 26.02.15.
//  Copyright (c) 2015 Trinomica GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sys/types.h>
#import <netinet/in.h>

@interface AKAIPAddress : NSObject

#pragma mark - Initialization

+ (instancetype)ipAddressWithSocketAddress:(struct sockaddr*)address;

+ (instancetype)ipAddressWithInternetAddress:(struct in_addr)address;

- (instancetype)initWithString:(NSString*)text
                         error:(NSError*__autoreleasing*)error;

- (instancetype)initWithIntegerValueInNetworkByteOrder:(in_addr_t)s_addr;

- (instancetype)initWithComponent0:(uint8_t)c0
                        component1:(uint8_t)c1
                        component2:(uint8_t)c2
                        component3:(uint8_t)c3;

@property (nonatomic, readonly) NSString* text;

@property (nonatomic, readonly) in_addr_t address;

@property (nonatomic, readonly) NSUInteger unsignedIntegerValue;

@property (nonatomic, readonly) NSArray* components;

/**
 *  Provides access to address components in range [0..3]
 *
 *  @param index index of the address component, ranges from 0 to 3, 0 referencing the first address component.
 *
 *  @return an NSNumber instance containing an int value in range of [0..255].
 */
- (id)objectAtIndexedSubscript:(NSUInteger)index;

@end
