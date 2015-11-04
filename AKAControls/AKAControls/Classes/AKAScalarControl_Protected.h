//
//  AKAAtomicControl_Protected.h
//  AKABeacon
//
//  Created by Michael Utech on 14.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAScalarControl.h"

@interface AKAScalarControl ()

#pragma mark - Initialization
/// @name Initialization

- (instancetype)            initWithOwner:(AKACompositeControl*)owner
                                  binding:(AKAControlViewBinding*)binding;

- (instancetype)      initWithDataContext:(id)dataContext
                                  binding:(AKAControlViewBinding*)binding;

@end
