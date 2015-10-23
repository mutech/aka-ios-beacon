//
//  AKACompositeControl+BindingDelegatePropagation.m
//  AKAControls
//
//  Created by Michael Utech on 13.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKACompositeControl+BindingDelegatePropagation.h"

@implementation AKACompositeControl (BindingDelegatePropagation)

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
               targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                               toTargetValueWithError:(opt_NSError)error
{
    [self.owner
                                    control:control
                                    binding:binding
     targetUpdateFailedToConvertSourceValue:sourceValue
                     toTargetValueWithError:error];
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
              targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                             convertedFromSourceValue:(opt_id)sourceValue
                                            withError:(opt_NSError)error
{
    [self.owner
                                     control:control
                                     binding:binding
     targetUpdateFailedToValidateTargetValue:targetValue
                    convertedFromSourceValue:sourceValue
                                   withError:error];
}

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKABinding)binding
                                    updateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue
{
    BOOL result = YES;

    AKACompositeControl* owner = self.owner;

    if (owner)
    {
        result = [owner
                            control:control
                      shouldBinding:binding
                  updateTargetValue:oldTargetValue
                                 to:newTargetValue
                     forSourceValue:oldSourceValue
                           changeTo:newSourceValue];
    }

    return result;
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
                                willUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
{
    [self.owner
                   control:control
                   binding:binding
     willUpdateTargetValue:oldTargetValue
                        to:newTargetValue];
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKABinding)binding
                                 didUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
{
    [self.owner
                  control:control
                  binding:binding
     didUpdateTargetValue:oldTargetValue
                       to:newTargetValue];
}

@end


@implementation AKACompositeControl (ControlViewBindingDelegatePropagation)

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
               sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                               toSourceValueWithError:(opt_NSError)error
{
    [self.owner
                                    control:control
                                    binding:binding
     sourceUpdateFailedToConvertTargetValue:targetValue
                     toSourceValueWithError:error];
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
              sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                             convertedFromTargetValue:(opt_id)targetValue
                                            withError:(opt_NSError)error
{
    [self.owner
                                     control:control
                                     binding:binding
     sourceUpdateFailedToValidateSourceValue:sourceValue
                    convertedFromTargetValue:targetValue
                                   withError:error];
}

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAControlViewBinding)binding
                                    updateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
                                       forTargetValue:(opt_id)oldTargetValue
                                             changeTo:(opt_id)newTargetValue
{
    BOOL result = YES;

    AKACompositeControl* owner = self.owner;

    if (owner)
    {
        result = [owner
                            control:control
                      shouldBinding:binding
                  updateSourceValue:oldSourceValue
                                 to:newSourceValue
                     forTargetValue:oldTargetValue
                           changeTo:newTargetValue];
    }

    return result;
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
                                willUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self.owner
                   control:control
                   binding:binding
     willUpdateSourceValue:oldSourceValue
                        to:newSourceValue];
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAControlViewBinding)binding
                                 didUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self.owner
                  control:control
                  binding:binding
     didUpdateSourceValue:oldSourceValue
                       to:newSourceValue];
}

@end


@implementation AKACompositeControl (KeyboardControlViewBindingDelegatePropagation)

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder
{
    BOOL result = YES;
    AKACompositeControl* owner = self.owner;

    if (owner)
    {
        result = [owner control:control shouldBinding:binding responderActivate:responder];
    }

    return result;
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder
{
    [self.owner control:control binding:binding responderWillActivate:responder];
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder
{
    [self.owner control:control binding:binding responderDidActivate:responder];
}

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder
{
    BOOL result = YES;
    AKACompositeControl* owner = self.owner;

    if (owner)
    {
        result = [owner control:control shouldBinding:binding responderDeactivate:responder];
    }

    return result;
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder
{
    [self.owner control:control binding:binding responderWillDeactivate:responder];
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder
{
    [self.owner control:control binding:binding responderDidDeactivate:responder];
}

- (BOOL)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                       responderRequestedActivateNext:(req_UIResponder)responder
{
    return [self.owner control:control binding:binding responderRequestedActivateNext:responder];
}

- (BOOL)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                           responderRequestedGoOrDone:(req_UIResponder)responder
{
    return [self.owner control:control binding:binding responderRequestedGoOrDone:responder];
}

@end


// TODO: replace AKADynamicPlaceholderTableViewCellCompositeControl with AKACollectionControl

#import "AKADynamicPlaceholderTableViewCellCompositeControl.h"

@implementation AKACompositeControl (CollectionControlViewBindingDelegatePropagation)

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                    sourceControllerWillChangeContent:(req_id)sourceDataController
{
    [self.owner control:control binding:binding sourceControllerWillChangeContent:sourceDataController];
}

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                         insertedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    [self.owner control:control binding:binding sourceController:sourceDataController insertedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          updatedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    [self.owner control:control binding:binding sourceController:sourceDataController updatedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          deletedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    [self.owner control:control binding:binding sourceController:sourceDataController deletedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                            movedItem:(opt_id)sourceCollectionItem
                                        fromIndexPath:(req_NSIndexPath)fromIndexPath
                                          toIndexPath:(req_NSIndexPath)toIndexPath
{
    [self.owner control:control binding:binding sourceController:sourceDataController movedItem:sourceCollectionItem fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                     sourceControllerDidChangeContent:(req_id)sourceDataController
{
    [self.owner control:control binding:binding sourceControllerDidChangeContent:sourceDataController];
}

@end