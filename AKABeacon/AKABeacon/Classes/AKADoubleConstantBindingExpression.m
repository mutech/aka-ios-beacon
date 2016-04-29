//
//  AKADoubleConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKADoubleConstantBindingExpression.h"


#pragma mark - AKADoubleConstantBindingExpression
#pragma mark -

@implementation AKADoubleConstantBindingExpression

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeDouble;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        result = [NSString stringWithFormat:@"%g", self.constant.doubleValue];
    }

    return result;
}

@end
