//
//  AKATransitionAnimationParametersPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 06.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKATransitionAnimationParametersPropertyBinding.h"
#import "AKABinding_Protected.h"
#import "AKANSEnumerations.h"


@implementation AKATransitionAnimationParametersPropertyBinding

+ (AKABindingSpecification*)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    [self registerEnumerationAndOptionTypes];

    dispatch_once(&onceToken, ^{
        NSDictionary* spec = @{
                               @"bindingType":          [AKATransitionAnimationParametersPropertyBinding class],
                               @"expressionType":       @(AKABindingExpressionTypeNone|AKABindingExpressionTypeAnyKeyPath),
                               @"attributes": @{
                                       @"duration": @{
                                               @"bindingType":     [AKAPropertyBinding class],
                                               @"expressionType":  @(AKABindingExpressionTypeNumber),
                                               @"use":             @(AKABindingAttributeUseBindToTargetProperty)
                                               },
                                       @"options": @{
                                               @"bindingType":     [AKAPropertyBinding class],
                                               @"expressionType":  @((AKABindingExpressionTypeOptionsConstant |
                                                                      AKABindingExpressionTypeAnyKeyPath)),
                                               @"optionsType":     @"UIViewAnimationOptions",
                                               @"use":             @(AKABindingAttributeUseBindToTargetProperty)
                                               },
                                       }
                               };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

+ (void)registerEnumerationAndOptionTypes
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        [AKABindingExpressionSpecification registerOptionsType:@"UIViewAnimationOptions"
                                              withValuesByName:[AKANSEnumerations
                                                                uiviewAnimationOptions]];
    });
}


- (AKAProperty *)defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                           context:(req_AKABindingContext)bindingContext
                                    changeObserver:(AKAPropertyChangeObserver)changeObserver
                                             error:(NSError *__autoreleasing  _Nullable *)error
{
    (void)bindingExpression;
    (void)bindingContext;
    (void)error;

    if (self.syntheticTargetValue == nil)
    {
        self.syntheticTargetValue = [AKATransitionAnimationParameters new];
    }
    AKAProperty* result = [AKAProperty propertyOfWeakKeyValueTarget:self
                                                            keyPath:@"syntheticTargetValue"
                                                     changeObserver:changeObserver];
    return result;
}

@end

