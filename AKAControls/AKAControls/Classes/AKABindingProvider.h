//
//  AKABindingProvider.h
//  AKAControls
//
//  Created by Michael Utech on 20.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;

@import AKACommons.AKANullability;

#import "AKABindingExpression.h"
#import "AKABinding.h"

@class AKABindingProvider;
typedef AKABindingProvider* _Nullable opt_AKABindingProvider;
typedef AKABindingProvider* _Nonnull  req_AKABindingProvider;

#pragma mark - AKABindingProvider - Public Interface

/**
 * A binding provider is in charge of instantiating bindings between a source specified
 * by a AKABindingExpression and a target that the provider knows about.
 *
 * Binding providers are also responsible to validate the semantics of binding expressions.
 *
 * @note Binding providers should be implemented as stateless singletons
 */
@interface AKABindingProvider: NSObject

#pragma mark - Interface Builder Property Support

/**
 * Gets the binding expression text associated with the specified property selector
 * of the specified view.
 *
 * @param selector the selector of a binding properties getter. The selector name will be used for KVC access to the property value.
 * @param view the view providing the binding property.
 *
 * @return the text of the binding expression or nil if the binding property is undefined.
 */
- (opt_NSString)bindingExpressionTextForSelector:(req_SEL)selector
                                          inView:(req_UIView)view;

/**
 * Associates the binding expression specified by the expression text with the specified
 * property select of the specified view. If the binding expression text is nil, the
 * binding property will be cleared.
 *
 * @warn Please note that an exception is thrown if the binding expression is invalid.
 *
 * @param bindingExpressionText A valid binding expression or nil.
 * @param selector the selector of a binding properties getter. The selector name will be used for KVC access to the property value.
 * @param view the view providing the binding property.
 */
- (void)                setBindingExpressionText:(req_NSString)bindingExpressionText
                                     forSelector:(req_SEL)selector
                                          inView:(req_UIView)view;

#pragma mark - Creating Bindings

- (req_AKABinding)  bindingWithView:(req_UIView)view
                         expression:(req_AKABindingExpression)bindingExpression
                            context:(req_AKABindingContext)bindingContext
                           delegate:(opt_AKABindingDelegate)delegate;

#pragma mark - Binding Expression Validation

/**
 * Validates the specified binding expression.
 *
 * @note Sub classes should not override this method and instead customize or override the
 *       more specialized validation methods for the primary binding expression and attributes
 *       respectively.
 *
 * @param bindingExpression the binding expression to valided
 * @param error if defined, error information will be stored here if validation fails.
 *
 * @return YES if the binding expression is valid, NO otherwise.
 */
- (BOOL)               validateBindingExpression:(req_AKABindingExpression)bindingExpression
                                           error:(out_NSError)error;

/**
 * Validates the primary (non-attributes) part of the specified binding expression.
 *
 * @param bindingExpression the binding expression to valided
 * @param error if defined, error information will be stored here if validation fails.
 *
 * @return YES if the binding expression is valid, NO otherwise.
 */
- (BOOL)        validatePrimaryBindingExpression:(req_AKABindingExpression)bindingExpression
                                           error:(out_NSError)error;

- (BOOL)   validateAttributesInBindingExpression:(req_AKABindingExpression)bindingExpression
                                           error:(out_NSError)error;

/**
 * Validates the specified binding expression as value for the attribute at the
 * specified key path.
 *
 * @param bindingExpression
 *      the binding expression to validate
 * @param attributeKeyPath
 *      the attributes key path relative to binding expressions handled by this provider.
 * @param targetBindingProvider
 *      the target binding provider which performed a prevalidation (or nil if no target provider
 *      manages the nested attribute).
 * @param targetBindingProviderKeyPath
 *      attribute key path of the binding expression that is controlled by the binding provider
 *      which performed the validation or nil if no target binding provider manages the nested
 *      attribute.
 * @param result
 *      the result of the target binding providers validation
 * @param error
 *      where to store error information, also contains error information possibly provided by the
 *      target binding provider.
 *
 * @return YES if the binding expression is valid for the specified attribute.
 */
- (BOOL)               validateBindingExpression:(req_AKABindingExpression)bindingExpression
                           forAttributeAtKeyPath:(req_NSString)attributeKeyPath
                                     validatedBy:(opt_AKABindingProvider)targetBindingProvider
                              atAttributeKeyPath:(opt_NSString)targetBindingProviderKeyPath
                                      withResult:(BOOL)result
                                           error:(out_NSError)error;

- (req_AKABindingProvider)providerForAttributeNamed:(req_NSString)attributeName;

/**
 * Returns the binding provider to be used to create and control the binding
 * expression of the attribute with the specified name.
 *
 * The default implementation creates a provider that uses the result of
 * @c targetBindingProviderForAttributeNamed: to implement most of the binding
 * provider services.
 *
 * @param attributeName <#attributeName description#>
 *
 * @return <#return value description#>
 */
- (opt_AKABindingProvider)targetProviderForAttributeAtKeyPath:(req_NSString)attributeKeyPath;

@end
