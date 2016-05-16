//
//  AKAInterfaceInfo+Deprecated.h
//  AKACommons
//
//  Created by Michael Utech on 10.03.16.
//  Copyright © 2016 AKA Sarl. All rights reserved.
//

#import "AKAInterfaceInfo.h"

@interface AKAInterfaceInfo(Deprecated)

/**
 * The SSID of the interface, if the interface is a WLAN interface, otherwise nil
 *
 * @warning The implementation uses a deprecated API (since 9.0) that will most likely not be available for much longer.
 */
@property (nonnull, readonly) NSString* SSID;

@end
