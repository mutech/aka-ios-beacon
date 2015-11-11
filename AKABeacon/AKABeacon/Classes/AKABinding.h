//
//  AKABinding.h
//  AKABeacon
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKANullability;
@import AKACommons.AKAProperty;

#import "AKABindingDelegate.h"
#import "AKABindingExpression.h"

@class AKABinding;
@class AKAControlViewBinding;
@class AKAKeyboardControlViewBinding;
typedef AKABinding* _Nullable                               opt_AKABinding;
typedef AKABinding* _Nonnull                                req_AKABinding;
typedef AKAControlViewBinding* _Nullable                    opt_AKAControlViewBinding;
typedef AKAControlViewBinding* _Nonnull                     req_AKAControlViewBinding;
typedef AKAKeyboardControlViewBinding*_Nullable             opt_AKAKeyboardControlViewBinding;
typedef AKAKeyboardControlViewBinding*_Nonnull              req_AKAKeyboardControlViewBinding;

@protocol AKAControlViewBindingDelegate;


@interface AKABinding: NSObject

#pragma mark - Initialization

/**
 Initializes a binding with the specified binding target, expression, context and delegate.
 
 If an error occurs, the initializer returns nil and sets the error output parameter or, if the error storage is nil, throws an exception.

 @param target            the binding target (eg. a view or property)
 @param property          the binding target property defining the binding expression (if applicable)
 @param bindingExpression the binding expression
 @param bindingContext    the context in which the expression is evaluated
 @param delegate          the binding delegate
 @param error             error storage, if undefined, the initializer will throw an exception if an error is encountered.
 @throws NSException if an error occurred and the @c error parameter is nil.

 @return a new binding
 */
- (nullable instancetype)                    initWithTarget:(req_id)target
                                                   property:(opt_SEL)property
                                                 expression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                                   delegate:(opt_AKABindingDelegate)delegate
                                                      error:(out_NSError)error;

/**
 Sets up the binding source for the specified binding expression and binding context with the specified change observer.
 
 The default implementation evaluates the binding expression's primary expression and returns a property set up with the specified change observer or returns nil and sets the specified error to an error message explaining that the binding expression invalidly did not provide a binding source.

 This can be overridden by implementing sub classes to provide a default value when the binding expression does not define a primary expression or, less commonly, to replace the binding source or to allow a binding with undefined source (by not setting the error).

 @param bindingExpression the binding expression
 @param bindingContext    the binding context
 @param changeObserver    the change observer provided by the binding which has to be used by the resulting property to notify the binding of changes.
 @param error             only set if an undefined result is returned. Describes the error or if nil, indicates that the result is validly undefined.

 @return A property referring to the binding source of nil if an error occurred or if there is no binding source.
 */
- (opt_AKAProperty)        setupBindingSourceWithExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                             changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                                      error:(out_NSError)error;

#pragma mark - Configuration

@property(nonatomic, readonly, nonnull) AKAProperty*        bindingSource;
@property(nonatomic, readonly, nonnull) AKAProperty*        bindingTarget;
@property(nonatomic, readonly, nullable) SEL                bindingProperty;
@property(nonatomic, readonly, weak) id<AKABindingContextProtocol> bindingContext;
@property(nonatomic, readonly, weak) id<AKABindingDelegate> delegate;

#pragma mark - Conversion


- (BOOL)                                 convertSourceValue:(opt_id)sourceValue
                                              toTargetValue:(out_id)targetValueStore
                                                      error:(out_NSError)error;

#pragma mark - Validation

- (BOOL)                                validateSourceValue:(inout_id)sourceValueStore
                                                      error:(out_NSError)error;

- (BOOL)                                validateTargetValue:(inout_id)targetValueStore
                                                      error:(out_NSError)error;

#pragma mark - Change Tracking

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                                 toNewValue:(opt_id)newSourceValue;

- (BOOL)                              startObservingChanges;

- (BOOL)                               stopObservingChanges;

#pragma mark - Updating

/**
 Triggers an update of the target value from source.
 
 This can be used by subclasses to initialize the target value or to reset it, for example if configuration parameters have been changed and the target needs to be reinitialized.
 
 @note Please note that source value changes are tracked automatically and do not require this method to be called.
 */
- (void)                                  updateTargetValue;

@end


@interface AKABinding(Internal)

@property(nonatomic, readonly)BOOL isUpdatingTargetValueForSourceValueChange;

/**
 * Determines if the target (f.e. view-) value should be updated as a result of a changed
 * source (f.e. model-) value.
 *
 * @note: This is used before the corresponding delegate method is called and serves as
 *   shortcut to prevent update cycles. For this purpose, an unnecessary and potentially
 *   expensive conversion of source to target values is skipped. The default implementation
 *   returns YES.
 * @warning: Sub class redefining this method should always call the super implementation and never return YES if it returned NO.
 *
 * @param oldSourceValue the old source value
 * @param newSourceValue the new source value
 * @param sourceValue the new source value or the result of the source value validation replacing an invalid value.
 *
 * @return YES if the target value should be updated, NO otherwise.
 */
- (BOOL)              shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
                                                validatedTo:(opt_id)sourceValue;

@end



