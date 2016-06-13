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


@end



@interface AKABinding (Protected)

@end




