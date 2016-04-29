//
//  AKAArrayBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.NSMutableString_AKATools;

#import "AKAArrayBindingExpression.h"


#pragma mark - AKAArrayBindingExpression
#pragma mark -

@implementation AKAArrayBindingExpression

#pragma mark - Initialization

- (instancetype)initWithArray:(NSArray<AKABindingExpression*>*)array
                   attributes:(opt_AKABindingExpressionAttributes)attributes
                specification:(opt_AKABindingSpecification)specification
{
    if (self = [super initWithAttributes:attributes
                           specification:specification])
    {
        _array = array;
    }

    return self;
}

- (instancetype)initWithPrimaryExpression:(opt_id)primaryExpression
                               attributes:(opt_AKABindingExpressionAttributes)attributes
                            specification:(opt_AKABindingSpecification)specification
{
    NSAssert(primaryExpression == nil || [primaryExpression isKindOfClass:[NSArray class]], @"AKAArrayBindingExpression requires a primary expression of type NSArray, got %@", primaryExpression);

    return [self initWithArray:(NSArray*)primaryExpression
                    attributes:attributes
                 specification:specification];
}

#pragma mark - Properties

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeArray;
}

#pragma mark - Binding Support

- (opt_AKAProperty)bindingSourcePropertyInContext:(req_AKABindingContext)bindingContext
                                    changeObserer:(opt_AKAPropertyChangeObserver)changeObserver
{
    (void)bindingContext;
    opt_AKAProperty result = nil;
    opt_id target = self.array;

    NSAssert(target != nil, @"Array binding expression delivered an undefined (nil) array, the binding's source will, probably unexpectedly, be undefined.");

    if (target)
    {
        result = [AKAProperty propertyOfWeakKeyValueTarget:(req_id)target
                                                   keyPath:nil
                                            changeObserver:changeObserver];
    }

    return result;
}

- (opt_id)bindingSourceValueInContext:(req_AKABindingContext)bindingContext
{
    (void)bindingContext;
    return self.array;
}

#pragma mark - Diagnostics

- (NSString*)constantStringValueOrDescription
{
    return @"(array expression)";
}

#pragma mark - Serialization

- (NSString*)textForPrimaryExpressionWithNestingLevel:(NSUInteger)level
                                               indent:(NSString*)indent
{
    static NSString*const kArrayOpen = @"[";
    static NSString*const kArrayClose = @"]";
    static NSString*const kArrayItemSeparator = @",";

    NSMutableString* result = [NSMutableString new];

    [result appendString:kArrayOpen];
    NSString* itemPrefix;

    if (indent.length > 0)
    {
        itemPrefix = @"\n";
    }
    else
    {
        itemPrefix = @" ";
    }

    if (self.array.count > 0)
    {
        NSUInteger count = self.array.count;
        [self.array
         enumerateObjectsUsingBlock:
         ^(AKABindingExpression* _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop)
         {
             (void)stop;
             NSString* itemText = [obj textWithNestingLevel:level + 1
                                                     indent:indent];

             [result appendString:itemPrefix];
             [result aka_appendString:indent
                               repeat:level + 1];

             [result appendString:itemText];

             if (idx < count - 1)
             {
                 [result appendString:kArrayItemSeparator];
             }
         }];
    }

    [result appendString:itemPrefix];
    [result aka_appendString:indent repeat:level];
    [result appendString:kArrayClose];
    
    return result;
}

@end

