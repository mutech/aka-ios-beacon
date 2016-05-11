//
//  AKAConditionalBindingExpression.h
//  AKABeacon
//
//  Created by Michael Utech on 10.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAControlStructureBindingExpression.h"

@interface AKAConditionalBindingExpressionClause: NSObject

+ (req_instancetype)whenClauseWithCondition:(req_AKABindingExpression)condition
                                     expression:(req_AKABindingExpression)result;

+ (req_instancetype)whenNotClauseWithCondition:(req_AKABindingExpression)condition
                                        expression:(req_AKABindingExpression)result;

+ (req_instancetype)elseClauseWithExpression:(req_AKABindingExpression)result;

@property(nonatomic, readonly, nullable) AKABindingExpression* conditionBindingExpression;
@property(nonatomic, readonly) BOOL                            isConditionNegated;
@property(nonatomic, readonly, nonnull)  AKABindingExpression* resultBindingExpression;

@property(nonatomic, readonly, nonnull) NSString*              keyword;


@end


@interface AKAConditionalBindingExpression : AKAControlStructureBindingExpression

- (req_instancetype)initWithClauses:(nonnull NSArray<AKAConditionalBindingExpressionClause*>*)clauses
                      specification:(req_AKABindingSpecification)bindingSpecification;


@property(nonatomic, readonly, nonnull) NSArray<AKAConditionalBindingExpressionClause*>* clauses;

@end
