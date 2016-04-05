//
//  AKAViewBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;

#import "AKAViewBinding.h"
#import "AKABindingExpression+Accessors.h"


@implementation AKAViewBinding

@dynamic delegate;

#pragma mark - Initialization

- (instancetype)initWithView:(req_UIView)targetView
                  expression:(req_AKABindingExpression)bindingExpression
                     context:(req_AKABindingContext)bindingContext
                    delegate:(opt_AKABindingDelegate)delegate
                       error:(out_NSError)error
{
    [self validateTargetView:targetView];

    if (self = [super initWithTarget:[self createBindingTargetPropertyForView:targetView]
                          expression:bindingExpression
                             context:bindingContext
                            delegate:delegate
                               error:error])
    {
        _view = targetView;
    }

    return self;
}

- (void)validateTargetView:(req_UIView)targetView
{
    (void)targetView;
    NSParameterAssert([targetView isKindOfClass:[UIView class]]);
}


- (req_AKAProperty)createBindingTargetPropertyForView:(req_UIView)target
{
    (void)target;
    AKAErrorAbstractMethodImplementationMissing();
}

@end