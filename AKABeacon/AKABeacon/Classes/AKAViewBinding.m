//
//  AKAViewBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAErrors.h"

#import "AKAViewBinding.h"
#import "AKABindingExpression+Accessors.h"
#import "AKAConditionalBinding.h"
#import "AKABinding_Protected.h"

@implementation AKAViewBinding

@dynamic delegate;

#pragma mark - Initialization

+ (opt_AKABinding)bindingToView:(req_UIView)targetView
                 withExpression:(req_AKABindingExpression)bindingExpression
                        context:(req_AKABindingContext)bindingContext
                       delegate:(opt_AKABindingDelegate)delegate
                          error:(out_NSError)error
{
    if (bindingExpression.expressionType == AKABindingExpressionTypeConditional)
    {
        AKABindingSpecification* specification = [self specification];

        AKAConditionalBinding* result = [AKAConditionalBinding alloc];
        result = [result initWithTarget:targetView
                   resultBindingFactory:
                  ^AKABinding * _Nullable(req_id                    rTarget,
                                          req_AKABindingExpression  rExpression,
                                          req_AKABindingContext     rContext,
                                          opt_AKABindingDelegate    rDelegate,
                                          out_NSError               rError)
                  {
                      AKAViewBinding* resultBinding = [specification.bindingType alloc];
                      return [resultBinding initWithView:rTarget
                                              expression:rExpression
                                                 context:rContext
                                                delegate:rDelegate
                                                   error:rError];

                  }
                      resultBindingType:self
                             expression:bindingExpression
                                context:bindingContext
                               delegate:delegate
                                  error:error];
        return result;
    }
    else
    {
        return [[self alloc] initWithView:targetView
                               expression:bindingExpression
                                  context:bindingContext
                                 delegate:delegate
                                    error:error];
    }
}

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