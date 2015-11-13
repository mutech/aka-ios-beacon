//
//  AKABindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 18.09.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//
@import Foundation;
@import AKACommons.AKANullability;

#import "AKABindingContextProtocol.h"
#import "AKABindingSpecification.h"


@class AKABindingExpression;
typedef AKABindingExpression* _Nullable opt_AKABindingExpression;
typedef AKABindingExpression* _Nonnull req_AKABindingExpression;
typedef AKABindingExpression* __autoreleasing _Nullable* _Nullable out_AKABindingExpression;

typedef NSDictionary<NSString*, AKABindingExpression*>* _Nullable opt_AKABindingExpressionAttributes;
typedef NSDictionary<NSString*, AKABindingExpression*>* _Nonnull req_AKABindingExpressionAttributes;

typedef enum AKABindingExpressionScope* _Nullable out_AKABindingExpressionScope;

@class AKABindingProvider;
typedef AKABindingProvider* _Nonnull req_AKABindingProvider;


/**
   A binding expression specifies the source value of a binding.
 */
@interface AKABindingExpression: NSObject

#pragma mark - Initialization
/// @name Initialization

/**
   Initializes a binding expression with the specified expression text using the binding provider for validation.

   The expression text has to conform to this grammar:

     <bindingExpression> ::= <primaryExpression> <attributes>? |
                             <compositeExpression> <attributes> |
                             "$options" <attributes>? | "$options." <optionsType> <attributes>?

     <attributes>

     <primaryExpression> ::= <constantExpression> | <keyPathExpression> | <arrayExpression> |


     <constantExpression> ::= <booleanExpression> | <integerExpression> | <doubleExpression> |
                              <enumExpression>  | <stringExpression> | <classExpression>

     <booleanExpression> ::= "$true" | "$false"

     <integerExpression> ::= [+-]?[0-9]+

     <doubleExpression> ::= _C double with at least a decimal point_

     <enumConstant> ::= "$enum" | "$enum." <enumerationValue> | "enum." <type> "." <enumerationValue>

     <optionsConstant> ::=

     <stringExpression> ::= '"' <escapedCharacter> '"'

     <classExpression> ::= '<' <identifier> '>'

     <compositeExpression> ::= "$UIColor" | "$CGColor" | "$CGPoint" | "$CGSize" | "$CGRect" |
     "$UIFont"

     <keyPathExpression> ::= <keyPath> | <scope> | <scope> '.' <keyPath>

     <keyPath> ::= _see Apple documentation_

     <scope> ::= '$data' | '$root' | '$control'

     <attributes> ::= '{' <attributeList>? '}'

     <attributeList> ::= <attribute> | <attributeList> ',' <attribute>

     <attribute> ::= <identifier> | <identifier> ':' <bindingExpression>

   @param expressionText  the expression text.
   @param bindingProvider the binding provider, used for semantic validation
   @param error           parser and semantic error will be stored here

   @return an initialized binding expression equivalent to the specified expressionText.
 */
+ (instancetype _Nullable)          bindingExpressionWithString:(req_NSString)expressionText
                                                bindingProvider:(req_AKABindingProvider)bindingProvider
                                                          error:(out_NSError)error;

#pragma mark - Properties
/// @name Properties

/**
   Determines the type of the binding expression's primary expression.
 */
@property(nonatomic, readonly) AKABindingExpressionType         expressionType;

/**
   Determines whether the binding expression is constant. Constant binding expressions can be evaluated without (or with an undefined) binding context.
 */
@property(nonatomic, readonly) BOOL                             isConstant;

/**
   A string value representing the constant value of the binding expression.
 */
@property(nonatomic, readonly) opt_NSString                     constantStringValueOrDescription;

/**
   The serialized form of the binding expression.

   Please note that there is no guarantee that this equals the string that was used to define the binding expression. The text will however produce an equivalent binding expression when parsed again.
 */
@property(nonatomic, readonly, nonnull) NSString*               text;

/**
   The binding provider associated with this binding expression.
 */
@property(nonatomic, readonly, weak, nullable) AKABindingProvider* bindingProvider;

/**
   Additional named binding expressions which are used by the binding provider processing this binding expression to setup bindings.

   The semantics of binding attributes are defined by binding providers.
 */
@property(nonatomic, readonly, nullable) opt_AKABindingExpressionAttributes attributes;

#pragma mark - Validation

- (BOOL)                              validateWithSpecification:(opt_AKABindingExpressionSpecification)specification
                                                          error:(out_NSError)error;

- (BOOL)                          validatePrimaryExpressionType:(AKABindingExpressionType)expressionType
                                                          error:(out_NSError)error;

- (BOOL)                    validateAttributesWithSpecification:(opt_AKABindingExpressionSpecification)specification
                                                          error:(out_NSError)error;

#pragma mark - Binding Support
/// @name Binding Support

/**
   Convenience method creating a property for the primary expression evaluated in the specified bindingContext using the specified changeObserver.

   @note that constant binding expressions provide a defined result independent of the bindingContext. Key path expressions require a defined bindingContext. Array expressions require a defined bindingContext if any of the array items are non-constant expressions.

   @note the default implementation always returns nil (instances of AKABindingExpression do not have a primary expression, those of subclasses typically do), subclasses implementing specific primary expression types have to redefine this method.

   @param bindingContext the binding context in which the primary expression will be evaluated
   @param changeObserver called whenever the resulting properties value changes

   @return a property or nil if the expression does not have a primary expression.
 */
- (opt_AKAProperty)              bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                                  changeObserer:(opt_AKAPropertyChangeObserver)changeObserver;

/**
   Convenience method evaluating the binding expression's primary expression in the specified binding context.

   @see bindingSourcePropertyInContext:changeObserver:

   @param bindingContext the binding context in which the primary expression is evaluated.

   @return the primary expression value
 */
- (opt_id)                          bindingSourceValueInContext:(req_AKABindingContext)bindingContext;

/**
   Convenience method creating a property for the primary expression evaluated in the specified bindingContext using the specified changeObserver.

   @note that constant binding expressions provide a bound property. Key path expressions will return an unbound property, you can access the value by calling [AKAUnboundProperty valueForTarget:] with an appropriate target object.

   @note the default implementation always returns nil (instances of AKABindingExpression do not have a primary expression, those of subclasses typically do), subclasses implementing specific primary expression types have to redefine this method.

   @return a property or nil if the expression does not have a primary expression.
 */
- (opt_AKAUnboundProperty)bindingSourceUnboundPropertyInContext:(req_AKABindingContext)bindingContext;

@end