//
//  NSDictionary+AKABindingExpressionSpecification.h
//  AKAControls
//
//  Created by Michael Utech on 25.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKANullability;

#import <Foundation/Foundation.h>

@interface NSDictionary (AKABindingExpressionSpecification)

#pragma mark - Queries

@property(nonatomic, readonly) BOOL aka_acceptsUnspecifiedAttributes;

- (BOOL)aka_typeConformsToSpecification:(Class)candidateType;

- (opt_NSDictionary)aka_specificationForAttributeWithName:(req_NSString)attributeName;

#pragma mark - Convenience

- (BOOL)aka_booleanForKey:(req_NSString)key withDefault:(BOOL)defaultValue;

@end
