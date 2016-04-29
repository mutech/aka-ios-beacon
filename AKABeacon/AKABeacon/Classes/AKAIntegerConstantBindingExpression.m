//
//  AKAIntegerConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAIntegerConstantBindingExpression.h"


#pragma mark - AKAIntegerConstantBindingExpression
#pragma mark -

@implementation AKAIntegerConstantBindingExpression

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeIntegerConstant;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        result = [NSString stringWithFormat:@"%lld", self.constant.longLongValue];
    }

    return result;
}

@end
