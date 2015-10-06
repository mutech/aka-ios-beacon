//
//  AKABinding_AKABinding_formatter.h
//  AKAControls
//
//  Created by Michael Utech on 06.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"

@interface AKABinding_AKABinding_formatter : AKAPropertyBinding

#pragma mark - Initialization

- (instancetype)                        initWithProperty:(req_AKAProperty)bindingTarget
                                              expression:(req_AKABindingExpression)bindingExpression
                                                 context:(req_AKABindingContext)bindingContext
                                                delegate:(opt_AKABindingDelegate)delegate;

#pragma mark - Properties

@property(nonatomic, readonly) NSFormatter* formatter;

#pragma mark - Abstract Methods

- (NSDictionary<NSString*,id(^)(id)>*) configurationValueConvertersByPropertyName;

- (NSFormatter*)createMutableFormatter;

@end
