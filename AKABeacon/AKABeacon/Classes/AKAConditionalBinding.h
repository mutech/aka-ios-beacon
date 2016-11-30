//
//  AKAConditionalBinding.h
//  AKABeacon
//
//  Created by Michael Utech on 10.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"
#import "AKAConditionalBindingExpression.h"


@interface AKAConditionalBindingClause: NSObject

@property(nonatomic, readonly) NSUInteger   expressionClauseIndex;
@property(nonatomic, readonly, nullable) NSPredicate* predicate;
@property(nonatomic, readonly, nullable) AKABinding*  binding;

@end


@interface AKAConditionalBinding: AKABinding

- (opt_instancetype)initWithTarget:(opt_id)target
                 resultBindingType:(req_Class)resultBindingType
                        expression:(req_AKABindingExpression)bindingExpression
                           context:(req_AKABindingContext)bindingContext
                             owner:(opt_AKABindingOwner)owner
                          delegate:(opt_AKABindingDelegate)delegate
                             error:(out_NSError)error;

- (opt_instancetype)initWithTarget:(opt_id)target
               targetValueProperty:(req_AKAProperty)targetValueProperty
                 resultBindingType:(req_Class)resultBindingType
                        expression:(req_AKABindingExpression)bindingExpression
                           context:(req_AKABindingContext)bindingContext
                             owner:(opt_AKABindingOwner)owner
                          delegate:(opt_AKABindingDelegate)delegate error:(out_NSError)error;

@property(nonatomic, readonly, nullable) AKAConditionalBindingClause*           activeClause;

@property(nonatomic, readonly, nonnull) NSArray<AKAConditionalBindingClause*>* clauses;

@end
