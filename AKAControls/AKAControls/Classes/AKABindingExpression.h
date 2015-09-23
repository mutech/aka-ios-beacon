//
//  AKABindingExpression.h
//  AKAControls
//
//  Created by Michael Utech on 18.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import Foundation;
@import AKACommons.AKANullability;

#import "AKABindingContextProtocol.h"

@class AKABindingProvider;
@class AKABindingExpression;

typedef AKABindingExpression* _Nullable                             opt_AKABindingExpression;
typedef AKABindingExpression* __nonnull                             req_AKABindingExpression;
typedef AKABindingExpression*__autoreleasing __nullable*__nullable  out_AKABindingExpression;
typedef NSDictionary<NSString*,AKABindingExpression*>*_Nullable     opt_AKABindingExpressionAttributes;
typedef enum AKABindingExpressionScope*_Nullable                    out_AKABindingExpressionScope;
typedef AKABindingProvider* _Nonnull                                req_AKABindingProvider;

/**
 * A binding expression specifies the source value of a binding.
 *
 * The source value is obtained by applying a key path to the object identified
 * by the binding's expressions scope, which can be the binding's data context (@c $data),
 * the root data context (@c $root), the bindings control (@c $control) a constant
 * (for example @c $123, $"string", $(1.23), $true, $false) or unspecified.
 *
 * If the scope is not specified, the default scope defined by the controlling
 * binding provider is used. In most cases, the default scope is @c $data.
 *
 * If no key path is defined, the scope itself serves as source value.
 *
 * In addition to the source value, a binding expression can contain attribute
 * specifications. A binding attribute is a named binding expression. The semantics
 * of attributes is defined by binding providers.
 */
@interface AKABindingExpression : NSObject


+ (instancetype _Nullable) bindingExpressionWithString:(req_NSString)expressionText
                                       bindingProvider:(req_AKABindingProvider)bindingProvider
                                                 error:(out_NSError)error;

#pragma mark - Properties

/**
 * The serialized form of the binding expression. Please note that there is no guarantee
 * that this equals the string that was (possibly) used to define the binding expression.
 * The text will however produce an equivalent binding expression when parsed again.
 */
@property(nonatomic, readonly, nonnull) NSString* text;

/**
 * The binding provider associated with this binding expression.
 */
@property(nonatomic, readonly, nullable) AKABindingProvider* bindingProvider;

/**
 * Additional named binding expressions which are used by the binding provider processing
 * this binding expression to customize aspects of the binding. The semantics of binding
 * attributes are defined by binding providers.
 */
@property(nonatomic, readonly, nullable) NSDictionary<NSString*, AKABindingExpression*>* attributes;

#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver;

@end