//
//  AKAKeyPathBindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingExpression.h"


@interface AKAKeyPathBindingExpression: AKABindingExpression

- (instancetype _Nonnull)initWithKeyPath:(opt_NSString)keyPath
                              attributes:(opt_AKABindingExpressionAttributes)attributes
                           specification:(opt_AKABindingSpecification)specification;

/**
 * The key path referencing the bindings source value relative to the defined scope.
 * If the key path is undefined, the scope (or constant) itself is used.
 */
@property(nonatomic, readonly, nullable) NSString* keyPath;

@end


@interface AKADataContextKeyPathBindingExpression: AKAKeyPathBindingExpression
@end


@interface AKARootDataContextKeyPathBindingExpression: AKAKeyPathBindingExpression
@end


@interface AKAControlKeyPathBindingExpression: AKAKeyPathBindingExpression
@end