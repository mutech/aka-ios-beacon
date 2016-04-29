//
//  AKACGSizeConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKACGSizeConstantBindingExpression.h"

#import "AKABindingExpressionParser.h"

#pragma mark - AKACGSizeConstantBindingExpression
#pragma mark -

@implementation AKACGSizeConstantBindingExpression

#pragma mark - Initialization

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                   specification:(opt_AKABindingSpecification)specification
{
    NSValue* value = nil;

    if ([constant isKindOfClass:[NSValue class]])
    {
        NSParameterAssert(strcmp([((NSValue*)constant) objCType], @encode(CGRect)) == 0);
        value = constant;
    }

    if ((value && attributes.count > 0) || (!value && attributes.count == 0))
    {
        // TODO: add error parameter instead of throwing exception
        NSString* message = @"Invalid specification of attributes for CGRect. Attributes are required when no rectangle is defined as primary expression and forbidden otherwise";
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        self = nil;
    }
    else if (!value)
    {
        CGFloat w = [AKAStructConstantBindingExpression coordinateWithKeys:@[ @"w", @"width" ]
                                                            fromAttributes:attributes
                                                                  required:YES].floatValue;
        CGFloat h = [AKAStructConstantBindingExpression coordinateWithKeys:@[ @"h", @"height" ]
                                                            fromAttributes:attributes
                                                                  required:YES].floatValue;
        value = [NSValue valueWithCGSize:CGSizeMake(w, h)];
    }
    self = [super initWithConstant:value attributes:nil specification:specification];

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeCGSizeConstant;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [AKABindingExpressionParser keywordCGSize];
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        CGSize value = ((NSValue*)self.constant).CGSizeValue;
        result = [NSString stringWithFormat:@"$%@ { w:%g, h:%g }", [self keyword], value.width, value.height];
    }

    return result;
}

@end

