//
//  AKABinding+DelegateSupport.h
//  AKABeacon
//
//  Created by Michael Utech on 28.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding.h"


#pragma mark - AKABinding(DelegateSupport) - Interface
#pragma mark -

@interface AKABinding(DelegateSupport)

#pragma mark - Binding Delegate Message Propagation

/**
 Enumerates the binding's delegate, owner bindings and its immediate owner controller in that order
 and calls the specified block with the target if responds to the specified selector.
 
 IF the block sets the stop parameter to NO, the enumeration will be stopped.

 @param selector the delegate method selector
 @param block    the block
 */
- (void)propagateBindingDelegateMethod:(req_SEL)selector
                            usingBlock:(void(^_Nonnull)(id<AKABindingDelegate> _Nonnull,
                                                outreq_BOOL))block;

/**
 Determines if this binding will receive delegate messages originating from sub bindings (bindings referencing this instance as owner), even if this binding is not referenced as delegate by the sub binding.
 
 This setting does not prevent delegate messages from being sent if a sub binding's delegate property references this binding.
 
 @return the default implementation returns NO.
 */
- (BOOL)shouldReceiveDelegateMessagesForSubBindings;

/**
 Only used if shouldReceiveDelegateMessagesForSubBindings returns YES:

 Determines if this binding will receive delegate messages originating from transitive sub bindings (ssub bindings of sub bindings).

 @return the default implementation returns NO.
 */
- (BOOL)shouldReceiveDelegateMessagesForTransitiveSubBindings;


#pragma mark - Delegate Support Methods

- (void)             targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                                     toTargetValueWithError:(opt_NSError)error;

- (void)            targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                                   convertedFromSourceValue:(opt_id)sourceValue
                                                  withError:(opt_NSError)error;

- (void)                   sourceValueDidChangeFromOldValue:(id _Nullable)oldSourceValue
                                                         to:(id _Nullable)newSourceValue;

- (void)                   sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                             toInvalidValue:(opt_id)newSourceValue
                                                  withError:(opt_NSError)error;

- (void)                             sourceArrayItemAtIndex:(NSUInteger)index
                                                      value:(opt_id)oldValue
                                                didChangeTo:(opt_id)newValue;

- (void)                             targetArrayItemAtIndex:(NSUInteger)index
                                                      value:(opt_id)oldValue
                                                didChangeTo:(opt_id)newValue;

// TODO: move to subclass support category
- (BOOL)              shouldUpdateTargetValueForSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue
                                                validatedTo:(opt_id)sourceValue;

- (BOOL)                            shouldUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
                                             forSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue;

- (void)                              willUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue;

- (void)                               didUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
                                             forSourceValue:(opt_id)oldSourceValue
                                                   changeTo:(opt_id)newSourceValue;

@end
