//
//  AKAViewBinding_Protected.h
//  AKABeacon
//
//  Created by Michael Utech on 11.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_Protected.h"

@interface AKAViewBinding(Protected)

- (opt_instancetype)                           initWithView:(req_UIView)targetView
                                                 expression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                                   delegate:(opt_AKABindingDelegate)delegate
                                                      error:(out_NSError)error;


/**
 Abstract method that subclasses have to implement to return an AKAProperty instance
 that provides access to the binding target value.

 @param target the target view

 @return a property providing access to the binding target value.
 */
- (req_AKAProperty)      createBindingTargetPropertyForView:(req_UIView)target;

/**
 Called by initWithView:expression:context:delegate, this method can be used to validate
 the targetView and should throw an exception or fail with an assertion if the targetView
 is invalid.

 @param targetView the view to validate.
 */
- (void)                                 validateTargetView:(req_UIView)targetView;

@end

