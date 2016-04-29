//
//  AKAStringConstantBindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAConstantBindingExpression.h"

@interface AKAStringConstantBindingExpression: AKAConstantBindingExpression

- (instancetype _Nonnull)initWithConstant:(opt_NSString)constant
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                            specification:(opt_AKABindingSpecification)specification;

@property(nonatomic, readonly, nullable) NSString* constant;

@end
