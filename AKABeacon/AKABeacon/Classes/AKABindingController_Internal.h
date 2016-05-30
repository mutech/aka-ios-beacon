//
//  AKABindingController_Internal.h
//  AKABeacon
//
//  Created by Michael Utech on 24.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController.h"
#import "AKAKeyboardActivationSequence.h"


#pragma mark - AKABindingController - Internal Interface
#pragma mark -

// This header exposes implementation details to other AKABeacon components and is not supposed
// to be publically exposed or used. All interfaces may change without prior notice.

@interface AKABindingController()

#pragma mark - Initialization

/**
 Constructor for use by internal sub classes of AKABindingController.
 
 This constructor just initializes corresponding fields and does not add bindings or initialize the keyboard activation sequence.

 @note sub class initializers are required to initialize dataContextProperty right after calling this initializer. The data source property cannot be passed as parameter because it might need to reference the resulting controller.

 @param parent                parent property
 @param targetObjectHierarchy targetObjectHierarchy property
 @param delegate              delegate property
 @param error                 error details if the initialization failed.

 @return a new instance.
 */
- (opt_instancetype)                initWithParent:(opt_AKABindingController)parent
                             targetObjectHierarchy:(req_id)targetObjectHierarchy
                                          delegate:(opt_AKABindingControllerDelegate)delegate;

@end


#pragma mark - AKAIndependentBindingController - Internal Interface
#pragma mark -

/**
 Implementation of AKABindingController that references it's data context independently from its parent binding context. Independent binding controllers support changing the data context and they.
 
 Independent controllers are used as root binding controllers or as dynamic binding controllers managing dynamic view hierarchies such as table view cells.
 
 @note Independent binding controllers share the $root binding scope with their parent controllers.
 */
@interface AKAIndependentBindingController: AKABindingController

#pragma mark - Initialization

- (opt_instancetype)                initWithParent:(opt_AKABindingController)parent
                             targetObjectHierarchy:(req_id)targetObjectHierarchy
                                       dataContext:(opt_id)dataContext
                                          delegate:(opt_AKABindingControllerDelegate)delegate
                                             error:(out_NSError)error;


#pragma mark - Properties

@property(nonatomic, nullable) id                  dataContext;

@end


#pragma mark - AKADependentBindingController - Internal Interface
#pragma mark -

/**
 Implementation of AKABindingController that references it's data context relative to its parent's data context (typically in terms of key paths). Dependent binding controllers automatically update their data context whenever the corresponding value of the parent's data context changes and they do not support manual changes of the data context.

 Dependent controllers are used to change the data context of a view hierarchy or to group bindings to support managing them as unit.
 */
@interface AKADependentBindingController: AKABindingController

#pragma mark - Initialization

- (opt_instancetype)                initWithParent:(req_AKABindingController)parent
                             targetObjectHierarchy:(req_id)targetObjectHierarchy
                              dataContextAtKeyPath:(opt_NSString)keyPath
                                          delegate:(opt_AKABindingControllerDelegate)delegate
                                             error:(out_NSError)error;

@end