//
//  UIView+AKABindingSupport.h
//  AKAControls
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit.UIView;
@import AKACommons.AKANullability;
@import AKACommons.AKAReference;

#import "AKABindingExpression.h"

@class AKABinding;


#pragma mark - UIView+AKABindingSupport - Public Interface
#pragma mark -

/**
 * Provides methods to loosely associate binding expressions to views implementing the storage
 * facility for binding properties which can be added to existing views by defining categories.
 *
 * Binding support methods defined here are typically used through AKABindingProviders which
 * take care of parsing and serializing binding expressions.
 */
@interface UIView(AKABindingSupport)

/**
 * The names of all properties of this view which define a binding expression.
 */
@property(nonatomic, readonly, nullable) NSArray<NSString*>* aka_definedBindingPropertyNames;

/**
 * The binding expression associated with the specified property or @c nil if the property
 * does not have a defined binding expression.
 *
 * @param selector the selector identifying the properties getter.
 *
 * @return the binding expression associated with the specified property.
 */
- (opt_AKABindingExpression)aka_bindingExpressionForProperty:(req_SEL)selector;

- (opt_AKABindingExpression)aka_bindingExpressionForPropertyNamed:(req_NSString)key;

- (void)aka_setBindingExpression:(opt_AKABindingExpression)bindingExpression
                     forProperty:(req_SEL)selector;

- (void)aka_setBindingExpression:(opt_AKABindingExpression)bindingExpression
                forPropertyNamed:(req_NSString)key;

@end
