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
#import "AKABindingSpecification.h"
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

#pragma mark - Initialization

/**
 * Returns the shared instance for this binding provider type. The default implementation
 * of AKABindingProvider throws an exception and should thus never be called. Use
 * @c [AKABindingProvider sharedInstanceOfType:<ConcreteBindingProvider class>] or
 * [ConcreteBindingProvider sharedInstance] to access the instance of a concrete
 * binding provider type.
 */
+ (instancetype _Nonnull)sharedInstance;

/**
 * Returns the shared instance of the binding provider with the specified type.
 *
 * @param type a Class which is a sub class of AKABindingProvider which implements
 *      @c sharedInstance method.
 *
 * @return the shared instance of the specified binding provider type.
 */
+ (instancetype _Nullable)sharedInstanceOfType:(req_Class)type;

/**
 * Returns the shared instance defined by the specification item.
 *
 * @param spec either in instance or a subclass of AKABindingProvider
 *
 * @return the specified instance or the shared instance of the specified type or
 *      nil if the specification item is undefined.
 */
+ (instancetype _Nullable)sharedInstanceForSpecificationItem:(opt_id)spec;

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

- (req_AKABinding)  bindingWithTarget:(req_id)target
                           expression:(req_AKABindingExpression)bindingExpression
                              context:(req_AKABindingContext)bindingContext
                             delegate:(opt_AKABindingDelegate)delegate;

#pragma mark - Binding Expression Specification

@property(nonatomic, readonly, nonnull) AKABindingSpecification* specification;

- (opt_AKABindingProvider)providerForAttributeNamed:(req_NSString)attributeName;

- (opt_AKABindingProvider)providerForBindingExpressionInPrimaryExpressionArray;

@end
