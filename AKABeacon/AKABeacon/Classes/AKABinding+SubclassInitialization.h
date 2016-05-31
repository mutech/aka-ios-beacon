//
//  AKABinding+SubclassInitialization.h
//  AKABeacon
//
//  Created by Michael Utech on 28.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"

@interface AKABinding()

/**
 This can be used by bindings to strongly reference a target value that has been created (typically by source-to-target conversion) and needs to be preserved during the life time of the binding (f.e. because the target property does not keep a strong reference or uses a different internal representation).
 */
@property(nonatomic, strong, nullable) id syntheticTargetValue;

@end



@interface AKABinding (SubclassInitialization)

#pragma mark - Initialization

/**
 Initializes the binding for the specified target object.
 
 Subclasses should usually not have to override this initializer and instead customize or override the more specific initialization methods exposed in AKABinding+SubclassInitialization.h.
 
 One reason to override it would be to keep a (weak!) reference to the target object. AKAViewBinding does just that (recording the target UIView in the AKAViewBinding.target property).

 @param target            the target object
 @param bindingExpression the binding expression specifying the binding source and other parameters
 @param bindingContext    the binding context in which binding expressions are evaluated
 @param owner             the object which owns the binding. The owner will receive binding delegate calls if it implements the AKABindingDelegate protocol and is responsible to keep the binding alive for as long as it's needed.
 @param delegate          the binding delegate
 @param error             error details, has to be set whenever (and only if) the initializer returns nil.

 @return an instance of this binding type or nil.
 */
- (opt_instancetype)initWithTarget:(req_id)target
                        expression:(req_AKABindingExpression)bindingExpression
                           context:(req_AKABindingContext)bindingContext
                             owner:(opt_AKABindingOwner)owner
                          delegate:(opt_AKABindingDelegate)delegate
                             error:(out_NSError)error;

#pragma mark - Binding Type Validation

/**
 Validates that this binding type matches the specification of the binding expression.

 You should not need to override (or otherwise use) this method directly. It's used to transparently
 replace bindings, currently only to implement validation for AKAConditionalBinding.
 */
- (BOOL)                     validateBindingTypeWithExpression:(opt_AKABindingExpression)bindingExpression
                                                         error:(out_NSError)error;

#pragma mark - Binding Target Initialization and Validation

/**
 Called by initWithTarget:expression:context:owner:delegate:error: to check that a given target is valid.
 
 Subclasses which support initialization using targets (as opposed to target properties) have to implement this method and throw an exception if the target is not supported or otherwise invalid for use with the concrete binding type.
 
 The default implementation throws an exception indicating that the sub class failed to implement this method.

 @param target the target to validate.
 */
- (void)                                        validateTarget:(req_id)target;

/**
 Called by initWithTarget:expression:context:delegate:error: to obtain an instance of AKAProperty to be used as binding target for initWithTarget:expression:context:owner:delegate:error:

 Subclasses which support initialization using targets (as opposed to target properties) have to implement this method and return a property adapting the target (view or object) to a property which provides read/and/or/write access to the target value. (For example, AKABinding_UITextField_textBinding provides a property mapping the text field to its text value.

 The property also has to ensure that when the state of the target object changes in a way that affects the target value, this property will emit change events. A text field binding might have to attach to the text fields delegate or listen to control events to get notified about updates from the user.

 The default implementation throws an exception indicating that the sub class failed to implement this method.
 */
- (req_AKAProperty)         createTargetValuePropertyForTarget:(req_id)target;


#pragma mark - Binding Source Initialization
/// @name Binding Source Initialization

/**
 * Called by initWithTarget:targetValueProperty:expression:context:owner:delegate:error: to obtain a binding source property.
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
/// @name Binding Attribute Initialization

/**
 Initializes the attributes specified in the binding expression and processes them according to the binding expression specification provided by this binding type.

 You should typically not have to override this method, consider overriding the more specialized binding attribute initialization methods.

 @param bindingExpression the binding expression for this binding
 @param error             error storage, has to be set (if and only if) the implementation returns NO.

 @return YES if the attribute has been processed without error, NO otherwise.
 */
- (BOOL)                    initializeAttributesWithExpression:(req_AKABindingExpression)bindingExpression
                                                         error:(out_NSError)error;

/**
 Called by initializeAttributesWithExpression:error: for attributes with a specified use of AKABindingAttributeUseManually. The default implementation ignores the attribute.

 @param attributeName       the attribute's name
 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)                     initializeManualAttributeWithName:(req_NSString)attributeName
                                                 specification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                         error:(out_NSError)error;

/**
 Called by initializeAttributesWithExpression:error: for attributes with a specified use of AKABindingAttributeUseAssignValueToBindingProperty. The default implementation assignes the result of evaluating the attribute expression in the binding context to the binding (self)'s property using bindingProperty as key (KVC).

 @param bindingProperty     the property name of this object (self) to which the result of evaluating the binding expression is to be assigned to.
 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)     initializeBindingPropertyValueAssignmentAttribute:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                         error:(out_NSError)error;

/**
 Called by initializeAttributesWithExpression:error: for attributes with a specified use of AKABindingAttributeUseAssignValueToBindingProperty. The default implementation assignes the result of evaluating the attribute expression in the binding context to the binding (self)'s property using bindingProperty as key (KVC).

 @param bindingProperty     the property name of this object (self) to which the result of evaluating the binding expression is to be assigned to.
 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)initializeBindingPropertyEvaluatorAssignmentAttribute:(req_NSString)bindingProperty
                                            withSpecification:(req_AKABindingAttributeSpecification)specification
                                          attributeExpression:(req_AKABindingExpression)attributeExpression
                                                        error:(out_NSError)error;

/**
 Called by initializeAttributesWithExpression:error: for attributes with a specified use of AKABindingAttributeUseAssignEvalutorToBindingProperty. The default implementation creates an evaluator for the attribute expression and assigns the result to the binding (self)'s property using bindingProperty as key (KVC).

 @param bindingProperty     the property name of this object (self) to which the binding expression is to be assigned to.
 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)initializeBindingPropertyExpressionAssignmentAttribute:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                         error:(out_NSError)error;

- (BOOL)      initializeTargetPropertyValueAssignmentAttribute:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                         error:(out_NSError)error;

/**
 Called by initializeAttributesWithExpression:error: for attributes with a specified use of AKABindingAttributeUseBindToBindingProperty. The default implementation creates an attribute binding targeting the binding (self)'s property using bindingProperty as key.

 @param bindingProperty     the property name of this object (self) that the attribute binding will target.
 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)             initializeBindingPropertyBindingAttribute:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                         error:(out_NSError)error;

/**
 Called by initializeAttributesWithExpression:error: for attributes with a specified use of AKABindingAttributeUseBindToTargetProperty. The default implementation creates an attribute binding targeting the binding (self)'s binding target property (self.targetValueProperty's value) using bindingProperty as key.

 Please note that the targetValueProperty is not necessarily defined at the time when the binding attribute's binding is created.

 @param bindingProperty     the property name of this object's binding target that the attribute binding will target.
 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)              initializeTargetPropertyBindingAttribute:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                         error:(out_NSError)error;

/**
 Called by initializeAttributesWithExpression:error: if the binding does not specify the attribute. The default implementation does nothing and returns YES. Specific binding types handling unspecified attributes should override this method to process these.

 @param attributeName       the name of the attribute
 @param attributeExpression the binding expression of the attribute
 @param error               the error location to be set in case of errors

 @return YES if the attribute has been set up successfully, NO otherwise. Overriding classes have to set error accordingly if returning NO.
 */
- (BOOL)                        initializeUnspecifiedAttribute:(req_NSString)attributeName
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                         error:(out_NSError)error;

@end
