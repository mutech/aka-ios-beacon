//
//  AKAOperationErrors.h
//  AKABeacon
//
//  Created by Michael Utech on 08.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import <AKABeacon/AKABeacon.h>

@interface AKAOperationErrors : AKAErrors

typedef NS_ENUM(NSUInteger, AKAOperationError)
{
    AKAOperationErrorConditionFailed
};

FOUNDATION_EXPORT NSString* const kAKAOperationErrorDomain;

@end
