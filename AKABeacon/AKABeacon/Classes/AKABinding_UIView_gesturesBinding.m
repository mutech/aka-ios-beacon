//
//  AKABinding_UIView_gesturesBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 28.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_UIView_gesturesBinding.h"
#import "AKATapGestureRecognizerBinding.h"

@implementation AKABinding_UIView_gesturesBinding

+ (AKABindingSpecification *)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":          [AKABinding_UIView_gesturesBinding class],
           @"targetType":           [UIView class],
           @"expressionType":       @(AKABindingExpressionTypeNone),
           @"attributes":
               @{ @"tap":
                      @{ @"bindingType":    [AKATapGestureRecognizerBinding class],
                         @"use":             @(AKABindingAttributeUseBindToBindingProperty),
                         @"bindingProperty": @"tapGestureRecognizer",
                         },
                  }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    return result;
}

#pragma mark - Initialization

- (void)validateTargetView:(req_UIView)targetView
{
    NSParameterAssert([targetView isKindOfClass:[UIView class]]);
}


- (AKAProperty*)createBindingTargetPropertyForView:(req_UIView)view
{
    (void)view;
    // We might want to use some base style/theming mechanism here. For the time
    // being, the primary value is simply ignored and the binding target value too.
    __weak typeof(self) weakSelf = self;
    return [AKAProperty propertyOfWeakTarget:view
                                      getter:
            ^id _Nullable(req_id target)
            {
                return target;
            }
                                      setter:
            ^(req_id target, opt_id value)
            {
                (void)target;
                (void)value;
            }
                          observationStarter:
            ^BOOL(req_id target)
            {
                UIView* view = target;
                if (weakSelf.tapGestureRecognizer)
                {
                    [view addGestureRecognizer:weakSelf.tapGestureRecognizer];
                }
                return YES;
            }
                          observationStopper:
            ^BOOL(req_id target)
            {
                UIView* view = target;
                if (weakSelf.tapGestureRecognizer)
                {
                    [view removeGestureRecognizer:weakSelf.tapGestureRecognizer];
                }
                return YES;
            }];
}

- (AKAProperty *)defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                           context:(req_AKABindingContext)bindingContext
                                    changeObserver:(AKAPropertyChangeObserver)changeObserver
                                             error:(NSError *__autoreleasing  _Nullable *)error
{
    (void)bindingExpression;
    (void)bindingContext;
    (void)error;

    return [AKAProperty propertyOfWeakKeyValueTarget:nil keyPath:nil changeObserver:changeObserver];
}

@end
