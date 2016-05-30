//
//  AKABindingController+ChildBindingControllers.m
//  AKABeacon
//
//  Created by Michael Utech on 24.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController+ChildBindingControllers.h"
#import "AKABindingController_ChildBindingControllersProperties.h"
#import "AKABindingController_Internal.h"

#import <objc/runtime.h>


#pragma mark - AKABindingController(ChildBindingControllers) - Implementation
#pragma mark -

@implementation AKABindingController(ChildBindingControllers)

#pragma mark - Constants

// Key for storing a child binding controller as associated object with a target object hierarchy.
static const char kTargetObjectHierarchyBindingControllerToken = 0;

#pragma mark - Child Controller Storage

- (NSHashTable<AKABindingController*>*)childBindingControllersCreateIfNeeded:(BOOL)createIfNeeded
{
    if (self.childBindingControllers == nil && createIfNeeded)
    {
        self.childBindingControllers = [NSHashTable weakObjectsHashTable];
    }
    return self.childBindingControllers;
}

#pragma mark - Creating and Removing Child Controllers

+ (instancetype)bindingControllerManagingView:(UIView*)view
{
    AKABindingController* result = nil;

    if (view)
    {
        result = objc_getAssociatedObject(view, &kTargetObjectHierarchyBindingControllerToken);
        if (!result)
        {
            UIView* superview = view.superview;
            if (superview)
            {
                result = [self bindingControllerManagingView:superview];
            }
        }
    }

    return result;
}

- (void)beginUpdatingChildControllers
{
    //NSAssert(self.updatedChildBindingControllers == nil, @"beginUpdatingChildControllers: previous session still active or not terminated");

    self.updatedChildBindingControllers = [NSHashTable weakObjectsHashTable];
}

- (void)endUpdatingChildControllers
{
    //NSAssert(self.updatedChildBindingControllers != nil, @"endUpdatingChildControllers: no update session to end");

    //self.updatedChildBindingControllers = nil;
}

- (opt_instancetype) createOrReuseBindingControllerForTargetObjectHierarchy:(req_id)targetObjectHierarchy
                                                   withDataContextAtKeyPath:(opt_NSString)keyPath
                                                                      error:(out_NSError)error
{
    if (![self discardRecycledBindingControllerForTargetObjectHierarchy:targetObjectHierarchy])
    {
        // TODO: error handling: throw but create exception in AKABeaconErrors
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Attempt to manage a binding target object which is used by a different binding controller."
                                     userInfo:nil];
    }
    AKADependentBindingController* result =
        [[AKADependentBindingController alloc] initWithParent:self
                                        targetObjectHierarchy:targetObjectHierarchy
                                         dataContextAtKeyPath:keyPath
                                                     delegate:nil
                                                        error:error];

    if (result != nil)
    {
        objc_setAssociatedObject(targetObjectHierarchy,
                                 &kTargetObjectHierarchyBindingControllerToken,
                                 result,
                                 OBJC_ASSOCIATION_RETAIN);
    }

    if (self.isObservingChanges && !result.isObservingChanges)
    {
        [result startObservingChanges];
    }
    
    return result;

}

- (instancetype)bindingControllerForTargetObjectHierarchy:(id)targetObjectHierarchy
                                          withDataContext:(id)dataContext
                                   createOrReuseIfMissing:(BOOL)createOrReuseIfMissing
                                                    error:(out_NSError)error
{
    // TODO: implement
    return nil;
}

- (AKABindingController*)createOrReuseBindingControllerForTargetObjectHierarchy:(id)targetObjectHierarchy
                                                                withDataContext:(id)dataContext
                                                                          error:(out_NSError)error
{
    NSHashTable<AKABindingController*>* children = [self childBindingControllersCreateIfNeeded:YES];

    AKABindingController* result = [self reuseBindingControllerForTargetObjectHierarchy:targetObjectHierarchy];

    // A dependent binding controller does not support updating the data context and thus
    // cannot be reused here. We will attempt to discard it:
    if (result && ![result isKindOfClass:[AKAIndependentBindingController class]])
    {
        if ([self discardRecycledBindingController:result
                          forTargetObjectHierarchy:targetObjectHierarchy])
        {
            // Done, we'll create a new dependent controller
            result = nil;
        }
        else
        {
            // TODO: error handling: throw but create exception in AKABeaconErrors
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Attempt to manage a binding target object which is used by a different binding controller."
                                         userInfo:nil];
        }
    }

    BOOL active = result != nil && [children containsObject:result];
    id previousDataContext = result.dataContext;
    BOOL unchanged = result != nil && previousDataContext == dataContext;
    BOOL isNew = NO;

    if (result == nil)
    {
        result = [[AKAIndependentBindingController alloc] initWithParent:self
                                                   targetObjectHierarchy:targetObjectHierarchy
                                                             dataContext:dataContext
                                                                delegate:nil
                                                                   error:error];
        if (result != nil)
        {
            isNew = YES;
            objc_setAssociatedObject(targetObjectHierarchy,
                                     &kTargetObjectHierarchyBindingControllerToken,
                                     result,
                                     OBJC_ASSOCIATION_RETAIN);
            unchanged = YES;
        }
    }

    if (!active)
    {
        [children addObject:result];
    }


    if (!isNew)
    {
        [self.updatedChildBindingControllers addObject:result];
    }

    if (!unchanged)
    {
        NSAssert([result isKindOfClass:[AKAIndependentBindingController class]], @"Expected an independent binding controller here");
        ((AKAIndependentBindingController*)result).dataContext = dataContext;
    }

    if (self.isObservingChanges && !result.isObservingChanges)
    {
        [result startObservingChanges];
    }

    return result;
}

- (BOOL)removeBindingControllerForTargetObjectHierarchy:(id)targetObjectHierarchy
                                          enqueForReuse:(BOOL)enqueueForReuse//XX
{
    BOOL result = NO;
    //BOOL enqueueForReuse = NO;

    // Using reuseBinding.. to check the ownership of the child controller. If the targetObjectHierarchy had a non-active child controller owned by another parent, it will be removed from there, if it is active there, this will lead to an exception.
    AKABindingController* controller = [self reuseBindingControllerForTargetObjectHierarchy:targetObjectHierarchy];

    if (controller)
    {
        NSHashTable<AKABindingController*>* children = [self childBindingControllersCreateIfNeeded:NO];

        if ([children containsObject:controller])
        {
            if (![self.updatedChildBindingControllers containsObject:controller])
            {
                [controller stopObservingChanges];
                [children removeObject:controller];
                if (enqueueForReuse)
                {
                    if (self.recycledChildBindingControllers == nil)
                    {
                        self.recycledChildBindingControllers = [NSHashTable weakObjectsHashTable];
                    }
                    [self.recycledChildBindingControllers addObject:controller];
                }
                else
                {
                    [self discardRecycledBindingController:controller
                                  forTargetObjectHierarchy:targetObjectHierarchy];
                }
                result = YES;
            }
            else
            {
                [self.updatedChildBindingControllers removeObject:controller];
            }
        }
    }

    return result;
}

- (void)removeAllBindingControllersEnqueueForReuse:(BOOL)enqueueForReuse
{
    if (!enqueueForReuse)
    {
        for (AKABindingController* childController in self.childBindingControllers.objectEnumerator)
        {
            id target = childController.targetObjectHierarchy;
            if (target)
            {
                AKABindingController* parent = childController.parent;
                if (parent == self || parent == nil)
                {
                    objc_setAssociatedObject(target,
                                             &kTargetObjectHierarchyBindingControllerToken,
                                             nil,
                                             OBJC_ASSOCIATION_ASSIGN);
                }
            }
        }
    }
    [self.childBindingControllers removeAllObjects];
}

#pragma mark - Change Tracking

- (void)startObservingChangesInChildBindingControllers
{
    for (AKABindingController* childController in self.childBindingControllers)
    {
        [childController startObservingChanges];
    }
}

- (void)stopObservingChangesInChildBindingControllers
{
    for (AKABindingController* childController in self.childBindingControllers)
    {
        [childController stopObservingChanges];
    }
}

#pragma mark - Implementation

- (AKABindingController*)reuseBindingControllerForTargetObjectHierarchy:(id)targetObjectHierarchy
{
    AKABindingController* result = objc_getAssociatedObject(targetObjectHierarchy,
                                                            &kTargetObjectHierarchyBindingControllerToken);

    if (result)
    {
        // Check that targetObjectHierarchy has not been used by another binding controller which is still active.
        AKABindingController* parent = result.parent;
        if (parent != self)
        {
            if (![self discardRecycledBindingControllerForTargetObjectHierarchy:targetObjectHierarchy])
            {
                // TODO: error handling: throw but create exception in AKABeaconErrors
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:@"Attempt to manage a binding target object which is used by a different binding controller."
                                             userInfo:nil];
            }
            else
            {
                result = nil;
            }
        }
        else
        {
            if ([self.recycledChildBindingControllers containsObject:result])
            {
                [self.recycledChildBindingControllers removeObject:result];
            }
        }
    }

    return result;
}

- (BOOL)discardRecycledBindingControllerForTargetObjectHierarchy:(id)targetObjectHierarchy
{
    AKABindingController* controller = objc_getAssociatedObject(targetObjectHierarchy,
                                                                &kTargetObjectHierarchyBindingControllerToken);
    BOOL result = controller == nil;
    if (!result)
    {
        result = [self discardRecycledBindingController:controller
                               forTargetObjectHierarchy:targetObjectHierarchy];
    }
    return result;
}

- (BOOL)discardRecycledBindingController:(AKABindingController*)controller
                forTargetObjectHierarchy:(id)targetObjectHierarchy
{
    BOOL result = NO;

    if (controller)
    {
        AKABindingController* parent = controller.parent;
        if (parent == self && [self.childBindingControllers containsObject:controller])
        {
            // Do not discard if the controller is still active
            controller = nil;
        }

        if (controller)
        {
            if (parent == self || parent == nil)
            {
                objc_setAssociatedObject(targetObjectHierarchy,
                                         &kTargetObjectHierarchyBindingControllerToken,
                                         nil,
                                         OBJC_ASSOCIATION_ASSIGN);
                result = YES;
            }
            else
            {
                // Other parent: let it handle the deletion
                result = [parent discardRecycledBindingControllerForTargetObjectHierarchy:targetObjectHierarchy];
            }
        }
    }
    
    return result;
}

@end


