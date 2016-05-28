//
//  AKABindingController+BindingInitialization.h
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController.h"

#pragma mark - AKABindingController(BindingInitialization) - Private Interface
#pragma mark -

@interface AKABindingController(BindingInitialization)

/**
 Scans the targetObjectHierarchy recursively for binding expressions and creates bindings for them.

 @note This is done as part of the initialization of the controller. After the initialization, binding controllers typically do not add or remove bindings. Dynamic addition or removal of bindings is handled by child view controllers.

 @param rootTarget      The root of the binding target hierarchy (typically a view hierarchy).
 @param excludedTargets Targets (sub trees) which should be ignored (typically root views of child view controllers).
 @param error           Error details

 @return YES if all bindings have been created succesfully, NO if at least one binding creation failed or another error occured. The state of the binding controllers and its bindings is undefined if an error occurs, the controller should be discarded.
 */
- (BOOL)           addBindingsForTargetObjectHierarchy:(req_id)rootTarget
                                  excludeTargetObjects:(req_NSSet)excludedTargets
                                                 error:(out_NSError)error;

@end
