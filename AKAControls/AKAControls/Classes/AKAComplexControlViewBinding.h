//
//  AKAComplexControlViewBinding.h
//  AKAControls
//
//  Created by Michael Utech on 19.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAControlViewBinding.h"

/**
 Common base class for composite and collection control view bindings.

 Complex control view bindings connect structured source data with complex control views. They differ from control bindings to scalar controls in that they manage changes to the content of their binding source data and (typically) not to the binding source data itself.

 For example, a typical composite control view bound to some object will contain member controls which edit properties of that object. A typical collection control view bound to an array will add, remove or reorder elements of the array and not replace the array itself.

 @note however that complex control views can act on their complex source data just like any other control view (a collection control view can for example replace, create or delete the array and a composite control can change the object it is operating on.
 */
@interface AKAComplexControlViewBinding: AKAControlViewBinding

@end
