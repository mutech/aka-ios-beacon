//
//  AKAPropertyBinding.h
//  AKAControls
//
//  Created by Michael Utech on 05.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKABinding.h"

@interface AKAPropertyBinding : AKABinding

#pragma mark - Initialization

- (instancetype)                                    initWithProperty:(req_AKAProperty)bindingTarget
                                                          expression:(req_AKABindingExpression)bindingExpression
                                                             context:(req_AKABindingContext)bindingContext
                                                            delegate:(opt_AKABindingDelegate)delegate;

@end
