//
//  AKABindingController+BindingDelegatePropagation.m
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController+BindingDelegatePropagation.h"
#import "AKABindingController+KeyboardActivationSequence.h"

#pragma mark - AKABindingController(BindingDelegatePropagation) - Implementation
#pragma mark -

@implementation AKABindingController(BindingDelegatePropagation)

#pragma mark - AKABindingDelegate

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                     sourceValueDidChangeFromOldValue:(id _Nullable)oldSourceValue
                                                   to:(id _Nullable)newSourceValue
{
    [self.parent controller:controller binding:binding sourceValueDidChangeFromOldValue:oldSourceValue to:newSourceValue];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:sourceValueDidChangeFromOldValue:to:)])
    {
        [delegate controller:controller binding:binding sourceValueDidChangeFromOldValue:oldSourceValue to:newSourceValue];
    }
}


- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                     sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                       toInvalidValue:(opt_id)newSourceValue
                                            withError:(opt_NSError)error
{
    [self.parent controller:controller binding:binding sourceValueDidChangeFromOldValue:oldSourceValue toInvalidValue:newSourceValue withError:error];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:sourceValueDidChangeFromOldValue:toInvalidValue:error:)])
    {
        [delegate controller:controller binding:binding sourceValueDidChangeFromOldValue:oldSourceValue toInvalidValue:newSourceValue withError:error];
    }
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                               sourceArrayItemAtIndex:(NSUInteger)index
                                                value:(opt_id)oldValue
                                          didChangeTo:(opt_id)newValue
{
    [self.parent controller:controller binding:binding sourceArrayItemAtIndex:index value:oldValue didChangeTo:newValue];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:sourceArrayItemAtIndex:value:didChangeTo:)])
    {
        [delegate controller:controller binding:binding sourceArrayItemAtIndex:index value:oldValue didChangeTo:newValue];
    }
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                               targetArrayItemAtIndex:(NSUInteger)index
                                                value:(opt_id)oldValue
                                          didChangeTo:(opt_id)newValue;
{
    [self.parent controller:controller binding:binding targetArrayItemAtIndex:index value:oldValue didChangeTo:newValue];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:targetArrayItemAtIndex:value:didChangeTo:)])
    {
        [delegate controller:controller binding:binding targetArrayItemAtIndex:index value:oldValue didChangeTo:newValue];
    }
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
               targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                               toTargetValueWithError:(opt_NSError)error
{
    [self.parent controller:controller binding:binding targetUpdateFailedToConvertSourceValue:sourceValue toTargetValueWithError:error];

    id<AKABindingControllerDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(controller:binding:targetUpdateFailedToConvertSourceValue:toTargetValueWithError:)])
    {
        [delegate controller:controller binding:binding targetUpdateFailedToConvertSourceValue:sourceValue toTargetValueWithError:error];
    }
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
              targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                             convertedFromSourceValue:(opt_id)sourceValue
                                            withError:(opt_NSError)error
{
    [self.parent controller:controller binding:binding targetUpdateFailedToValidateTargetValue:targetValue convertedFromSourceValue:sourceValue withError:error];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:targetUpdateFailedToValidateTargetValue:convertedFromSourceValue:withError:)])
    {
        [delegate controller:controller binding:binding targetUpdateFailedToValidateTargetValue:targetValue convertedFromSourceValue:sourceValue withError:error];
    }
}

- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKABinding)binding
                                    updateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue
{
    BOOL result = YES;

    id<AKABindingControllerDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(controller:shouldBinding:updateTargetValue:to:forSourceValue:changeTo:)])
    {
        result = [delegate controller:controller shouldBinding:binding updateTargetValue:oldTargetValue to:newTargetValue forSourceValue:oldSourceValue changeTo:newSourceValue];
    }

    AKABindingController* owner = self.parent;
    if (result && owner)
    {
        result = [owner controller:controller shouldBinding:binding updateTargetValue:oldTargetValue to:newTargetValue forSourceValue:oldSourceValue changeTo:newSourceValue];
    }

    return result;
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                                willUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
{
    [self.parent controller:controller binding:binding willUpdateTargetValue:oldTargetValue to:newTargetValue];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:willUpdateTargetValue:to:)])
    {
        [delegate controller:controller binding:binding willUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKABinding)binding
                                 didUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
{
    [self.parent controller:controller binding:binding didUpdateTargetValue:oldTargetValue to:newTargetValue];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:didUpdateTargetValue:to:)])
    {
        [delegate controller:controller binding:binding didUpdateTargetValue:oldTargetValue to:newTargetValue];
    }
}

#pragma mark - AKAControlViewBindingDelegate

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
               sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                               toSourceValueWithError:(opt_NSError)error
{
    [self.parent controller:controller binding:binding sourceUpdateFailedToConvertTargetValue:targetValue toSourceValueWithError:error];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:sourceUpdateFailedToConvertTargetValue:toSourceValueWithError:)])
    {
        [delegate controller:controller binding:binding sourceUpdateFailedToConvertTargetValue:targetValue toSourceValueWithError:error];
    }
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
              sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                             convertedFromTargetValue:(opt_id)targetValue
                                            withError:(opt_NSError)error
{
    [self.parent controller:controller binding:binding sourceUpdateFailedToValidateSourceValue:sourceValue convertedFromTargetValue:targetValue
                  withError:error];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:sourceUpdateFailedToValidateSourceValue:convertedFromTargetValue:withError:)])
    {
        [delegate controller:controller binding:binding sourceUpdateFailedToValidateSourceValue:sourceValue convertedFromTargetValue:targetValue withError:error];
    }
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
                     targetValueDidChangeFromOldValue:(opt_id)oldTargetValue
                                       toInvalidValue:(opt_id)newTargetValue
                                            withError:(opt_NSError)error;
{
    [self.parent controller:controller binding:binding targetValueDidChangeFromOldValue:oldTargetValue toInvalidValue:newTargetValue withError:error];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:targetValueDidChangeFromOldValue:toInvalidValue:withError:)])
    {
        [delegate controller:controller binding:binding targetValueDidChangeFromOldValue:oldTargetValue toInvalidValue:newTargetValue withError:error];
    }
}

- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKAControlViewBinding)binding
                                    updateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
                                       forTargetValue:(opt_id)oldTargetValue
                                             changeTo:(opt_id)newTargetValue
{
    BOOL result = YES;

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:shouldBinding:updateSourceValue:to:forTargetValue:changeTo:)])
    {
        result = [delegate controller:controller shouldBinding:binding updateSourceValue:oldSourceValue to:newSourceValue forTargetValue:oldTargetValue changeTo:newTargetValue];
    }

    AKABindingController* parent = self.parent;
    if (result && parent)
    {
        result = [parent controller:controller shouldBinding:binding updateSourceValue:oldSourceValue to:newSourceValue forTargetValue:oldTargetValue changeTo:newTargetValue];
    }

    return result;
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
                                willUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self.parent controller:controller binding:binding willUpdateSourceValue:oldSourceValue to:newSourceValue];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:willUpdateSourceValue:to:)])
    {
        [delegate controller:controller binding:binding willUpdateSourceValue:oldSourceValue to:newSourceValue];
    }
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAControlViewBinding)binding
                                 didUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self.parent controller:controller binding:binding didUpdateSourceValue:oldSourceValue to:newSourceValue];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:didUpdateSourceValue:to:)])
    {
        [delegate controller:controller binding:binding didUpdateSourceValue:oldSourceValue to:newSourceValue];
    }
}

#pragma mark - AKAKeyboardControlViewBindingDelegate


- (BOOL)                                   controller:(req_AKABindingController __unused)controller
                                              binding:(req_AKAKeyboardControlViewBinding __unused)binding
                       responderRequestedActivateNext:(req_UIResponder __unused)responder
{
    BOOL result = NO;

    AKABindingController* parent = self.parent;
    if (parent)
    {
        result = [self.parent controller:controller binding:binding responderRequestedActivateNext:responder];
    }

    if (!result)
    {
        id<AKABindingControllerDelegate> delegate = self.delegate;
        if (delegate && [delegate respondsToSelector:@selector(controller:binding:responderRequestedActivateNext:)])
        {
            result =  [delegate controller:controller binding:binding responderRequestedActivateNext:responder];
        }
    }

    if (!result)
    {
        result = [self.keyboardActivationSequence activateNext];
    }

    return result;
}

- (BOOL)                                   controller:(req_AKABindingController __unused)controller
                                              binding:(req_AKAKeyboardControlViewBinding __unused)binding
                           responderRequestedGoOrDone:(req_UIResponder __unused)responder
{
    BOOL result = NO;

    AKABindingController* parent = self.parent;
    if (parent)
    {
        result = [self.parent controller:controller binding:binding responderRequestedGoOrDone:responder];
    }

    if (!result)
    {
        id<AKABindingControllerDelegate> delegate = self.delegate;
        if (delegate && [delegate respondsToSelector:@selector(controller:binding:responderRequestedGoOrDone:)])
        {
            result =  [delegate controller:controller binding:binding responderRequestedGoOrDone:responder];
        }
    }

    if (!result)
    {
        result = [self.keyboardActivationSequence deactivate];
    }

    return result;
}

- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder
{
    BOOL result = YES;

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:shouldBinding:responderActivate:)])
    {
        result = [delegate controller:controller shouldBinding:binding responderActivate:responder];
    }

    AKABindingController* parent = self.parent;
    if (result && parent)
    {
        result = [parent controller:controller shouldBinding:binding responderActivate:responder];
    }

    return result;
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder
{
    [self.parent controller:controller binding:binding responderWillActivate:responder];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:responderWillActivate:)])
    {
        [delegate controller:controller binding:binding responderWillActivate:responder];
    }
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder
{
    [self.parent controller:controller binding:binding responderDidActivate:responder];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:responderDidActivate:)])
    {
        [delegate controller:controller binding:binding responderDidActivate:responder];
    }
}

- (BOOL)                                   controller:(req_AKABindingController)controller
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder
{
    BOOL result = YES;

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:shouldBinding:responderDeactivate:)])
    {
        result = [delegate controller:controller shouldBinding:binding responderDeactivate:responder];
    }

    AKABindingController* parent = self.parent;
    if (result && parent)
    {
        result = [parent controller:controller shouldBinding:binding responderDeactivate:responder];
    }

    return result;
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder
{
    [self.parent controller:controller binding:binding responderWillDeactivate:responder];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:responderWillDeactivate:)])
    {
        [delegate controller:controller binding:binding responderWillDeactivate:responder];
    }
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder
{
    [self.parent controller:controller binding:binding responderDidDeactivate:responder];

    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controller:binding:responderDidDeactivate:)])
    {
        [delegate controller:controller binding:binding responderDidDeactivate:responder];
    }
}

#pragma mark - AKACollectionControlViewBindingDelegate

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                    sourceControllerWillChangeContent:(req_id)sourceDataController
{
    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceControllerWillChangeContent:)])
    {
        [delegate controller:controller binding:binding sourceControllerWillChangeContent:sourceDataController];
    }

    [self.parent controller:controller binding:binding sourceControllerWillChangeContent:sourceDataController];
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                         insertedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceController:insertedItem:atIndexPath:)])
    {
        [delegate controller:controller binding:binding sourceController:sourceDataController insertedItem:sourceCollectionItem atIndexPath:indexPath];
    }

    [self.parent controller:controller binding:binding sourceController:sourceDataController insertedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          updatedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceController:updatedItem:atIndexPath:)])
    {
        [delegate controller:controller binding:binding sourceController:sourceDataController updatedItem:sourceCollectionItem atIndexPath:indexPath];
    }

    [self.parent controller:controller binding:binding sourceController:sourceDataController updatedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          deletedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceController:deletedItem:atIndexPath:)])
    {
        [delegate controller:controller binding:binding sourceController:sourceDataController deletedItem:sourceCollectionItem atIndexPath:indexPath];
    }

    [self.parent controller:controller binding:binding sourceController:sourceDataController deletedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                            movedItem:(opt_id)sourceCollectionItem
                                        fromIndexPath:(req_NSIndexPath)fromIndexPath
                                          toIndexPath:(req_NSIndexPath)toIndexPath
{
    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceController:movedItem:fromIndexPath:toIndexPath:)])
    {
        [delegate controller:controller binding:binding sourceController:sourceDataController movedItem:sourceCollectionItem fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }

    [self.parent controller:controller binding:binding sourceController:sourceDataController movedItem:sourceCollectionItem fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)                                   controller:(req_AKABindingController)controller
                                              binding:(req_AKACollectionControlViewBinding)binding
                     sourceControllerDidChangeContent:(req_id)sourceDataController
{
    id<AKABindingControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceControllerDidChangeContent:)])
    {
        [delegate controller:controller binding:binding sourceControllerDidChangeContent:sourceDataController];
    }
    
    [self.parent controller:controller binding:binding sourceControllerDidChangeContent:sourceDataController];
}

@end
