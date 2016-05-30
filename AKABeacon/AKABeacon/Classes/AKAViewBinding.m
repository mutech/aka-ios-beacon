//
//  AKAViewBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAErrors.h"

#import "AKAViewBinding.h"
#import "AKABinding+SubclassInitialization.h"
#import "AKABindingExpression+Accessors.h"
#import "AKAConditionalBinding.h"
#import "AKABinding_Protected.h"

@implementation AKAViewBinding

@dynamic delegate;

#pragma mark - Initialization

- (instancetype)initWithTarget:(req_id)target
                    expression:(req_AKABindingExpression)bindingExpression
                       context:(req_AKABindingContext)bindingContext
                      delegate:(opt_AKABindingDelegate)delegate
                         error:(out_NSError)error
{
    if (self = [super initWithTarget:target
                          expression:bindingExpression
                             context:bindingContext
                            delegate:delegate
                               error:error])
    {
        _view = target;
    }

    return self;
}

- (void)validateTarget:(req_id)target
{
    (void)target;
    NSParameterAssert([target isKindOfClass:[UIView class]]);
}

@end