//
//  AKAViewBinding.m
//  AKAControls
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKAErrors;

#import "AKAViewBinding.h"

@implementation AKAViewBinding

#pragma mark - Initialization

- (instancetype _Nullable)        initWithView:(req_UIView)target
                                    expression:(req_AKABindingExpression)bindingExpression
                                       context:(req_AKABindingContext)bindingContext
                                      delegate:(opt_AKABindingDelegate)delegate
{
    NSParameterAssert([target isKindOfClass:[UIView class]]);

    if (self = [super initWithTarget:[self createBindingTargetPropertyForView:target]
                          expression:bindingExpression
                             context:bindingContext
                            delegate:delegate])
    {
        _view = target;
    }
    return self;
}

- (req_AKAProperty)createBindingTargetPropertyForView:(req_UIView)target
{
    AKAErrorAbstractMethodImplementationMissing();
}

@end

