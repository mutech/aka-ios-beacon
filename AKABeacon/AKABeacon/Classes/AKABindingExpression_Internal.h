//
//  AKABindingExpression_Internal.h
//  AKABeacon
//
//  Created by Michael Utech on 19.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABindingExpression.h"

#import "AKANullability.h"

@interface AKABindingExpression()

#pragma mark - Initialization

- (instancetype _Nullable)initWithPrimaryExpression:(opt_id)primaryExpression
                                         attributes:(opt_AKABindingExpressionAttributes)attributes
                                      specification:(opt_AKABindingSpecification)specification;

- (instancetype _Nonnull)initWithAttributes:(opt_AKABindingExpressionAttributes)attributes
                              specification:(opt_AKABindingSpecification)specification;


#pragma mark - Serialization

//@property(nonatomic, readonly, nullable)NSString* textForPrimaryExpression;

- (req_NSString)textForPrimaryExpressionWithNestingLevel:(NSUInteger)level
                                                  indent:(opt_NSString)indent;

- (req_NSString)textWithNestingLevel:(NSUInteger)level
                              indent:(opt_NSString)indent;

@end







