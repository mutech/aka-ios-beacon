//
//  AKABinding.h
//  AKAControls
//
//  Created by Michael Utech on 17.09.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
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

- (instancetype _Nullable)                   initWithTarget:(req_id)target
                                                 expression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                                   delegate:(opt_AKABindingDelegate)delegate;

#pragma mark - Configuration

@property(nonatomic, readonly, nonnull) AKAProperty*        bindingSource;
@property(nonatomic, readonly, nonnull) AKAProperty*        bindingTarget;
@property(nonatomic, readonly, nullable) SEL                bindingProperty;
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

#pragma mark - Change Propagation

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



