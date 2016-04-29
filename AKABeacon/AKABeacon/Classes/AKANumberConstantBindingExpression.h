//
//  AKANumberConstantBindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAConstantBindingExpression.h"


@interface AKANumberConstantBindingExpression: AKAConstantBindingExpression

- (instancetype _Nonnull)  initWithNumber:(opt_NSNumber)constant
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                            specification:(opt_AKABindingSpecification)specification;

@property(nonatomic, readonly, nullable) NSNumber* constant;

@end
