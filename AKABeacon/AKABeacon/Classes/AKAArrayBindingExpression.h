//
//  AKAArrayBindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingExpression.h"


@interface AKAArrayBindingExpression: AKABindingExpression

- (instancetype _Nonnull)initWithArray:(NSArray<AKABindingExpression*>*_Nullable)array
                            attributes:(opt_AKABindingExpressionAttributes)attributes
                         specification:(opt_AKABindingSpecification)specification;

@property(nonatomic, readonly, nullable) NSArray<AKABindingExpression*>* array;

@end
