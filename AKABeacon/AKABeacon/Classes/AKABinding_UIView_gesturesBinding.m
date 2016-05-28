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

- (void)validateTarget:(req_id)target
{
    NSParameterAssert([target isKindOfClass:[UIView class]]);
}


- (AKAProperty*)createBindingTargetPropertyForTarget:(req_id)view
{
    (void)view;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    // The binding target property is only used to install/uninstall the tapGestureRecognizer on
    // observation start/stop. Getter and setter are not used.
    __weak typeof(self) weakSelf = self;
    return [AKAProperty propertyOfWeakTarget:view
                                      getter:
            ^id _Nullable(__unused req_id target)
            {
                return nil;
            }
                                      setter:
            ^(__unused req_id target, __unused opt_id value)
            {
                (void)target;
                (void)value;
            }
                          observationStarter:
            ^BOOL(__unused req_id target)
            {
                if (weakSelf.tapGestureRecognizer)
                {
                    [view addGestureRecognizer:weakSelf.tapGestureRecognizer];
                }
                return YES;
            }
                          observationStopper:
            ^BOOL(__unused req_id target)
            {
                if (weakSelf.tapGestureRecognizer)
                {
                    [view removeGestureRecognizer:weakSelf.tapGestureRecognizer];
                }
                return YES;
            }];
#pragma clang diagnostic pop
}

- (AKAProperty *)defaultBindingSourceForExpression:(req_AKABindingExpression __unused)bindingExpression
                                           context:(req_AKABindingContext __unused)bindingContext
                                    changeObserver:(AKAPropertyChangeObserver __unused)changeObserver
                                             error:(NSError *__autoreleasing  _Nullable * __unused)error
{
    return [AKAProperty constantNilProperty];
}

@end
