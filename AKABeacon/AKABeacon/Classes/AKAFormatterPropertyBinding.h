//
//  AKAFormatterPropertyBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"


@interface AKAFormatterPropertyBinding : AKAPropertyBinding

#pragma mark - Enumeration and Option Type Registry

+ (void)registerEnumerationAndOptionTypes;

#pragma mark - Abstract Methods

- (NSFormatter*)createMutableFormatter;

- (NSFormatter*)defaultFormatter;

@end
