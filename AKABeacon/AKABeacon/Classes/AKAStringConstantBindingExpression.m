//
//  AKAStringConstantBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAStringConstantBindingExpression.h"

#pragma mark - AKAStringConstantBindingExpression
#pragma mark -

@implementation AKAStringConstantBindingExpression

@dynamic constant;

#pragma mark - Initialization

- (instancetype _Nonnull)initWithConstant:(opt_NSString)constant
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
    return AKABindingExpressionTypeStringConstant;
}

#pragma mark - Serialization

- (NSString*)textForConstant
{
    NSMutableString* result = nil;

    NSString* string = self.constant;

    if (string != nil)
    {
        result = [NSMutableString stringWithString:@"\""];
        for (NSUInteger i = 0; i < string.length; ++i)
        {
            unichar c = [string characterAtIndex:i];
            [AKAStringConstantBindingExpression appendEscapeSequenceForCharacter:c
                                                                 inMutableString:result];
        }
        [result appendString:@"\""];
    }

    return result;
}

+ (void)appendEscapeSequenceForCharacter:(unichar)character
                         inMutableString:(NSMutableString*)storage
{
    static NSDictionary<NSNumber*, NSString*>* map;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        map = @{ @((unichar)'\a'): @"\\a",
                 @((unichar)'\b'): @"\\b",
                 @((unichar)'\f'): @"\\f",
                 @((unichar)'\n'): @"\\n",
                 @((unichar)'\r'): @"\\r",
                 @((unichar)'\t'): @"\\t",
                 @((unichar)'\v'): @"\\v",
                 @((unichar)'\\'): @"\\\\",
                 @((unichar)'\''): @"\\'",
                 @((unichar)'"'):  @"\\\"",
                 @((unichar)'\?'): @"\\?", };
    });

    NSString* replacement = map[@(character)];

    if (replacement != nil)
    {
        [storage appendString:replacement];
    }
    else
    {
        [storage appendFormat:@"%C", character];
    }
}

@end


