//
//  AKAIPAddress.m
//  proReport
//
//  Created by Michael Utech on 26.02.15.
//  Copyright (c) 2015 Trinomica GmbH. All rights reserved.
//

#import "AKAIPAddress.h"
#import "AKANetworkingErrors.h"


#import <arpa/inet.h>

@interface AKAIPAddress() {
    BOOL _isSet;
    struct in_addr _storage;
}

@end

@implementation AKAIPAddress

#pragma mark - Initialization

+ (instancetype)ipAddressWithSocketAddress:(struct sockaddr*)address
{
    return [[AKAIPAddress alloc] initWithIntegerValueInNetworkByteOrder:((struct sockaddr_in*)address)->sin_addr.s_addr];
}

+ (instancetype)ipAddressWithInternetAddress:(struct in_addr)address
{
    return [[AKAIPAddress alloc] initWithIntegerValueInNetworkByteOrder:address.s_addr];
}

- (instancetype)initWithString:(NSString*)text
                         error:(NSError*__autoreleasing*)error
{
    self = [super init];
    if (self)
    {
        if (![self parseText:text error:error])
        {
            self = nil;
        }
    }
    return self;
}

- (instancetype)initWithIntegerValueInNetworkByteOrder:(in_addr_t)s_addr
{
    self = [super init];
    if (self)
    {
        _storage.s_addr  = s_addr;
        _isSet = YES;
    }
    return self;
}

- (instancetype)initWithComponent0:(uint8_t)c0
                        component1:(uint8_t)c1
                        component2:(uint8_t)c2
                        component3:(uint8_t)c3
{
    in_addr_t address = htonl(c0 << 24 | c1 << 16 | c2 << 8 | c3);
    self = [self initWithIntegerValueInNetworkByteOrder:address];
    return self;
}

- (instancetype)initWithComponents:(NSArray*)components
{
    NSParameterAssert(components != nil && components.count == 4);
    NSParameterAssert([components[0] isKindOfClass:[NSNumber class]] &&
                      ((NSNumber*)components[0]).unsignedIntegerValue < 256);
    NSParameterAssert([components[1] isKindOfClass:[NSNumber class]] &&
                      ((NSNumber*)components[1]).unsignedIntegerValue < 256);
    NSParameterAssert([components[2] isKindOfClass:[NSNumber class]] &&
                      ((NSNumber*)components[2]).unsignedIntegerValue < 256);
    NSParameterAssert([components[3] isKindOfClass:[NSNumber class]] &&
                      ((NSNumber*)components[3]).unsignedIntegerValue < 256);

    return [self initWithComponent0:(uint8_t)((NSNumber*)components[0]).unsignedIntegerValue
                         component1:(uint8_t)((NSNumber*)components[1]).unsignedIntegerValue
                         component2:(uint8_t)((NSNumber*)components[2]).unsignedIntegerValue
                         component3:(uint8_t)((NSNumber*)components[3]).unsignedIntegerValue];
}

#pragma mark - Access

- (NSString *)description
{
    return self.text;
}

- (NSString *)text
{
    NSString* result = nil;
    if (_isSet)
    {
        socklen_t length = INET_ADDRSTRLEN + 1;
        char buffer[length];
        const char* cString = inet_ntop(AF_INET, &_storage, buffer, length);
        if (cString)
        {
            result = [NSString stringWithUTF8String:cString];
        }
    }
    return result;
}

- (in_addr_t)address
{
    return _storage.s_addr;
}

- (NSUInteger)unsignedIntegerValue
{
    return ntohl(self.address);
}

- (NSArray *)components
{
    NSArray* result = nil;
    if (_isSet)
    {
        result = @[self[0], self[1], self[2], self[3]];
    }
    return result;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return @((uint8_t) (_storage.s_addr >> (index * 8)) & 0xff);
}

#pragma mark - Implementation

- (BOOL)parseText:(NSString*)text error:(NSError*__autoreleasing*)error
{
    if (text.length > 0)
    {
        const char* cText = [text cStringUsingEncoding:NSUTF8StringEncoding];
        _isSet = (1 == inet_aton(cText, &_storage));
        if (!_isSet && error != nil)
        {
            *error = [NSError errorWithDomain:[AKANetworkingErrors errorDomain]
                                         code:InvalidCIDREmptyString
                                     userInfo:
                      @{ NSLocalizedDescriptionKey: @"Invalid IP address (invalid format, expected d.d.d.d with d in range [0..255])"
                         }];
        }
    }
    else if (error)
    {
        *error = [NSError errorWithDomain:[AKANetworkingErrors errorDomain]
                                     code:InvalidCIDRString
                                 userInfo:
                  @{ NSLocalizedDescriptionKey: @"Invalid IP address (empty string)"
                     }];
    }
    return _isSet;
}

@end
