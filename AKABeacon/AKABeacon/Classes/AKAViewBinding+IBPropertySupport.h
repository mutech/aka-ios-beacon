//
//  AKAViewBinding+IBPropertySupport.h
//  AKABeacon
//
//  Created by Michael Utech on 24.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAViewBinding.h"

@interface AKAViewBinding (IBPropertySupport)

/**
 * Gets the binding expression text associated with the specified property selector
 * of the specified view.
 *
 * @param selector the selector of a binding properties getter. The selector name will be used for KVC access to the property value.
 * @param view the view providing the binding property.
 *
 * @return the text of the binding expression or nil if the binding property is undefined.
 */
+ (opt_NSString)           bindingExpressionTextForSelector:(req_SEL)selector
                                                     inView:(req_id)view;

/**
 * Associates the binding expression specified by the expression text with the specified
 * property select of the specified view. If the binding expression text is nil, the
 * binding property will be cleared.
 *
 * @warn Please note that an exception is thrown if the binding expression is invalid.
 *
 * @param bindingExpressionText A valid binding expression or nil.
 * @param selector the selector of a binding properties getter. The selector name will be used for KVC access to the property value.
 * @param view the view providing the binding property.
 */
+ (void)                           setBindingExpressionText:(opt_NSString)bindingExpressionText
                                                forSelector:(req_SEL)selector
                                                     inView:(req_id)view;

@end
