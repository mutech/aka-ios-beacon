//
//  AKAConditionalBindingExpression.m
//  AKABeacon
//
//  Created by Michael Utech on 10.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "NSMutableString+AKATools.h"

#import "AKAConditionalBindingExpression.h"
#import "AKABindingExpression_Internal.h"
#import "AKABindingExpressionParser.h" // keywords

@implementation AKAConditionalBindingExpressionClause

+ (instancetype)whenClauseWithCondition:(req_AKABindingExpression)condition
                             expression:(req_AKABindingExpression)result
{
    return [[self alloc] initWithConditionBindingExpression:condition
                                                    negated:NO
                             resultBindingBindingExpression:result];
}

+ (instancetype)whenNotClauseWithCondition:(req_AKABindingExpression)condition
                                expression:(req_AKABindingExpression)result
{
    return [[self alloc] initWithConditionBindingExpression:condition
                                                    negated:YES
                             resultBindingBindingExpression:result];
}

+ (instancetype)elseClauseWithExpression:(req_AKABindingExpression)result
{
    return [[self alloc] initWithConditionBindingExpression:nil
                                                    negated:NO
                             resultBindingBindingExpression:result];
}

- (instancetype)initWithConditionBindingExpression:(AKABindingExpression *)condition
                                           negated:(BOOL)conditionNegated
                    resultBindingBindingExpression:(AKABindingExpression *)result
{
    self = [super init];
    if (self)
    {
        _conditionBindingExpression = condition;
        _isConditionNegated = conditionNegated;
        _resultBindingExpression = result;
    }

    return self;
}

@end


@implementation AKAConditionalBindingExpression

- (instancetype)initWithClauses:(NSArray<AKAConditionalBindingExpressionClause *> *)clauses
                  specification:(req_AKABindingSpecification)bindingSpecification
{
    if (self = [super initWithAttributes:nil
                           specification:bindingSpecification])
    {
        _clauses = clauses;
    }
    return self;
}

- (AKABindingExpressionType)expressionType
{
    return AKABindingExpressionTypeConditional;
}

- (NSString*)textForPrimaryExpressionWithNestingLevel:(NSUInteger)level
                                               indent:(NSString*)indent
{
    NSMutableString* result = [NSMutableString new];

    [self.clauses enumerateObjectsUsingBlock:
     ^(AKAConditionalBindingExpressionClause * _Nonnull clause,
       NSUInteger idx __unused, BOOL * _Nonnull stop __unused)
     {
         if (idx > 0)
         {
             if (indent.length)
             {
                 [result appendString:@"\n"];
                 [result aka_appendString:indent repeat:level];
             }
             else
             {
                 [result appendString:@" "];
             }
         }

         if (clause.conditionBindingExpression)
         {
             [result appendFormat:@"$%@(", (clause.isConditionNegated
                                            ? [AKABindingExpressionParser keywordWhenNot]
                                            : [AKABindingExpressionParser keywordWhen])];

             [result appendString:(req_NSString)clause.conditionBindingExpression.text];

             [result appendString:@")"];
         }
         else
         {
             [result appendFormat:@"$%@", [AKABindingExpressionParser keywordElse]];
         }

         if (indent.length)
         {
             [result appendString:@"\n"];
             [result aka_appendString:indent repeat:level+1];
         }
         else
         {
             [result appendString:@" "];
         }

         [result appendString:[clause.resultBindingExpression textWithNestingLevel:level + 1 indent:indent]];
     }];

    return result;
}

- (BOOL)                          validatePrimaryExpressionWithSpecification:(opt_AKABindingExpressionSpecification)specification
                                                                       error:(out_NSError)error
{
    BOOL result = YES;

    if (specification)
    {
        for (AKAConditionalBindingExpressionClause* clause in self.clauses)
        {
            result = [clause.resultBindingExpression validatePrimaryExpressionWithSpecification:specification
                                                                                          error:error];
            if (!result)
            {
                break;
            }
        }
    }

    return result;
}

- (BOOL)validateAttributesWithSpecification:(AKABindingExpressionSpecification*)specification
             overrideAllowUnknownAttributes:(BOOL)allowUnknownAttributes
                                      error:(NSError *_Nullable __autoreleasing *)error
{
    BOOL result = YES;

    for (AKAConditionalBindingExpressionClause* clause in self.clauses)
    {
        result = [clause.resultBindingExpression validateAttributesWithSpecification:specification
                                                      overrideAllowUnknownAttributes:allowUnknownAttributes
                                                                               error:error];
        if (!result)
        {
            break;
        }
    }

    return result;
}

@end
