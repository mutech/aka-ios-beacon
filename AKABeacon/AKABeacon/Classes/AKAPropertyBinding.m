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
                                                            property:(opt_SEL)property
                                                          expression:(req_AKABindingExpression)bindingExpression
                                                             context:(req_AKABindingContext)bindingContext
                                                            delegate:(opt_AKABindingDelegate)delegate
                                                               error:(out_NSError)error
{
    NSParameterAssert([target isKindOfClass:[AKAProperty class]]);

    self = [super initWithTarget:target
                        property:property
                      expression:bindingExpression
                         context:bindingContext
                        delegate:delegate
                           error:error];

    return self;
}

@dynamic bindingTarget;

@end
