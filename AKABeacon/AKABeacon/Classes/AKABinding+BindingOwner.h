//
//  AKABinding+BindingOwner.h
//  AKABeacon
//
//  Created by Michael Utech on 28.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"
#import "AKABindingOwnerProtocol.h"

/*
 Bindings may create and own bindings. Currently these are bindings for elements of array binding expressions and bindings for binding expression attributes which are connected to binding- or target properties (properties of this binding object or the target object associated with the binding).
 
 These sub binding are typically static in the sense that they won't change after the binding is initialized. There are however some binding types which may add bindings dynamically (f.e. the table view data source binding when using dynamic sections).
 
 The three types of sub bindings are managed seperately because their change tracking has to be started in the correct order (target property bindings require a target, binding property bindings have to start observing changes early, array item bindings have to start when the binding source observation started).
 */

@interface AKABinding (BindingOwner) <AKABindingOwnerProtocol>

- (void)                                    addArrayItemBinding:(req_AKABinding)binding;

- (void)                                removeArrayItemBindings;

- (void)                              addBindingPropertyBinding:(req_AKABinding)binding;

- (void)                               addTargetPropertyBinding:(req_AKABinding)binding;

@end
