//
//  AKABinding_Protected.h
//  AKABeacon
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"

@interface AKABinding (Protected)


#pragma mark - Properties

@property(nonatomic, readonly, nullable) NSArray<AKABinding*>*      arrayItemBindings;
@property(nonatomic, readonly, nullable) NSArray<AKABinding*>*      bindingPropertyBindings;
@property(nonatomic, readonly, nullable) NSArray<AKABinding*>*      targetPropertyBindings;
@property(nonatomic, nullable) id                                   syntheticTargetValue;

#pragma mark - Sub Bindings

- (void)                                    addArrayItemBinding:(req_AKABinding)binding;

- (void)                              addBindingPropertyBinding:(req_AKABinding)binding;

- (void)                               addTargetPropertyBinding:(req_AKABinding)binding;

#pragma mark - Binding Source Initialization

- (opt_AKAProperty)                 bindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                       context:(req_AKABindingContext)bindingContext
                                                changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                         error:(out_NSError)error;

- (opt_AKAProperty)          defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                       context:(req_AKABindingContext)bindingContext
                                                changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                         error:(out_NSError)error;

#pragma mark - Binding Attribute Initialization

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
   Called by initializeAttributesWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseAssignExpressionToBindingProperty. The default implementation assigns the attribute expression (not the result of its evaluation) to the binding (self)'s property using  bindingProperty as key (KVC).

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

@end
