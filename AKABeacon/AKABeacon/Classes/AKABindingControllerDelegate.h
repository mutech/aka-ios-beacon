//
//  AKABindingControllerDelegate.h
//  AKABeacon
//
//  Created by Michael Utech on 24.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
#import "AKABeaconNullability.h"


@class AKABindingController;
@protocol AKABindingControllerDelegate <NSObject>

@optional
/**
 Determines whether a binding with the specified parameters should be created and added to the binding controller.

 @param controller        the binding controller
 @param bindingType       a subclass of AKABinding (f.e. AKABinding_UILabel_textBinding)
 @param target            the binding target (f.e. an instance of UILabel)
 @param bindingProperty   the property (getter selector) holding the binding expression (f.e. textBinding_aka)
 @param bindingExpression the binding expression that will be used to create the new binding

 @return YES if the binding should be created and added to the binding controller, NO if it should be ignored.
 */
- (BOOL)                                  shouldController:(req_AKABindingController __unused)controller
                                          addBindingOfType:(req_Class)bindingType
                                                 forTarget:(req_id)target
                                                  property:(req_SEL)bindingProperty
                                         bindingExpression:(req_AKABindingExpression __unused)bindingExpression;

@optional
/**
 Called after a binding was created and before it is added to the binding controller.


 @param controller        the binding controller
 @param binding           an instance of AKABinding
 @param target            the binding target (f.e. an instance of UILabel)
 @param bindingProperty   the property (getter selector) holding the binding expression (f.e. textBinding_aka)
 @param bindingExpression the binding expression that was used to create the binding.
 */
- (void)                                        controller:(req_AKABindingController __unused)controller
                                            willAddBinding:(req_AKABinding)binding
                                                 forTarget:(req_id __unused)view
                                                  property:(req_SEL __unused)bindingProperty
                                         bindingExpression:(req_AKABindingExpression __unused)bindingExpression;

@optional
- (void)                                        controller:(req_AKABindingController __unused)controller
                               failedToCreateBindingOfType:(req_Class)bindingType
                                                 forTarget:(req_id)target
                                                  property:(req_SEL)bindingProperty
                                         bindingExpression:(req_AKABindingExpression)bindingExpression
                                                 withError:(req_NSError)error;

@optional
- (void)                                        controller:(req_AKABindingController __unused)controller
                                             didAddBinding:(req_AKABinding)binding
                                                 forTarget:(req_id __unused)view
                                                  property:(req_SEL __unused)bindingProperty
                                         bindingExpression:(req_AKABindingExpression __unused)bindingExpression;


#pragma mark - AKABindingDelegate


@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                     sourceValueDidChangeFromOldValue:(id _Nullable)oldSourceValue
                                                   to:(id _Nullable)newSourceValue;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                     sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                       toInvalidValue:(opt_id)newSourceValue
                                            withError:(opt_NSError)error;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                               sourceArrayItemAtIndex:(NSUInteger)index
                                                value:(opt_id)oldValue
                                          didChangeTo:(opt_id)newValue;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                               targetArrayItemAtIndex:(NSUInteger)index
                                                value:(opt_id)oldValue
                                          didChangeTo:(opt_id)newValue;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
               targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                               toTargetValueWithError:(opt_NSError)error;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
              targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                             convertedFromSourceValue:(opt_id)sourceValue
                                            withError:(opt_NSError)error;

@optional
- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKABinding)binding
                                    updateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                                willUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                                 didUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue;

#pragma mark - AKAControlViewBindingDelegate

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
               sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                               toSourceValueWithError:(opt_NSError)error;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
              sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                             convertedFromTargetValue:(opt_id)targetValue
                                            withError:(opt_NSError)error;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
                           targetValueDidChangeFromOldValue:(opt_id)oldTargetValue
                                             toInvalidValue:(opt_id)newTargetValue
                                                  withError:(opt_NSError)error;

@optional
- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKAControlViewBinding)binding
                                    updateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
                                       forTargetValue:(opt_id)oldTargetValue
                                             changeTo:(opt_id)newTargetValue;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
                                willUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
                                 didUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue;

#pragma mark - AKAKeyBoardControlViewBindingDelegate

#pragma mark Keyboard Activation Requests

@optional
- (BOOL)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                       responderRequestedActivateNext:(req_UIResponder)responder;

@optional
- (BOOL)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                           responderRequestedGoOrDone:(req_UIResponder)responder;

#pragma mark UIResponder Events

@optional
- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder;

@optional
- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder;

#pragma mark - AKACollectionViewBindingDelegate

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                    sourceControllerWillChangeContent:(req_id)sourceDataController;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                         insertedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          updatedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          deletedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                            movedItem:(opt_id)sourceCollectionItem
                                        fromIndexPath:(req_NSIndexPath)fromIndexPath
                                          toIndexPath:(req_NSIndexPath)toIndexPath;

@optional
- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                     sourceControllerDidChangeContent:(req_id)sourceDataController;

@end


