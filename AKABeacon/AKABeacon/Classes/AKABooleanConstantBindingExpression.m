//
//  AKABooleanConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingExpressionParser.h" // TODO: extract keywords from parser and put them in separate header

#import "AKABooleanConstantBindingExpression.h"


#pragma mark - AKABooleanConstantBindingExpression
#pragma mark -

@implementation AKABooleanConstantBindingExpression

+ (AKABooleanConstantBindingExpression*)constantTrue
{
    static AKABooleanConstantBindingExpression* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result = [[AKABooleanConstantBindingExpression alloc] initWithConstant:YES];
    });

    return result;
}

+ (AKABooleanConstantBindingExpression*)constantFalse
{
    static AKABooleanConstantBindingExpression* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        result = [[AKABooleanConstantBindingExpression alloc] initWithConstant:NO];
    });

    return result;
}

- (instancetype)initWithConstant:(BOOL)value
{
    self = [super initWithConstant:@(value)
                        attributes:nil
                     specification:nil];

    return self;
}

- (instancetype)initWithConstant:(opt_NSNumber)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                   specification:(opt_AKABindingSpecification)specification
{
    if (constant == nil || attributes.count > 0)
    {
        self = [super initWithConstant:constant attributes:attributes specification:specification];
    }
    else if (constant.boolValue)
    {
        self = [AKABooleanConstantBindingExpression constantTrue];
    }
    else
    {
        self = [AKABooleanConstantBindingExpression constantFalse];
    }

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeBooleanConstant;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        if (self.constant.boolValue)
        {
            result = [NSString stringWithFormat:@"$%@", [AKABindingExpressionParser keywordTrue]];
        }
        else
        {
            result = [NSString stringWithFormat:@"$%@", [AKABindingExpressionParser keywordFalse]];
        }
    }
    
    return result;
}

@end
