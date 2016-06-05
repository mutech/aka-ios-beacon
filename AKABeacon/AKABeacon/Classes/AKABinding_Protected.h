//
//  AKABinding_Protected.h
//  AKABeacon
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"

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
- (opt_instancetype)initWithTarget:(opt_id)target targetValueProperty:(req_AKAProperty)targetValueProperty
                        expression:(req_AKABindingExpression)bindingExpression
                           context:(req_AKABindingContext)bindingContext owner:(opt_AKABindingOwner)owner
                          delegate:(opt_AKABindingDelegate)delegate error:(out_NSError)error;


#pragma mark - Obscure

// This should become delegate support methods or probably just be removed unless really needed

/**
 Called when a sub binding created from an attribute configured for use AKABindingAttributeUseBindToBindingProperty changed the value of the configured property of this binding.

 @param bindingPropertyName the properties name (KVC key).
 @param oldValue            the properties value before the change
 @param newValue            the properties new value
 */
- (void)                                    bindingProperty:(req_NSString)bindingPropertyName
                                                      value:(opt_id)oldValue
                                        didChangeToNewValue:(opt_id)newValue;

/**
 Called when a sub binding created from an attribute configured for use AKABindingAttributeUseBindToTargetProperty changed the value of the configured property of this binding's target value.

 @param bindingPropertyName the properties name (KVC key).
 @param oldValue            the properties value before the change
 @param newValue            the properties new value
 */
- (void)                                     targetProperty:(req_NSString)bindingPropertyName
                                                      value:(opt_id)oldValue
                                        didChangeToNewValue:(opt_id)newValue;

@end



@interface AKABinding (Protected)

#pragma mark - Properties

//@property(nonatomic, readonly, nonnull)  id<AKABindingDelegate>     delegateForSubBindings;

@end




