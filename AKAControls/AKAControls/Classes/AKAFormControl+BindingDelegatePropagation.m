//
//  AKAFormControl+BindingDelegatePropagation.m
//  AKAControls
//
//  Created by Michael Utech on 18.10.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKAFormControl+BindingDelegatePropagation.h"
#import "AKAKeyboardActivationSequence.h"

@implementation AKAFormControl (BindingDelegatePropagation)

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

    id<AKAControlDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(control:binding:targetUpdateFailedToConvertSourceValue:toTargetValueWithError:)])
    {
        [delegate
                                        control:control
                                        binding:binding
         targetUpdateFailedToConvertSourceValue:sourceValue
                         toTargetValueWithError:error];
    }
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

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:targetUpdateFailedToValidateTargetValue:convertedFromSourceValue:withError:)])
    {
        [delegate
                                         control:control
                                         binding:binding
         targetUpdateFailedToValidateTargetValue:targetValue
                        convertedFromSourceValue:sourceValue
                                       withError:error];
    }
}

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKABinding)binding
                                    updateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue
{
    BOOL result = YES;

    id<AKAControlDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(control:shouldBinding:updateTargetValue:to:forSourceValue:changeTo:)])
    {
        result = [delegate
                            control:control
                      shouldBinding:binding
                  updateTargetValue:oldTargetValue
                                 to:newTargetValue
                     forSourceValue:oldSourceValue
                           changeTo:newSourceValue];
    }

    AKACompositeControl* owner = self.owner;

    if (result && owner)
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

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:willUpdateTargetValue:to:)])
    {
        [delegate
                       control:control
                       binding:binding
         willUpdateTargetValue:oldTargetValue
                            to:newTargetValue];
    }
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

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:didUpdateTargetValue:to:)])
    {
        [delegate
                      control:control
                      binding:binding
         didUpdateTargetValue:oldTargetValue
                           to:newTargetValue];
    }
}

@end


@implementation AKAFormControl (ControlViewBindingDelegatePropagation)

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

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceUpdateFailedToConvertTargetValue:toSourceValueWithError:)])
    {
        [delegate
                                        control:control
                                        binding:binding
         sourceUpdateFailedToConvertTargetValue:targetValue
                         toSourceValueWithError:error];
    }
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

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceUpdateFailedToValidateSourceValue:convertedFromTargetValue:withError:)])
    {
        [delegate
                                         control:control
                                         binding:binding
         sourceUpdateFailedToValidateSourceValue:sourceValue
                        convertedFromTargetValue:targetValue
                                       withError:error];
    }
}

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAControlViewBinding)binding
                                    updateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
                                       forTargetValue:(opt_id)oldTargetValue
                                             changeTo:(opt_id)newTargetValue
{
    BOOL result = YES;

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:shouldBinding:updateSourceValue:to:forTargetValue:changeTo:)])
    {
        result = [delegate
                            control:control
                      shouldBinding:binding
                  updateSourceValue:oldSourceValue
                                 to:newSourceValue
                     forTargetValue:oldTargetValue
                           changeTo:newTargetValue];
    }

    AKACompositeControl* owner = self.owner;
    if (result && owner)
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

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:willUpdateSourceValue:to:)])
    {
        [delegate
                       control:control
                       binding:binding
         willUpdateSourceValue:oldSourceValue
                            to:newSourceValue];
    }
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

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:didUpdateSourceValue:to:)])
    {
        [delegate
                      control:control
                      binding:binding
         didUpdateSourceValue:oldSourceValue
                           to:newSourceValue];
    }
}

@end


@implementation AKAFormControl (KeyboardControlViewBindingDelegatePropagation)

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder
{
    BOOL result = YES;

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:shouldBinding:responderActivate:)])
    {
        result = [delegate control:control shouldBinding:binding responderActivate:responder];
    }

    if (result)
    {
        result = [super control:control shouldBinding:binding responderActivate:responder];
    }

    return result;
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder
{
    [super control:control binding:binding responderWillActivate:responder];

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:responderWillActivate:)])
    {
        [delegate control:control binding:binding responderWillActivate:responder];
    }
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder
{
    [super control:control binding:binding responderDidActivate:responder];

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:responderDidActivate:)])
    {
        [delegate control:control binding:binding responderDidActivate:responder];
    }
}

- (BOOL)                                      control:(req_AKAControl)control
                                        shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder
{
    BOOL result = YES;

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:shouldBinding:responderDeactivate:)])
    {
        result = [delegate control:control shouldBinding:binding responderDeactivate:responder];
    }

    if (result)
    {
        result = [super control:control shouldBinding:binding responderDeactivate:responder];
    }

    return result;
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder
{
    [super control:control binding:binding responderWillDeactivate:responder];

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:responderWillDeactivate:)])
    {
        [delegate control:control binding:binding responderWillDeactivate:responder];
    }
}

- (void)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder
{
    [super control:control binding:binding responderDidDeactivate:responder];

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:responderDidDeactivate:)])
    {
        [delegate control:control binding:binding responderDidDeactivate:responder];
    }
}

- (BOOL)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                       responderRequestedActivateNext:(req_UIResponder)responder
{
    // Don't see a need to propagate event since activation events will fire
    (void)control;
    (void)binding;
    (void)responder;
    return [self.keyboardActivationSequence activateNext];
}

- (BOOL)                                      control:(req_AKAControl)control
                                              binding:(req_AKAKeyboardControlViewBinding)binding
                           responderRequestedGoOrDone:(req_UIResponder)responder
{
    // Don't see a need to propagate event since activation events will fire
    (void)control;
    (void)binding;
    (void)responder;
    // TODO: consider implementing commit form
    return [self.keyboardActivationSequence deactivate];
}

@end


@implementation AKAFormControl (CollectionControlViewBindingDelegatePropagation)

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                    sourceControllerWillChangeContent:(req_id)sourceDataController
{
    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceControllerWillChangeContent:)])
    {
        [delegate control:control binding:binding sourceControllerWillChangeContent:sourceDataController];
    }

    [super control:control binding:binding sourceControllerWillChangeContent:sourceDataController];
}

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                         insertedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceController:insertedItem:atIndexPath:)])
    {
        [delegate control:control binding:binding sourceController:sourceDataController insertedItem:sourceCollectionItem atIndexPath:indexPath];
    }

   [super control:control binding:binding sourceController:sourceDataController insertedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          updatedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceController:updatedItem:atIndexPath:)])
    {
        [delegate control:control binding:binding sourceController:sourceDataController updatedItem:sourceCollectionItem atIndexPath:indexPath];
    }

    [super control:control binding:binding sourceController:sourceDataController updatedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          deletedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceController:deletedItem:atIndexPath:)])
    {
        [delegate control:control binding:binding sourceController:sourceDataController deletedItem:sourceCollectionItem atIndexPath:indexPath];
    }

    [super control:control binding:binding sourceController:sourceDataController deletedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                            movedItem:(opt_id)sourceCollectionItem
                                        fromIndexPath:(req_NSIndexPath)fromIndexPath
                                          toIndexPath:(req_NSIndexPath)toIndexPath
{
    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceController:movedItem:fromIndexPath:toIndexPath:)])
    {
        [delegate control:control binding:binding sourceController:sourceDataController movedItem:sourceCollectionItem fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }

    [super control:control binding:binding sourceController:sourceDataController movedItem:sourceCollectionItem fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)                                      control:(req_AKACompositeControl)control
                                              binding:(req_AKACollectionControlViewBinding)binding
                     sourceControllerDidChangeContent:(req_id)sourceDataController
{
    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(control:binding:sourceControllerDidChangeContent:)])
    {
        [delegate control:control binding:binding sourceControllerDidChangeContent:sourceDataController];
    }

   [super control:control binding:binding sourceControllerDidChangeContent:sourceDataController];
}

@end