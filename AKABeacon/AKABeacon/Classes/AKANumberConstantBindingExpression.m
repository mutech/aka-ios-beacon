//
//  AKANumberConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKANumberConstantBindingExpression.h"


#pragma mark - AKANumberConstantBindingExpression
#pragma mark -

@implementation AKANumberConstantBindingExpression

@dynamic constant;

#pragma mark - Initialization

- (instancetype _Nonnull)initWithNumber:(opt_NSNumber)constant
                      attributes:(NSDictionary<NSString*, AKABindingExpression*>* __nullable)attributes
                   specification:(opt_AKABindingSpecification)specification
{
    return [super initWithConstant:constant
                        attributes:attributes
                     specification:specification];
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeAbstract;
}

#pragma mark - Serialization

- (opt_NSString)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        result = self.constant.stringValue;
    }

    return result;
}

@end

