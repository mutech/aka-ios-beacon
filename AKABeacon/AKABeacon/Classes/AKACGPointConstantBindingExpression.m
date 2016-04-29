//
//  AKACGPointConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKACGPointConstantBindingExpression.h"
#import "AKANumberConstantBindingExpression.h"
#import "AKABindingExpressionParser.h"


#pragma mark - AKACGPointConstantBindingExpression
#pragma mark -

@implementation AKACGPointConstantBindingExpression

#pragma mark - Initialization



- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                   specification:(opt_AKABindingSpecification)specification
{
    NSValue* value = nil;

    if ([constant isKindOfClass:[NSValue class]])
    {
        NSParameterAssert(strcmp([((NSValue*)constant) objCType], @encode(CGPoint)) == 0);
        value = constant;
    }

    if ((value && attributes.count > 0) || (!value && attributes.count == 0))
    {
        // TODO: add error parameter instead of throwing exception
        NSString* message = @"Invalid specification of attributes for CGPoint. Attributes are required when no point is defined as primary expression and forbidden otherwise";
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        self = nil;
    }
    else if (!value)
    {
        CGFloat x = [AKAStructConstantBindingExpression coordinateWithKeys:@[ @"x" ]
                                                            fromAttributes:attributes
                                                                  required:YES].floatValue;
        CGFloat y = [AKAStructConstantBindingExpression coordinateWithKeys:@[ @"y" ]
                                                            fromAttributes:attributes
                                                                  required:YES].floatValue;
        value = [NSValue valueWithCGPoint:CGPointMake(x, y)];
    }
    self = [super initWithConstant:value attributes:nil specification:specification];

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeCGPointConstant;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [AKABindingExpressionParser keywordCGPoint];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        CGPoint value = ((NSValue*)self.constant).CGPointValue;
        result = [NSString stringWithFormat:@"$%@ { x:%g, y:%g }", [self keyword], value.x, value.y];
    }
    
    return result;
}

@end

