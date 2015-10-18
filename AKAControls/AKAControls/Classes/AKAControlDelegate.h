//
//  AKAControlDelegate.h
//  AKAControls
//
//  Created by Michael Utech on 17.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import UIKit;
@import AKACommons.AKANullability;

@class AKABinding;
typedef AKABinding*_Nonnull                 req_AKABinding;

@class AKAControlViewBinding;
typedef AKAControlViewBinding*_Nonnull      req_AKAControlViewBinding;

@class AKAKeyboardControlViewBinding;
typedef AKAKeyboardControlViewBinding*_Nonnull req_AKAKeyboardControlViewBinding;

@class AKAControl;
typedef AKAControl*_Nonnull                 req_AKAControl;
typedef AKAControl*_Nullable                opt_AKAControl;

@class AKABinding;
typedef AKABinding*_Nonnull                 req_AKABinding;
typedef AKABinding*_Nullable                opt_AKABinding;

@class AKACompositeControl;
typedef AKACompositeControl*_Nonnull        req_AKACompositeControl;
typedef AKACompositeControl*_Nullable       opt_AKACompositeControl;


@protocol AKAControlMembershipDelegate <NSObject>

@optional
- (BOOL)                  shouldControl:(req_AKACompositeControl)compositeControl
                             addControl:(req_AKAControl)memberControl
                                atIndex:(NSUInteger)index;

@optional
- (void)                        control:(req_AKACompositeControl)compositeControl
                         willAddControl:(req_AKAControl)memberControl
                                atIndex:(NSUInteger)index;

@optional
- (void)                        control:(req_AKACompositeControl)compositeControl
                          didAddControl:(req_AKAControl)memberControl
                                atIndex:(NSUInteger)index;

@optional
- (BOOL)                 shouldControl:(req_AKACompositeControl)compositeControl
                         removeControl:(req_AKAControl)memberControl
                               atIndex:(NSUInteger)index;

@optional
- (void)                        control:(req_AKACompositeControl)compositeControl
                      willRemoveControl:(req_AKAControl)memberControl
                              fromIndex:(NSUInteger)index;

@optional
- (void)                        control:(req_AKACompositeControl)compositeControl
                       didRemoveControl:(req_AKAControl)memberControl
                              fromIndex:(NSUInteger)index;

@end


@protocol AKAControl_BindingDelegate <NSObject>

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
               targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                               toTargetValueWithError:(opt_NSError)error;

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
              targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                             convertedFromSourceValue:(opt_id)sourceValue
                                            withError:(opt_NSError)error;

@optional
- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKABinding)binding
                                    updateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue;

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
                                willUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue;

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
                                 didUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue;

@end


@protocol AKAControl_ControlViewBindingDelegate <NSObject>

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
               sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                               toSourceValueWithError:(opt_NSError)error;

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
              sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                             convertedFromTargetValue:(opt_id)targetValue
                                            withError:(opt_NSError)error;

@optional
- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAControlViewBinding)binding
                                    updateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
                                       forTargetValue:(opt_id)oldTargetValue
                                             changeTo:(opt_id)newTargetValue;

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
                                willUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue;

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
                                 didUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue;

@end


@protocol AKAControl_KeyboardControlViewBindingDelegate <NSObject>

@optional
- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder;

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder;

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder;

@optional
- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder;

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder;

@optional
- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder;

@optional
- (BOOL)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                       responderRequestedActivateNext:(req_UIResponder)responder;

@optional
- (BOOL)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                           responderRequestedGoOrDone:(req_UIResponder)responder;


@end



@protocol AKAControlDelegate <
    AKAControlMembershipDelegate,
    AKAControl_BindingDelegate,
    AKAControl_ControlViewBindingDelegate,
    AKAControl_KeyboardControlViewBindingDelegate
>

@optional
- (void)                        control:(req_AKAControl)control
                  modelValueChangedFrom:(opt_id)oldValue
                                     to:(opt_id)newValue;

@end

typedef id<AKAControlDelegate>_Nullable             opt_AKAControlDelegate;
typedef id<AKAControlDelegate>_Nonnull              req_AKAControlDelegate;

