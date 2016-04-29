//
//  AKAColorConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAColorConstantBindingExpression.h"
#import "AKANumberConstantBindingExpression.h"
#import "AKADoubleConstantBindingExpression.h"
#import "AKAIntegerConstantBindingExpression.h"
#import "AKABindingExpressionParser.h"
#import "AKABindingErrors.h"


#pragma mark - AKAColorConstantBindingExpression
#pragma mark -

@implementation AKAColorConstantBindingExpression

#pragma mark - Initialization

+ (NSNumber*) colorComponentWithKeys:(NSArray<NSString*>*)keys
                      fromAttributes:(opt_AKABindingExpressionAttributes)attributes
                            required:(BOOL)required
{
    NSNumber* result = nil;
    AKABindingExpression* expression = nil;
    NSString* providedKey = nil;

    for (NSString* key in keys)
    {
        expression = attributes[key];

        if (expression)
        {
            providedKey = key;
            break;
        }
    }

    if ([expression isKindOfClass:[AKADoubleConstantBindingExpression class]])
    {
        AKANumberConstantBindingExpression* numberExpression = (id)expression;
        double doubleValue = numberExpression.constant.doubleValue;

        if (doubleValue < 0 || doubleValue > 1.0)
        {
            NSString* message = [NSString stringWithFormat:@"Invalid value %lf for color component %@ (valid aliases: %@), floating point values have to be in range [0 .. 1.0]", doubleValue, keys.firstObject, [keys componentsJoinedByString:@", "]];
            @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        }
        else
        {
            // normalize double values to range [0 .. 255.0], this will be undone when both integer and
            // double values get normalized to range 0 .. 1.0.
            result = @(doubleValue * 255);
        }
    }
    else if ([expression isKindOfClass:[AKAIntegerConstantBindingExpression class]])
    {
        AKANumberConstantBindingExpression* numberExpression = (id)expression;
        NSInteger integerValue = numberExpression.constant.integerValue;

        if (integerValue < 0 || integerValue > 255)
        {
            NSString* message = [NSString stringWithFormat:@"Invalid value %ld for color component %@ (valid aliases: %@), integer values have to be in range [0 .. 255]", (long)integerValue, keys.firstObject, [keys componentsJoinedByString:@", "]];
            @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        }
        else
        {
            result = numberExpression.constant;
        }
    }
    else if (expression)
    {
        NSString* message = [NSString stringWithFormat:@"Invalid type %@ for color component %@, expected a numeric constant in range [0 .. 1.0]", NSStringFromClass(expression.class), providedKey];
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
    }

    if (result == nil && required)
    {
        NSString* message = [NSString stringWithFormat:@"No value for color component %@ (valid aliases: %@), expected a numeric constant in range [0 .. 1.0] (floating point) or [0 .. 255] (integer)", keys.firstObject, [keys componentsJoinedByString:@", "]];
        @throw [NSException exceptionWithName:message reason:message userInfo:nil];
    }

    return result;
}

- (instancetype)initWithConstant:(opt_id)constant
                      attributes:(opt_AKABindingExpressionAttributes)attributes
                   specification:(opt_AKABindingSpecification)specification
{
    UIColor* color = nil;

    if ([constant isKindOfClass:[UIColor class]])
    {
        color = constant;
    }

    if ((color && attributes.count > 0) || (!color && attributes.count == 0))
    {
        // TODO: add error parameter instead of throwing exception
        @throw [NSException exceptionWithName:@"Invalid specification of attributes for color definition. Attributes are required when no color is defined as primary expression and forbidden otherwise" reason:@"Attributes are required when no color is defined as primary expression and forbidden otherwise" userInfo:nil];
        self = nil;
    }
    else if (!color)
    {
        // colorComponentWithKeys... normalizes values to double or long long values to the range 0 .. 255(.0)
        // using the type information available from numeric constant binding expressions:

        CGFloat red = [AKAUIColorConstantBindingExpression colorComponentWithKeys:@[ @"r", @"red" ]
                                                                   fromAttributes:attributes
                                                                         required:YES].floatValue / 255.0f;
        CGFloat green = [AKAUIColorConstantBindingExpression colorComponentWithKeys:@[ @"g", @"green" ]
                                                                     fromAttributes:attributes
                                                                           required:YES].floatValue / 255.0f;
        CGFloat blue = [AKAUIColorConstantBindingExpression colorComponentWithKeys:@[ @"b", @"blue" ]
                                                                    fromAttributes:attributes
                                                                          required:YES].floatValue / 255.0f;
        NSNumber* nalpha = [AKAUIColorConstantBindingExpression colorComponentWithKeys:@[ @"a", @"alpha" ]
                                                                        fromAttributes:attributes
                                                                              required:NO];
        CGFloat alpha = nalpha ? nalpha.floatValue : 1.0;

        color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];

        // TODO: we could/should validate attributes to warn/fail on unknown keys
        if (attributes.count != (nalpha ? 4 : 3))
        {
            NSString* message = [NSString stringWithFormat:@"Unsupported color attribute (one of: %@); supported attributes are 'r' or 'red', 'g' or 'green', 'b' or 'blue' and 'a' or 'alpha'; (HSB/CMY not yet supported)", [attributes.allKeys componentsJoinedByString:@", "]];
            @throw [NSException exceptionWithName:message reason:message userInfo:nil];
        }
    }
    self = [super initWithConstant:color attributes:nil specification:specification];

    return self;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeAbstract;
}

#pragma mark - Access

- (UIColor*)UIColor
{
    return self.constant;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (NSString*)textForColorComponent:(CGFloat)component
{
    NSString* result = nil;

    // Convert component to byte value and determine if distance from  next integer is small enough
    // to allow representation as int:
    CGFloat channel = component * 255.0f;
    double integral;
    double fractional = modf(channel, &integral);

    // Greatest double/char conversion error in range [0..255] is for 128 with 0.000007569
    if (fractional < .00001)
    {
        // We represent numbers with a smaller error (leaving some margin for differences on
        // iOS hardware) as integer...
        result = [NSString stringWithFormat:@"%d", (int)integral];
    }
    else
    {
        // ... and everything else as double
        result = [NSString stringWithFormat:@"%lg", (double)component];
    }

    return result;
}

- (NSString*)textForConstant
{
    NSString* result = nil;

    if (self.constant)
    {
        UIColor* color = [self UIColor];
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        result = [NSString stringWithFormat:@"$%@ { r:%@, g:%@, b:%@, a:%@ }",
                  [self keyword],
                  [self textForColorComponent:red],
                  [self textForColorComponent:green],
                  [self textForColorComponent:blue],
                  [self textForColorComponent:alpha]];
    }
    
    return result;
}

@end


#pragma mark - AKAUIColorConstantBindingExpression
#pragma mark -

@implementation AKAUIColorConstantBindingExpression


#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeUIColorConstant;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [AKABindingExpressionParser keywordUIColor];
}

@end


#pragma mark - AKACGColorConstantBindingExpression
#pragma mark -

@implementation AKACGColorConstantBindingExpression

- (id)constant
{
    id result = super.constant;

    if ([result isKindOfClass:[UIColor class]])
    {
        // TODO: does it have to be retained here? Don't think so, check later
        result = (__bridge id)[(UIColor*)result CGColor];
    }

    return result;
}

- (UIColor*)UIColor
{
    return super.constant;
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeCGColorConstant;
}

#pragma mark - Serialization

- (NSString*)keyword
{
    return [AKABindingExpressionParser keywordCGColor];
}

@end
