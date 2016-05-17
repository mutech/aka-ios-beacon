//
//  AKABinding_Protected.h
//  AKABeacon
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"

// Extension publishing methods available to sub classes only.
@interface AKABinding()

#pragma mark - Initialization

/**
 Initializes a binding with the specified parameters.

 If an error occurs, the initializer returns nil and sets the error output parameter or, if the error storage is nil, throws an exception.

 Subclasses typically do not need to override this initializer, because most of the initialization process
 is performed by
 @param target            the binding target
 @param bindingExpression the binding expression
 @param bindingContext    the context in which the expression is evaluated
 @param delegate          the binding delegate
 @param error             error storage, if undefined, the initializer will throw an exception if an error is encountered.
 @throws NSException if an error occurred and the @c error parameter is nil.

 @return a new binding
 */
- (opt_instancetype)                                 initWithTarget:(req_AKAProperty)target
                                                         expression:(req_AKABindingExpression)bindingExpression
                                                            context:(req_AKABindingContext)bindingContext
                                                           delegate:(opt_AKABindingDelegate)delegate
                                                              error:(out_NSError)error;

/**
 Validates that this binding type matches the specification of the binding expression.

 You should not need to override (or otherwise use) this method directly. It's used to transparently
 replace bindings, currently only to implement validation for AKAConditionalBinding.
 */
- (BOOL)                          validateBindingTypeWithExpression:(opt_AKABindingExpression)bindingExpression
                                                              error:(out_NSError)error;

@end



@interface AKABinding (Protected)

#pragma mark - Properties

@property(nonatomic, readonly, nonnull)  id<AKABindingDelegate>     delegateForSubBindings;
@property(nonatomic, nullable) NSArray<AKABinding*>*                arrayItemBindings;
@property(nonatomic, readonly, nullable) NSArray<AKABinding*>*      bindingPropertyBindings;
@property(nonatomic, readonly, nullable) NSArray<AKABinding*>*      targetPropertyBindings;
@property(nonatomic, nullable) id                                   syntheticTargetValue;

#pragma mark - Sub Bindings

- (void)                                    addArrayItemBinding:(req_AKABinding)binding;
- (void)                                removeArrayItemBindings;

- (void)                              addBindingPropertyBinding:(req_AKABinding)binding;

- (void)                               addTargetPropertyBinding:(req_AKABinding)binding;

#pragma mark - Binding Source Initialization
/// @name Binding Source Initialization

/**
 * Called by initWithTarget:expression:context:delegate:error: to obtain a binding source property.
 *
 * If the binding expression has no defined primary value, this method will call defaultBindingSourceForExpression:context:changeObserver:error:.
 *
 * If the binding expression is a manifest array, bindingSourceForArrayExpression:context:changeObserver:error: will be called.
 */
- (opt_AKAProperty)                 bindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                       context:(req_AKABindingContext)bindingContext
                                                changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                         error:(out_NSError)error;

/**
 * Called by bindingSourceForExpression:context:changeObserver:error: if the binding expression's type is AKABindingExpression or the binding's expressionType is AKABindingExpressionTypeNone, both indicating that the binding expression does not deliver a primary expression value.
 *
 * The default implementation throws an exception. Bindings which accept an empty primary expression (for example because they can synthesize a source value based on attributes such as AKAFormatterPropertyBindings) have to override this method and return an instance of AKAProperty. This property may synthesize a source value, return nil or some other value.
 *
 * @param bindingExpression the expression that is an instance of AKABindingExpression or has the expressionType AKABindingExpressionTypeNone
 * @param bindingContext the context in which expressions are evaluated
 * @param changeObserver the resulting property is expected to call this block whenever the source value provided by the property changes.
 * @param error used to store error information explaining why the result is nil.
 *
 * @returns A property providing the binding's source value or nil if an error occurred.
 */
- (opt_AKAProperty)          defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                       context:(req_AKABindingContext)bindingContext
                                                changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                         error:(out_NSError)error;

- (opt_AKAProperty)            bindingSourceForArrayExpression:(req_AKABindingExpression)bindingExpression
                                                       context:(req_AKABindingContext)bindingContext
                                                changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                         error:(out_NSError)error;

#pragma mark - Binding Attribute Initialization

// Initialization routines for binding attributes. You can override these to perform additional or
// alternative actions to setup you bindings for binding attributes.

- (BOOL)                    initializeAttributesWithExpression:(req_AKABindingExpression)bindingExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(out_NSError)error;

/**
   Called by initializeAttributesWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseManually. The default implementation ignores the attribute.

   @param attributeName       the attribute's name
   @param specification       the attribute specification
   @param attributeExpression the binding expression defined for the attribute
   @param bindingContext      the binding context in which the attribute expression can be evaluated
   @param error               storage for error information

   @return YES if the attribute value has been set up successfully.
 */
- (BOOL)                     initializeManualAttributeWithName:(req_NSString)attributeName
                                                 specification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(out_NSError)error;

/**
   Called by initializeAttributesWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseAssignValueToBindingProperty. The default implementation assignes the result of evaluating the attribute expression in the binding context to the binding (self)'s property using bindingProperty as key (KVC).

   @param specification       the attribute specification
   @param attributeExpression the binding expression defined for the attribute
   @param bindingContext      the binding context in which the attribute expression can be evaluated
   @param bindingProperty     the property name of this object (self) to which the result of evaluating the binding expression is to be assigned to.
   @param error               storage for error information

   @return YES if the attribute value has been set up successfully.
 */
- (BOOL)     initializeBindingPropertyValueAssignmentAttribute:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(out_NSError)error;

/**
 Called by initializeAttributesWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseAssignValueToBindingProperty. The default implementation assignes the result of evaluating the attribute expression in the binding context to the binding (self)'s property using bindingProperty as key (KVC).

 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param bindingContext      the binding context in which the attribute expression can be evaluated
 @param bindingProperty     the property name of this object (self) to which the result of evaluating the binding expression is to be assigned to.
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)initializeBindingPropertyEvaluatorAssignmentAttribute:(req_NSString)bindingProperty
                                            withSpecification:(req_AKABindingAttributeSpecification)specification
                                          attributeExpression:(req_AKABindingExpression)attributeExpression
                                               bindingContext:(req_AKABindingContext)bindingContext
                                                        error:(out_NSError)error;

/**
   Called by initializeAttributesWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseAssignEvalutorToBindingProperty. The default implementation creates an evaluator for the attribute expression and assigns the result to the binding (self)'s property using bindingProperty as key (KVC).

   @param specification       the attribute specification
   @param attributeExpression the binding expression defined for the attribute
   @param bindingContext      not used by the default implementation, can be used if evaluation of the attribute expression is required in overriding sub classes
   @param bindingProperty     the property name of this object (self) to which the binding expression is to be assigned to.
   @param error               storage for error information

   @return YES if the attribute value has been set up successfully.
 */
- (BOOL)initializeBindingPropertyExpressionAssignmentAttribute:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(out_NSError)error;

- (BOOL)      initializeTargetPropertyValueAssignmentAttribute:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(out_NSError)error;

/**
   Called by initializeAttributesWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseBindToBindingProperty. The default implementation creates an attribute binding targeting the binding (self)'s property using bindingProperty as key.

   @param specification       the attribute specification
   @param attributeExpression the binding expression defined for the attribute
   @param bindingContext      the binding context in which the attribute expression can be evaluated
   @param bindingProperty     the property name of this object (self) that the attribute binding will target.
   @param error               storage for error information

   @return YES if the attribute value has been set up successfully.
 */
- (BOOL)             initializeBindingPropertyBindingAttribute:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(out_NSError)error;

/**
   Called by initializeAttributesWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseBindToTargetProperty. The default implementation creates an attribute binding targeting the binding (self)'s binding target property (self.bindingTarget's value) using bindingProperty as key.

   Please note that the bindingTarget is not necessarily defined at the time when the binding attribute's binding is created.

   @param specification       the attribute specification
   @param attributeExpression the binding expression defined for the attribute
   @param bindingContext      the binding context in which the attribute expression can be evaluated
   @param bindingProperty     the property name of this object's binding target that the attribute binding will target.
   @param error               storage for error information

   @return YES if the attribute value has been set up successfully.
 */
- (BOOL)              initializeTargetPropertyBindingAttribute:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(out_NSError)error;

/**
   Called by initializeAttributesWithExpression:bindingContext:error: if the binding does not specify the attribute. The default implementation does nothing and returns YES. Specific binding types handling unspecified attributes should override this method to process these.

   @param attributeName       the name of the attribute
   @param attributeExpression the binding expression of the attribute
   @param bindingContext      the binding context in which the binding expression can be evaluated
   @param error               the error location to be set in case of errors

   @return YES if the attribute has been set up successfully, NO otherwise. Overriding classes have to set error accordingly if returning NO.
 */
- (BOOL)                        initializeUnspecifiedAttribute:(req_NSString)attributeName
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(out_NSError)error;

#pragma mark - Change Tracking

#pragma mark Observation start process events

// These methods are entry points that sub classes can override to perform additional actions during
// the observation start process. When overriding these methods, you should always call the corresponding
// super implementation.

/**
 Called before the binding will start observing changes.
 */
- (void)willStartObservingChanges;

/**
 Called before the binding's sub bindings targeting binding properties will start observing changes.
 */
- (void)willStartObservingBindingPropertyBindings;

/**
 Called after the binding's sub bindings targeting binding properties change observation started.
 */
- (void)didStartObservingBindingPropertyBindings;

/**
 Called before the binding's target property starts observing changes.
 */
- (void)willStartObservingBindingTarget;

/**
 Called after the binding's target properties change observation started.
 */
- (void)didStartObservingBindingTarget;

/**
 Called before the binding's source property starts observing changes.
 */
- (void)willStartObservingBindingSource;

/**
 Called after the binding's source properties change observation started.
 */
- (void)didStartObservingBindingSource;

/**
 Called before the bindings target value will be initialized as part of the observation start process.
 */
- (void)willInitializeTargetValueForObservationStart;

/**
 Called after the bindings target value has been initialized as part of the observation start process.
 */
- (void)didInitializeTargetValueForObservationStart;

/**
 Called before the binding's sub bindings targeting the binding target's properties start observing changes.
 */
- (void)willStartObservingBindingTargetPropertyBindings;

/**
 Called after the binding's sub bindings targeting the binding target's properties change observation started.
 */
- (void)didStartObservingBindingTargetPropertyBindings;

/**
 Called after the bindings change observation started.
 */
- (void)didStartObservingChanges;


- (void)willSopObservingChanges;

- (void)willStopObservingBindingPropertyBindings;

- (void)didStopObservingBindingPropertyBindings;

- (void)willStopObservingBindingTarget;

- (void)didStopObservingBindingTarget;

- (void)willStopObservingBindingSource;

- (void)didStopObservingBindingSource;

- (void)willStopObservingBindingTargetPropertyBindings;

- (void)didStopObservingBindingTargetPropertyBindings;

- (void)didStopObservingChanges;

@end


#pragma mark - AKABinding Delegate Support Implementation
#pragma mark -

// 
@interface AKABinding(DelegateSupport)

- (void)             targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                                     toTargetValueWithError:(opt_NSError)error;

- (void)            targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                                   convertedFromSourceValue:(opt_id)sourceValue
                                                  withError:(opt_NSError)error;

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                             toInvalidValue:(opt_id)newSourceValue
                                                  withError:(opt_NSError)error;

- (BOOL)              shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
                                                validatedTo:(opt_id)sourceValue;

- (BOOL)                            shouldUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
                                             forSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue;

- (void)                              willUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue;

- (void)                               didUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue;

- (void)                             targetArrayItemAtIndex:(NSUInteger)index
                                         valueDidChangeFrom:(opt_id)oldValue
                                                         to:(opt_id)newValue;

- (void)                             sourceArrayItemAtIndex:(NSUInteger)index
                                         valueDidChangeFrom:(opt_id)oldValue
                                                         to:(opt_id)newValue;

- (void)                                            binding:(req_AKABinding)binding
                           sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                                         to:(opt_id)newSourceValue;

@end


