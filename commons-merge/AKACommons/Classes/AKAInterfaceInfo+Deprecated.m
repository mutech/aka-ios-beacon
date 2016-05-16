//
//  AKAInterfaceInfo+Deprecated.m
//  AKACommons
//
//  Created by Michael Utech on 10.03.16.
//  Copyright © 2016 AKA Sarl. All rights reserved.
//

#import "AKAInterfaceInfo+Deprecated.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation AKAInterfaceInfo(Deprecated)

- (NSString *)SSID
{
    NSString *ssid = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CFDictionaryRef rawInfo =
    CNCopyCurrentNetworkInfo((__bridge CFStringRef)self.name);
#pragma clang diagnostic pop
    NSDictionary *info =
    CFBridgingRelease(rawInfo);
    ssid = info[@"SSID"];

    return ssid;
}

@end