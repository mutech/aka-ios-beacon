//
//  AKABinding_AKABinding_formatter.h
//  AKABeacon
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"


@interface AKABindingProvider_AKABinding_formatter: AKABindingProvider

#pragma mark - Enumeration and Option Type Registry

- (void)registerEnumerationAndOptionTypes;

@end

@interface AKABinding_AKABinding_formatter : AKAPropertyBinding

#pragma mark - Initialization

- (instancetype)                        initWithProperty:(req_AKAProperty)bindingTarget
                                              expression:(req_AKABindingExpression)bindingExpression
                                                 context:(req_AKABindingContext)bindingContext
                                                delegate:(opt_AKABindingDelegate)delegate
                                                   error:(out_NSError)error;

#pragma mark - Properties

@property(nonatomic, readonly) NSFormatter* formatter;

#pragma mark - Abstract Methods

- (NSDictionary<NSString*,id(^)(id)>*) configurationValueConvertersByPropertyName;

- (NSFormatter*)createMutableFormatter;

@end
