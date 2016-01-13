//
//  AKABinding.h
//  AKABeacon
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKANullability;
@import AKACommons.AKAProperty;

#import "AKABindingDelegate.h"
#import "AKABindingExpression.h"
#import "AKABindingSpecification.h"

@class AKABinding;
@class AKAControlViewBinding;
@class AKAKeyboardControlViewBinding;
typedef AKABinding* _Nullable                               opt_AKABinding;
typedef AKABinding* _Nonnull                                req_AKABinding;
typedef AKAControlViewBinding* _Nullable                    opt_AKAControlViewBinding;
typedef AKAControlViewBinding* _Nonnull                     req_AKAControlViewBinding;
typedef AKAKeyboardControlViewBinding*_Nullable             opt_AKAKeyboardControlViewBinding;
typedef AKAKeyboardControlViewBinding*_Nonnull              req_AKAKeyboardControlViewBinding;


@protocol AKAControlViewBindingDelegate;

@interface AKABinding: NSObject<AKABindingDelegate>

#pragma mark - Initialization

/**
 Initializes a binding with the specified parameters.
 
 If an error occurs, the initializer returns nil and sets the error output parameter or, if the error storage is nil, throws an exception.

 @param target            the binding target (eg. a view or property)
 @param property          the binding target property defining the binding expression (if applicable)
 @param bindingExpression the binding expression
 @param bindingContext    the context in which the expression is evaluated
 @param delegate          the binding delegate
 @param error             error storage, if undefined, the initializer will throw an exception if an error is encountered.
 @throws NSException if an error occurred and the @c error parameter is nil.

 @return a new binding
 */
- (nullable instancetype)                    initWithTarget:(req_id)target
                                                   property:(opt_SEL)property
                                                 expression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                                   delegate:(opt_AKABindingDelegate)delegate
                                                      error:(out_NSError)error;

#pragma mark - Binding Source Initialization

- (opt_AKAProperty)              bindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                             changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                      error:(out_NSError)error;

- (opt_AKAProperty)       defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                             changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                      error:(out_NSError)error;

#pragma mark - Binding Attribute Initialization

- (BOOL)               setupAttributeBindingsWithExpression:(req_AKABindingExpression)bindingExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error;

/**
 Called by setupAttributeBindingsWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseManually. The default implementation ignores the attribute.

 @param attributeName       the attribute's name
 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param bindingContext      the binding context in which the attribute expression can be evaluated
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL              )setupAttributeBindingManuallyWithName:(req_NSString)attributeName
                                              specification:(req_AKABindingAttributeSpecification)specification
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error;

/**
 Called by setupAttributeBindingsWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseAssignValueToBindingProperty. The default implementation assignes the result of evaluating the attribute expression in the binding context to the binding (self)'s property using bindingProperty as key (KVC).

 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param bindingContext      the binding context in which the attribute expression can be evaluated
 @param bindingProperty     the property name of this object (self) to which the result of evaluating the binding expression is to be assigned to.
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)setupAttributeBindingByAssigningValueToBindingProperty:(req_NSString)bindingProperty
                                             withSpecification:(req_AKABindingAttributeSpecification)specification
                                           attributeExpression:(req_AKABindingExpression)attributeExpression
                                                bindingContext:(req_AKABindingContext)bindingContext
                                                         error:(out_NSError)error;

/**
 Called by setupAttributeBindingsWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseAssignExpressionToBindingProperty. The default implementation assigns the attribute expression (not the result of its evaluation) to the binding (self)'s property using  bindingProperty as key (KVC).

 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param bindingContext      not used by the default implementation, can be used if evaluation of the attribute expression is required in overriding sub classes
 @param bindingProperty     the property name of this object (self) to which the binding expression is to be assigned to.
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)setupAttributeBindingByAssigningExpressionToBindingProperty:(req_NSString)bindingProperty
                                                  withSpecification:(req_AKABindingAttributeSpecification)specification
                                                attributeExpression:(req_AKABindingExpression)attributeExpression
                                                     bindingContext:(req_AKABindingContext)bindingContext
                                                              error:(out_NSError)error;

- (BOOL)setupAttributeBindingByAssigningValueToTargetProperty:(req_NSString)bindingProperty
                                            withSpecification:(req_AKABindingAttributeSpecification)specification
                                          attributeExpression:(req_AKABindingExpression)attributeExpression
                                               bindingContext:(req_AKABindingContext)bindingContext
                                                        error:(out_NSError)error;

/**
 Called by setupAttributeBindingsWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseBindToBindingProperty. The default implementation creates an attribute binding targeting the binding (self)'s property using bindingProperty as key.

 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param bindingContext      the binding context in which the attribute expression can be evaluated
 @param bindingProperty     the property name of this object (self) that the attribute binding will target.
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)    setupAttributeBindingByBindingToBindingProperty:(opt_NSString)bindingProperty
                                          withSpecification:(req_AKABindingAttributeSpecification)specification
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error;

/**
 Called by setupAttributeBindingsWithExpression:bindingContext:error: for attributes with a specified use of AKABindingAttributeUseBindToTargetProperty. The default implementation creates an attribute binding targeting the binding (self)'s binding target property (self.bindingTarget's value) using bindingProperty as key.
 
 Please note that the bindingTarget is not necessarily defined at the time when the binding attribute's binding is created.

 @param specification       the attribute specification
 @param attributeExpression the binding expression defined for the attribute
 @param bindingContext      the binding context in which the attribute expression can be evaluated
 @param bindingProperty     the property name of this object's binding target that the attribute binding will target.
 @param error               storage for error information

 @return YES if the attribute value has been set up successfully.
 */
- (BOOL)             setupAttributeBindingWithSpecification:(req_AKABindingAttributeSpecification)specification
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                  byBindingToTargetProperty:(req_NSString)bindingProperty
                                                      error:(out_NSError)error;
/**
 Called by setupAttributeBindingsWithExpression:bindingContext:error: if the binding does not specify the attribute. The default implementation does nothing and returns YES. Specific binding types handling unspecified attributes should override this method to process these.

 @param attributeName       the name of the attribute
 @param attributeExpression the binding expression of the attribute
 @param bindingContext      the binding context in which the binding expression can be evaluated
 @param error               the error location to be set in case of errors

 @return YES if the attribute has been set up successfully, NO otherwise. Overriding classes have to set error accordingly if returning NO.
 */
- (BOOL)           setupUnspecifiedAttributeBindingWithName:(req_NSString)attributeName
                                        attributeExpression:(req_AKABindingExpression)attributeExpression
                                             bindingContext:(req_AKABindingContext)bindingContext
                                                      error:(out_NSError)error;

#if 0
/**
 Used by setupAttributeBindingsWithExpression:bindingContext:error: and related methods to store attribute bindings.

 @param binding       the attribute binding
 @param specification the attribute binding's specification (may be nil for unspecified attribute bindings and should otherwise not be nil).
 @param key           the key identifying the binding attribute, this is typically the binding or target property name.
 */
- (void)addAttributeBinding:(req_AKABinding)binding
          withSpecification:(opt_AKABindingAttributeSpecification)specification
                     forKey:(req_NSString)key;
#else
- (void)addBindingPropertyBinding:(req_AKABinding)binding;
- (void)addTargetPropertyBinding:(req_AKABinding)binding;
#endif

#pragma mark - Ad hoc binding application

+ (BOOL)applyBindingExpression:(req_AKABindingExpression)expression
                      toTarget:(req_id)target
                     inContext:(req_AKABindingContext)context
                         error:(out_NSError)error;

// TODO: review/refactor this; protected interface:
- (BOOL)applyToTargetOnce:(out_NSError)error;

#pragma mark - Configuration

@property(nonatomic, readonly, nonnull) AKAProperty*        bindingSource;
@property(nonatomic, readonly, nonnull) AKAProperty*        bindingTarget;
@property(nonatomic, readonly, nullable) SEL                bindingProperty;
@property(nonatomic, readonly, weak) id<AKABindingContextProtocol> bindingContext;
@property(nonatomic, readonly, weak) id<AKABindingDelegate> delegate;

#pragma mark - Conversion


- (BOOL)                                 convertSourceValue:(opt_id)sourceValue
                                              toTargetValue:(out_id)targetValueStore
                                                      error:(out_NSError)error;

#pragma mark - Validation

- (BOOL)                                validateSourceValue:(inout_id)sourceValueStore
                                                      error:(out_NSError)error;

- (BOOL)                                validateTargetValue:(inout_id)targetValueStore
                                                      error:(out_NSError)error;

#pragma mark - Change Tracking

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                                 toNewValue:(opt_id)newSourceValue;

- (BOOL)                              startObservingChanges;

- (BOOL)                               stopObservingChanges;

#pragma mark - Updating

/**
 Triggers an update of the target value from source.
 
 This can be used by subclasses to initialize the target value or to reset it, for example if configuration parameters have been changed and the target needs to be reinitialized.
 
 @note Please note that source value changes are tracked automatically and do not require this method to be called.
 */
- (void)                                  updateTargetValue;

@end

@interface AKABinding(BindingAttributeBindings)

#if 0
@property(nonatomic, readonly, nullable) NSDictionary<NSString*, AKABinding*>* attributeBindings;
@property(nonatomic, readonly, nullable) NSDictionary<NSString*, AKABindingAttributeSpecification*>* attributeBindingSpecifications;
#else
@property(nonatomic, readonly, nullable) NSArray<AKABinding*>* bindingPropertyBindings;
@property(nonatomic, readonly, nullable) NSArray<AKABinding*>* targetPropertyBindings;
#endif

@end

@interface AKABinding(Internal)

@property(nonatomic, readonly)BOOL isUpdatingTargetValueForSourceValueChange;

/**
 * Determines if the target (f.e. view-) value should be updated as a result of a changed
 * source (f.e. model-) value.
 *
 * @note: This is used before the corresponding delegate method is called and serves as
 *   shortcut to prevent update cycles. For this purpose, an unnecessary and potentially
 *   expensive conversion of source to target values is skipped. The default implementation
 *   returns YES.
 * @warning: Sub class redefining this method should always call the super implementation and never return YES if it returned NO.
 *
 * @param oldSourceValue the old source value
 * @param newSourceValue the new source value
 * @param sourceValue the new source value or the result of the source value validation replacing an invalid value.
 *
 * @return YES if the target value should be updated, NO otherwise.
 */
- (BOOL)              shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
                                                validatedTo:(opt_id)sourceValue;

@end


@interface AKABinding(BindingSpecification)

#pragma mark - Binding Expression Specification

+ (req_AKABindingSpecification)     specification;

+ (opt_AKABindingAttributeSpecification)specificationForAttributeNamed:(req_NSString)attributeName;

+ (opt_Class)bindingTypeForBindingExpressionInPrimaryExpressionArray;

//+ (opt_Class)bindingTypeForAttributeNamed:(req_NSString)attributeName;

@end

