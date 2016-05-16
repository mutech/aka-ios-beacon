//
//  AKABindingExpressionEvaluator.h
//  AKABeacon
//
//  Created by Michael Utech on 14.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingExpression.h"
#import "AKAPropertyBinding.h"
#import "AKATableViewCellFactory.h"
#import "AKABindingContextProtocol.h"

/**
    Evaluates a binding expression in a binding context.
 */
@interface AKABindingExpressionEvaluator : NSObject

#pragma mark - Initialization

/**
 Initializes a new cell mapping. (...)

 @param bindingExpression a table view cell evaluationResult binding expression or a conforming conditional expression (using $when/$else) used to obtain a evaluationResult in a data context
 @param bindingContext    the table view's data source binding context
 @param delegate          the delegate used to set up the evaluationResult binding
 @param error             error details

 @return A new cell mapping or nil if the mapping could not initialize a evaluationResult binding
 */
- (nullable instancetype)initWithFactoryBindingExpression:(req_AKABindingExpression)bindingExpression
                                           bindingContext:(req_AKABindingContext)bindingContext
                                          bindingDelegate:(id<AKABindingDelegate>_Nullable)delegate
                                                    error:(out_NSError)error;

#pragma mark - Configuration

/**
 * The binding created from the bindingExpression specified to the initializer.
 */
@property(nonatomic, nonnull, readonly) AKABinding*                    binding;

#pragma mark - State

/**
 Determines if the evaluationResult binding is observing changes, which is the case while an evaluation is being performed (value or valueForDataContext:).
 */
@property(nonatomic, readonly) BOOL                       isObserving;

#pragma mark - Evaluation

/**
 * Evaluates the binding expression in a new child binding context using the specified data context ($data).
 *
 * @note: The evaluator is stateful and mutable and as a consequence not thread safe in the sense that at any time, only one evaluation (value or valueForDataContext:) can be performed.
 *
 * As a rule of thumb, evaluators should only be used in the main thread.
 */
- (opt_id)                            valueForDataContext:(id)dataContext;

/**
 * Evaluates the binding expression in the configured binding context.
 *
 * @note: The evaluator is stateful and mutable and as a consequence not thread safe in the sense that at any time, only one evaluation (value or valueForDataContext:) can be performed.
 *
 * As a rule of thumb, evaluators should only be used in the main thread.
 */
@property (nonatomic, readonly) opt_id                    value;

@end
