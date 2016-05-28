//
//  AKABindingController+BindingDelegatePropagation.h
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController.h"


#pragma mark - AKABindingController(BindingDelegatePropagation) - Interface
#pragma mark -

@interface AKABindingController(BindingDelegatePropagation)<AKABindingControllerDelegate>

#pragma mark - AKABindingDelegate

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
               targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                               toTargetValueWithError:(opt_NSError)error;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
              targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                             convertedFromSourceValue:(opt_id)sourceValue
                                            withError:(opt_NSError)error;

- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKABinding)binding
                                    updateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                                willUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                                 didUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue;

#pragma mark - AKAControlViewBindingDelegate

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
               sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                               toSourceValueWithError:(opt_NSError)error;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
              sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                             convertedFromTargetValue:(opt_id)targetValue
                                            withError:(opt_NSError)error;

- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKAControlViewBinding)binding
                                    updateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
                                       forTargetValue:(opt_id)oldTargetValue
                                             changeTo:(opt_id)newTargetValue;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
                                willUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
                                 didUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue;

#pragma mark - AKAKeyboardControlViewBindingDelegate

- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder;

- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder;

// TODO: remove or implement
- (BOOL)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                       responderRequestedActivateNext:(req_UIResponder)responder;

// TODO: remove or implement
- (BOOL)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                           responderRequestedGoOrDone:(req_UIResponder)responder;

#pragma mark - AKACollectionControlViewBindingDelegate

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                    sourceControllerWillChangeContent:(req_id)sourceDataController;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                         insertedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          updatedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          deletedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                            movedItem:(opt_id)sourceCollectionItem
                                        fromIndexPath:(req_NSIndexPath)fromIndexPath
                                          toIndexPath:(req_NSIndexPath)toIndexPath;

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                     sourceControllerDidChangeContent:(req_id)sourceDataController;

@end

