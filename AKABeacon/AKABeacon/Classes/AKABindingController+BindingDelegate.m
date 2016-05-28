//
//  AKABindingController+BindingDelegate.m
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController+BindingDelegate.h"
#import "AKABindingController+BindingDelegatePropagation.h"


#pragma mark - AKABindingController(BindingDelegate) - Implementation
#pragma mark -

@implementation AKABindingController(BindingDelegate)


#pragma mark - AKABindingDelegate

- (void)                                      binding:(req_AKABinding)binding
               targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                               toTargetValueWithError:(opt_NSError)error
{
    [self controller:self binding:binding targetUpdateFailedToConvertSourceValue:sourceValue toTargetValueWithError:error];
}

- (void)                                      binding:(req_AKABinding)binding
              targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                             convertedFromSourceValue:(opt_id)sourceValue
                                            withError:(opt_NSError)error
{
    [self controller:self binding:binding targetUpdateFailedToValidateTargetValue:targetValue convertedFromSourceValue:sourceValue withError:error];
}

- (BOOL)                                shouldBinding:(req_AKABinding)binding
                                    updateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue
{
    return [self controller:self shouldBinding:binding updateTargetValue:oldTargetValue to:newTargetValue forSourceValue:oldSourceValue changeTo:newSourceValue];
}

- (void)                                      binding:(req_AKABinding)binding
                                willUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
{
    return [self controller:self binding:binding willUpdateTargetValue:oldTargetValue to:newTargetValue];
}

- (void)                                      binding:(req_AKABinding)binding
                                 didUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
{
    [self controller:self binding:binding didUpdateTargetValue:oldTargetValue to:newTargetValue];
}

#pragma mark - AKAControlViewBindingDelegate

- (void)                                      binding:(req_AKAControlViewBinding)binding
               sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                               toSourceValueWithError:(opt_NSError)error
{
    [self controller:self binding:binding sourceUpdateFailedToConvertTargetValue:targetValue toSourceValueWithError:error];
}

- (void)                                      binding:(req_AKAControlViewBinding)binding
              sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                             convertedFromTargetValue:(opt_id)targetValue
                                            withError:(opt_NSError)error
{
    [self controller:self binding:binding sourceUpdateFailedToValidateSourceValue:sourceValue convertedFromTargetValue:targetValue
           withError:error];
}

- (BOOL)                                shouldBinding:(req_AKAControlViewBinding)binding
                                    updateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
                                       forTargetValue:(opt_id)oldTargetValue
                                             changeTo:(opt_id)newTargetValue
{
    return [self controller:self shouldBinding:binding updateSourceValue:oldSourceValue to:newSourceValue forTargetValue:oldTargetValue changeTo:newTargetValue];
}

- (void)                                      binding:(req_AKAControlViewBinding)binding
                                willUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self controller:self binding:binding willUpdateSourceValue:oldSourceValue to:newSourceValue];
}

- (void)                                      binding:(req_AKAControlViewBinding)binding
                                 didUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self controller:self binding:binding didUpdateSourceValue:oldSourceValue to:newSourceValue];
}

#pragma mark - AKAKeyboardControlViewBindingDelegate

- (BOOL)                                shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder
{
    return [self controller:self shouldBinding:binding responderActivate:responder];
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder
{
    return [self controller:self binding:binding responderWillActivate:responder];
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder
{
    [self controller:self binding:binding responderDidActivate:responder];
}

- (BOOL)                                shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder
{
    return [self controller:self shouldBinding:binding responderDeactivate:responder];
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder
{
    [self controller:self binding:binding responderWillDeactivate:responder];
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder
{
    [self controller:self binding:binding responderDidDeactivate:responder];
}

- (BOOL)                                      binding:(req_AKAKeyboardControlViewBinding __unused)binding
                       responderRequestedActivateNext:(req_UIResponder)responder
{
    return [self controller:self binding:binding responderRequestedActivateNext:responder];
}

- (BOOL)                                      binding:(req_AKAKeyboardControlViewBinding __unused)binding
                           responderRequestedGoOrDone:(req_UIResponder)responder
{
    return [self controller:self binding:binding responderRequestedGoOrDone:responder];
}

#pragma mark - AKACollectionControlViewBindingDelegate

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                    sourceControllerWillChangeContent:(req_id)sourceDataController
{
    [self controller:self binding:binding sourceControllerWillChangeContent:sourceDataController];
}

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                         insertedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    return [self controller:self binding:binding sourceController:sourceDataController insertedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          updatedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    return [self controller:self binding:binding sourceController:sourceDataController updatedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          deletedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    return [self controller:self binding:binding sourceController:sourceDataController deletedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                            movedItem:(opt_id)sourceCollectionItem
                                        fromIndexPath:(req_NSIndexPath)fromIndexPath
                                          toIndexPath:(req_NSIndexPath)toIndexPath
{
    return [self controller:self binding:binding sourceController:sourceDataController movedItem:sourceCollectionItem fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                     sourceControllerDidChangeContent:(req_id)sourceDataController
{
    return [self controller:self binding:binding sourceControllerDidChangeContent:sourceDataController];
}

@end
