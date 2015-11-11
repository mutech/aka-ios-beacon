//
//  AKABindingProvider.h
//  AKABeacon
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
#pragma mark -

/**
 The primary role of a binding provider is to provide a configured binding for a binding expression in a binding context.
 
 Binding providers are specific for the type of binding they provide and specify the binding expressions they support in order to semantically validate binding expressions and to set up bindings based on expressions.
 
 @note Sub classes are required to provide a static sharedInstance method, they have to override the specification property
 */
@interface AKABindingProvider: NSObject

#pragma mark - Initialization

/**
 Returns the shared instance for this binding provider type.
 
 The default implementation of AKABindingProvider throws an exception and should thus never be called. Use sharedInstanceOfType: or the sharedInstance: method of concrete sub classes.
 
 Sub classes have to override this method and provide a singleton instance (use dispatch_once).
 */
+ (nonnull instancetype)sharedInstance;

/**
 Returns the shared instance of the binding provider with the specified type.
 
 This is the preferred initialized for binding provider types which are not statically
 known (use [<SomeBindingProvider> sharedInstance] otherwise).

 @param type a sub class of AKABindingProvider.

 @return the shared instance of the specified binding provider type.
 */
+ (nullable instancetype)sharedInstanceOfType:(req_Class)type;

#pragma mark - Creating Bindings

// TODO: make binding context and result optional and add an error parameter instead:

/**
 Creates a new binding of the specified target to the source defined by the specified binding expression evaluated in the specified binding context; the binding will use the specified delegate.

 The binding provider will validate that the target and binding expression are valid according to the binding providers specification.

 @param target              the binding target (typically a view for view bindings)
 @param property            the target property defining the binding expression (mainly for reporting purposes)
 @param bindingExpression   the binding expression which (besides optional binding configuration) specifies the binding source.
 @param bindingContext      the binding context in which the binding expression will be evaluated. This is typically an instance of AKAControl owning the binding.
 @param delegate            the delegate responding to binding events. This is typically an instance of AKAControl owning the binding.

 @return a new binding
 */
- (req_AKABinding)  bindingWithTarget:(req_id)target
                             property:(opt_SEL)property
                           expression:(req_AKABindingExpression)bindingExpression
                              context:(req_AKABindingContext)bindingContext
                             delegate:(opt_AKABindingDelegate)delegate;


#pragma mark - Binding Expression Specification

/**
 The specification for bindings managed by this binding provider.
 
 @see AKABindingSpecification
 */
@property(nonatomic, readonly, nonnull) AKABindingSpecification* specification;

/**
 Returns the binding provider for the attribute with the specified name.

 @param attributeName the name of the attribute

 @return the binding provider for the specified attribute or nil if the attribute is used directly by enclosing bindings.
 */
- (opt_AKABindingProvider)providerForAttributeNamed:(req_NSString)attributeName;

/**
 Returns the binding provider for array items.
 
 @return the binding provider for array items or nil if the attribute is used directly by enclosing bindings.
 */
- (opt_AKABindingProvider)providerForBindingExpressionInPrimaryExpressionArray;

#pragma mark - Interface Builder Property Support

// TODO: move to AKAViewBindingProvider

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
- (void)                setBindingExpressionText:(opt_NSString)bindingExpressionText
                                     forSelector:(req_SEL)selector
                                          inView:(req_UIView)view;
@end
