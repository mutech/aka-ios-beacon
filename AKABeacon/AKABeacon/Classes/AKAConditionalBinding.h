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
@property(nonatomic, readonly) NSPredicate* predicate;
@property(nonatomic, readonly) AKABinding*  binding;

@end


@interface AKAConditionalBinding: AKABinding

- (opt_instancetype)initWithTarget:(req_id)targetObjectOrProperty
              resultBindingFactory:(opt_AKABinding(^_Nonnull)(req_id,
                                                              req_AKABindingExpression,
                                                              req_AKABindingContext,
                                                              opt_AKABindingDelegate,
                                                              out_NSError))resultBindingFactory
                 resultBindingType:(req_Class)resultBindingType
                        expression:(req_AKABindingExpression)bindingExpression
                           context:(req_AKABindingContext)bindingContext
                          delegate:(opt_AKABindingDelegate)delegate
                             error:(out_NSError)error;

@property(nonatomic, readonly) AKAConditionalBindingClause*           activeClause;

@property(nonatomic, readonly) NSArray<AKAConditionalBindingClause*>* clauses;

@end
