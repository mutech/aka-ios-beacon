//
//  AKAClassConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAClassConstantBindingExpression.h"


#pragma mark - AKAClassConstantBindingExpression
#pragma mark -

@implementation AKAClassConstantBindingExpression

@dynamic constant;

#pragma mark - Initialization

- (instancetype _Nonnull)initWithConstant:(opt_Class)constant
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                            specification:(opt_AKABindingSpecification)specification
{
    self = [super initWithConstant:constant
                        attributes:attributes
                     specification:specification];

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeClassConstant;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSString* result = nil;
    opt_Class type = self.constant;

    if (type != nil)
    {
        result = [NSString stringWithFormat:@"<%@>", NSStringFromClass((req_Class)type)];
    }

    return result;
}

@end

