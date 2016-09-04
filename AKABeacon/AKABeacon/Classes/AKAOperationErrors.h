//
//  AKAOperationErrors.h
//  AKABeacon
//
//  Created by Michael Utech on 08.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAErrors.h"

@class AKAOperation;
@class AKAPresentViewControllerOperation;

@interface AKAOperationErrors : AKAErrors

typedef NS_ENUM(NSUInteger, AKAOperationError)
{
    AKAOperationErrorConditionFailed,
    AKAOperationErrorDependencyFailed,

    AKAPresentViewControllerOperationFailedNoPresenter
};

+ (NSError *)presentViewControllerOperationFailedNoPresenter:(AKAPresentViewControllerOperation *)presentViewControllerOperation;

@end
