//
//  AKANetworkingErrors.h
//  proReport
//
//  Created by Michael Utech on 26.02.15.
//  Copyright (c) 2015 Trinomica GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum AKANetworkingErrorCodes {
    // Format errors
    InvalidCIDRString = 100,
    InvalidCIDREmptyString = 101,

    // Network function failures:
    GetIfAddrsFailed = 301,

    FtpSessionStartFailed = 10000,
    FtpSessionStartFailedWithLoginError = 10301,
    FtpSessionEndFailed = 11000,

} AKANetworkingErrorCodes;

@interface AKANetworkingErrors : NSObject

+ (NSString*)errorDomain;

@end
