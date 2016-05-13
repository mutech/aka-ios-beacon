//
//  AKAConstantBindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingExpression.h"


@interface AKAConstantBindingExpression: AKABindingExpression

- (instancetype _Nonnull)initWithConstant:(opt_id)constant
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                            specification:(opt_AKABindingSpecification)specification;

@property(nonatomic, readonly, nullable) id constant;

@property(nonatomic, readonly, nullable) NSString* textForConstant;

@end
