//
//  AKAOperationErrors.m
//  AKABeacon
//
//  Created by Michael Utech on 08.06.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAOperationErrors.h"
#import "AKAOperation.h"
#import "AKAOperationCondition.h"
#import "AKAOperationConditions_SubConditions.h"
#import "AKAPresentViewControllerOperation.h"

@implementation AKAOperationErrors

+ (NSString *)errorDomain
{
    static NSString* result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = @"com.aka-labs.AKAOperationErrors";
    });
    return result;
}

+ (NSError *)presentViewControllerOperationFailedNoPresenter:(AKAPresentViewControllerOperation *)presentViewControllerOperation
{
    NSString* reason = @"Failed to find a suitable view controller to present the view controller";
    NSString* description = [NSString stringWithFormat:@"%@: %@", presentViewControllerOperation, reason];
    return [NSError errorWithDomain:[AKAOperationErrors errorDomain]
                               code:AKAPresentViewControllerOperationFailedNoPresenter
                           userInfo:@{ NSLocalizedDescriptionKey: description,
                                       NSLocalizedFailureReasonErrorKey: reason,
                                       @"operation": presentViewControllerOperation }];
}

@end
