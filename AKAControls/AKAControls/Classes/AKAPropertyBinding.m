//
//  AKAPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 05.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAPropertyBinding.h"
#import "AKABindingProvider.h"

@implementation AKAPropertyBinding

#pragma mark - Initialization

- (instancetype)                                      initWithTarget:(id)target
                                                          expression:(req_AKABindingExpression)bindingExpression
                                                             context:(req_AKABindingContext)bindingContext
                                                            delegate:(opt_AKABindingDelegate)delegate
                                                               error:(out_NSError)error
{
    NSParameterAssert([target isKindOfClass:[AKAProperty class]]);

    return [self initWithProperty:target
                       expression:bindingExpression
                          context:bindingContext
                         delegate:delegate
                            error:error];
}

- (instancetype)                                    initWithProperty:(req_AKAProperty)bindingTarget
                                                          expression:(req_AKABindingExpression)bindingExpression
                                                             context:(req_AKABindingContext)bindingContext
                                                            delegate:(opt_AKABindingDelegate)delegate
                                                               error:(out_NSError)error
{
    self = [super initWithTarget:bindingTarget
                      expression:bindingExpression
                         context:bindingContext
                        delegate:delegate
                           error:error];

    return self;
}

@dynamic bindingTarget;

@end
