//
//  AKABinding_AKABinding_formatter.h
//  AKABeacon
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"


@interface AKABinding_AKABinding_formatter : AKAPropertyBinding

#pragma mark - Enumeration and Option Type Registry

+ (void)registerEnumerationAndOptionTypes;

#pragma mark - Initialization

#pragma mark - Properties

@property(nonatomic, readonly) NSFormatter* formatter;

#pragma mark - Abstract Methods

- (NSDictionary<NSString*,id(^)(id)>*) configurationValueConvertersByPropertyName;

- (NSFormatter*)createMutableFormatter;

- (NSFormatter*)defaultFormatter;

@end
