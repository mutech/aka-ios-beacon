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

- (void)propagateBindingDelegateMethod:(SEL)selector
                            usingBlock:(void(^)(id<AKABindingControllerDelegate>, outreq_BOOL))block
{
    BOOL stop = NO;

    AKABindingController* controller = self;
    while (!stop && controller)
    {
        id<AKABindingControllerDelegate> delegate = controller.delegate;
        if (delegate && [delegate respondsToSelector:selector])
        {
            block(delegate, &stop);
        }
        controller = controller.parent;
    }
}

#pragma mark - AKABindingDelegate

- (void)                                      binding:(req_AKABinding)binding
                     sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:sourceValueDidChangeFromOldValue:to:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding sourceValueDidChangeFromOldValue:oldSourceValue to:newSourceValue];
     }];
}

- (void)                                      binding:(req_AKABinding)binding
                     sourceValueDidChangeFromOldValue:(opt_id)oldSourceValue
                                       toInvalidValue:(opt_id)newSourceValue
                                            withError:(opt_NSError)error
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:sourceValueDidChangeFromOldValue:toInvalidValue:withError:)
                               usingBlock:
      ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
      {
          [delegate controller:self binding:binding sourceValueDidChangeFromOldValue:oldSourceValue toInvalidValue:newSourceValue withError:error];
      }];
}

- (void)                                      binding:(req_AKABinding)binding
                               sourceArrayItemAtIndex:(NSUInteger)index
                                                value:(opt_id)oldValue
                                          didChangeTo:(opt_id)newValue
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:sourceArrayItemAtIndex:value:didChangeTo:)
                               usingBlock:
      ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding sourceArrayItemAtIndex:index value:oldValue didChangeTo:newValue];
      }];
}

- (void)                                      binding:(req_AKABinding)binding
                               targetArrayItemAtIndex:(NSUInteger)index
                                                value:(opt_id)oldValue
                                          didChangeTo:(opt_id)newValue
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:targetArrayItemAtIndex:value:didChangeTo:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding targetArrayItemAtIndex:index value:oldValue didChangeTo:newValue];
     }];
}

- (void)                                      binding:(req_AKABinding)binding
               targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                               toTargetValueWithError:(opt_NSError)error
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:targetUpdateFailedToConvertSourceValue:toTargetValueWithError:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding targetUpdateFailedToConvertSourceValue:sourceValue toTargetValueWithError:error];
     }];
}

- (void)                                      binding:(req_AKABinding)binding
              targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                             convertedFromSourceValue:(opt_id)sourceValue
                                            withError:(opt_NSError)error
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:targetUpdateFailedToValidateTargetValue:convertedFromSourceValue:withError:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding targetUpdateFailedToValidateTargetValue:targetValue convertedFromSourceValue:sourceValue withError:error];
     }];
}

- (BOOL)                                shouldBinding:(req_AKABinding)binding
                                    updateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue
{
    __block BOOL result = YES;

    [self propagateBindingDelegateMethod:@selector(controller:shouldBinding:updateTargetValue:to:forSourceValue:changeTo:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop)
     {
         result = [delegate controller:self shouldBinding:binding updateTargetValue:oldTargetValue to:newTargetValue forSourceValue:oldSourceValue changeTo:newSourceValue];
         *stop = !result;
     }];

    return result;
}

- (void)                                      binding:(req_AKABinding)binding
                                willUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
{
    [self propagateBindingDelegateMethod:@selector(control:binding:willUpdateTargetValue:to:)
                               usingBlock:
      ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
      {
          [delegate controller:self binding:binding willUpdateTargetValue:oldTargetValue to:newTargetValue];
      }];
}

- (void)                                      binding:(req_AKABinding)binding
                                 didUpdateTargetValue:(opt_id)oldTargetValue
                                                   to:(opt_id)newTargetValue
                                       forSourceValue:(opt_id)oldSourceValue
                                             changeTo:(opt_id)newSourceValue
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:didUpdateTargetValue:to:forSourceValue:changeTo:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding didUpdateTargetValue:oldTargetValue to:newTargetValue forSourceValue:oldSourceValue
                 changeTo:newSourceValue];
     }];
}

#pragma mark - AKAControlViewBindingDelegate

- (void)                                      binding:(req_AKAControlViewBinding)binding
               sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                               toSourceValueWithError:(opt_NSError)error
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:sourceUpdateFailedToConvertTargetValue:toSourceValueWithError:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding sourceUpdateFailedToConvertTargetValue:targetValue toSourceValueWithError:error];
     }];
}

- (void)                                      binding:(req_AKAControlViewBinding)binding
              sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                             convertedFromTargetValue:(opt_id)targetValue
                                            withError:(opt_NSError)error
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:sourceUpdateFailedToValidateSourceValue:convertedFromTargetValue:withError:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding sourceUpdateFailedToValidateSourceValue:sourceValue convertedFromTargetValue:targetValue
                withError:error];
     }];
}

- (void)                                      binding:(req_AKAControlViewBinding)binding
                     targetValueDidChangeFromOldValue:(opt_id)oldTargetValue
                                       toInvalidValue:(opt_id)newTargetValue
                                            withError:(opt_NSError)error
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:targetValueDidChangeFromOldValue:toInvalidValue:withError:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding targetValueDidChangeFromOldValue:oldTargetValue toInvalidValue:newTargetValue withError:error];
     }];
}

- (BOOL)                                shouldBinding:(req_AKAControlViewBinding)binding
                                    updateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
                                       forTargetValue:(opt_id)oldTargetValue
                                             changeTo:(opt_id)newTargetValue
{
    __block BOOL result = YES;

    [self propagateBindingDelegateMethod:@selector(controller:shouldBinding:updateSourceValue:to:forTargetValue:changeTo:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop)
     {
         result = [delegate controller:self shouldBinding:binding updateSourceValue:oldSourceValue to:newSourceValue forTargetValue:oldTargetValue changeTo:newTargetValue];
         *stop = !result;
     }];

    return result;
}

- (void)                                      binding:(req_AKAControlViewBinding)binding
                                willUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:willUpdateSourceValue:to:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding willUpdateSourceValue:oldSourceValue to:newSourceValue];
     }];
}

- (void)                                      binding:(req_AKAControlViewBinding)binding
                                 didUpdateSourceValue:(opt_id)oldSourceValue
                                                   to:(opt_id)newSourceValue
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:didUpdateSourceValue:to:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding didUpdateSourceValue:oldSourceValue to:newSourceValue];
     }];
}

#pragma mark - AKAKeyboardControlViewBindingDelegate

- (BOOL)                                      binding:(req_AKAKeyboardControlViewBinding __unused)binding
                       responderRequestedActivateNext:(req_UIResponder)responder
{
    __block BOOL result = YES;

    [self propagateBindingDelegateMethod:@selector(controller:binding:responderRequestedActivateNext:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop)
     {
         result = [delegate controller:self binding:binding responderRequestedActivateNext:responder];
         *stop = !result;
     }];

    return result;
}

- (BOOL)                                      binding:(req_AKAKeyboardControlViewBinding __unused)binding
                           responderRequestedGoOrDone:(req_UIResponder)responder
{
    __block BOOL result = YES;

    [self propagateBindingDelegateMethod:@selector(controller:binding:responderRequestedGoOrDone:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop)
     {
         result = [delegate controller:self binding:binding responderRequestedGoOrDone:responder];
         *stop = !result;
     }];

    return result;
}

- (BOOL)                                shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                    responderActivate:(req_UIResponder)responder
{
    __block BOOL result = YES;

    [self propagateBindingDelegateMethod:@selector(controller:shouldBinding:responderActivate:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop)
     {
         result = [delegate controller:self shouldBinding:binding responderActivate:responder];
         *stop = !result;
     }];

    return result;
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                                responderWillActivate:(req_UIResponder)responder
{
    [self propagateBindingDelegateMethod:@selector(control:binding:responderWillActivate:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding responderWillActivate:responder];
     }];
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                                 responderDidActivate:(req_UIResponder)responder
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:responderDidActivate:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding responderDidActivate:responder];
     }];

}

- (BOOL)                                shouldBinding:(req_AKAKeyboardControlViewBinding)binding
                                  responderDeactivate:(req_UIResponder)responder
{
    __block BOOL result = YES;

    [self propagateBindingDelegateMethod:@selector(controller:shouldBinding:responderDeactivate:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop)
     {
         result = [delegate controller:self shouldBinding:binding responderDeactivate:responder];
         *stop = !result;
     }];

    return result;
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                              responderWillDeactivate:(req_UIResponder)responder
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:responderWillDeactivate:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding responderWillDeactivate:responder];
     }];
}

- (void)                                      binding:(req_AKAKeyboardControlViewBinding)binding
                               responderDidDeactivate:(req_UIResponder)responder
{
    [self propagateBindingDelegateMethod:@selector(controller:binding:responderDidDeactivate:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding responderDidDeactivate:responder];
     }];
}

#pragma mark - AKACollectionControlViewBindingDelegate

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                    sourceControllerWillChangeContent:(req_id)sourceDataController
{
    [self propagateBindingDelegateMethod:@selector(control:binding:sourceControllerWillChangeContent:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding sourceControllerWillChangeContent:sourceDataController];
     }];
}

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                         insertedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    [self propagateBindingDelegateMethod:@selector(control:binding:sourceController:insertedItem:atIndexPath:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding sourceController:sourceDataController insertedItem:sourceCollectionItem atIndexPath:indexPath];
     }];
}

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          updatedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    [self propagateBindingDelegateMethod:@selector(control:binding:sourceController:updatedItem:atIndexPath:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding sourceController:sourceDataController updatedItem:sourceCollectionItem atIndexPath:indexPath];
     }];
}

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                          deletedItem:(opt_id)sourceCollectionItem
                                          atIndexPath:(req_NSIndexPath)indexPath
{
    [self propagateBindingDelegateMethod:@selector(control:binding:sourceController:deletedItem:atIndexPath:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding sourceController:sourceDataController deletedItem:sourceCollectionItem atIndexPath:indexPath];
     }];
}

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                                     sourceController:(req_id)sourceDataController
                                            movedItem:(opt_id)sourceCollectionItem
                                        fromIndexPath:(req_NSIndexPath)fromIndexPath
                                          toIndexPath:(req_NSIndexPath)toIndexPath
{
    [self propagateBindingDelegateMethod:@selector(control:binding:sourceController:movedItem:fromIndexPath:toIndexPath:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding sourceController:sourceDataController movedItem:sourceCollectionItem fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
     }];
}

- (void)                                      binding:(req_AKACollectionControlViewBinding)binding
                     sourceControllerDidChangeContent:(req_id)sourceDataController
{
    [self propagateBindingDelegateMethod:@selector(control:binding:sourceControllerDidChangeContent:)
                              usingBlock:
     ^(id<AKABindingControllerDelegate> delegate, outreq_BOOL stop __unused)
     {
         [delegate controller:self binding:binding sourceControllerDidChangeContent:sourceDataController];
     }];
}

@end
