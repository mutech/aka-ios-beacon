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
@dynamic target;

- (UIView *)target
{
    id result = super.target;

    NSAssert(result == nil || [result isKindOfClass:[UIView class]], @"Internal inconsistency: AKAViewBinding target has to be an instance of UIView");

    return result;
}

- (void)validateTarget:(req_id)target
{
    (void)target;
    NSParameterAssert([target isKindOfClass:[UIView class]]);
}

@end