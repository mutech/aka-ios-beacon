//
//  AKABinding_TargetValueUpdateProperties.h
//  AKABeacon
//
//  Created by Michael Utech on 29.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"


@interface AKABinding ()

/**
 Indicates whether an update of the target value is in progress.
 
 Used to prevent the source value from beeing updated as a consequence of a target value update (which would or at least could result in an endless loop, depending on the way how involved properties observe changes).
 */
@property(nonatomic) BOOL isUpdatingTargetValueForSourceValueChange;

@end
