//
//  AKABindingController+BindingInitialization.m
//  AKABeacon
//
//  Created by Michael Utech on 25.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController+BindingInitialization.h"
#import "AKABindingController_BindingInitializationProperties.h"

#import "AKABindingController+BindingDelegate.h"
#import "AKABindingController+BindingContextProtocol.h"
#import "AKABindingController+KeyboardActivationSequence.h"

#import "AKABindingTargetContainerProtocol.h"
#import "AKABindingExpression+Accessors.h"

#import "AKABeaconErrors.h"
#import "UIView+AKAHierarchyVisitor.m"


#pragma mark - AKABindingController(BindingInitialization) - Implementation
#pragma mark -

@implementation AKABindingController(BindingInitialization)

- (BOOL)         addBindingsForTargetObjectHierarchy:(req_id)rootTarget
                                excludeTargetObjects:(NSSet<id>*)excludedTargets
                                               error:(out_NSError)error
{
    [self willUpdateBindings];

    BOOL result = [self _addBindingsForTargetObjectHierarchy:rootTarget
                                        excludeTargetObjects:excludedTargets
                                                       error:error];
    [self didUpdateBindings];

    return result;
}

- (BOOL)        _addBindingsForTargetObjectHierarchy:(req_id)rootTarget
                                excludeTargetObjects:(NSSet<id>*)excludedTargets
                                               error:(out_NSError)error
{
    __block BOOL result = [self addBindingsForTarget:rootTarget
                                               error:error];

    if (result && [rootTarget conformsToProtocol:@protocol(AKABindingTargetContainerProtocol)])
    {
        id<AKABindingTargetContainerProtocol> container = rootTarget;

        [container aka_enumeratePotentialBindingTargetsUsingBlock:
         ^(id  _Nonnull bindingTarget, BOOL * _Nonnull stop)
         {
             if (!excludedTargets || ![excludedTargets containsObject:bindingTarget])
             {
                 result = [self _addBindingsForTargetObjectHierarchy:bindingTarget
                                                excludeTargetObjects:excludedTargets
                                                               error:error];
             }
             *stop = !result;
         }];
    }

    return result;
}

- (BOOL)                        addBindingsForTarget:(id)target
                                               error:(out_NSError)error
{
    __block BOOL result = YES;

    [AKABindingExpression enumerateBindingExpressionsForTarget:target
                                                     withBlock:
     ^(SEL  _Nonnull                    property,
       AKABindingExpression * _Nonnull  bindingExpression,
       BOOL * _Nonnull                  stop)
     {
         NSError* localError = nil;
         AKABinding* binding = [self addBindingForTarget:target
                                                property:property
                                       bindingExpression:bindingExpression
                                                   error:&localError];
         if (binding != nil)
         {
             if (self.isObservingChanges)
             {
                 [binding startObservingChanges];
             }
         }
         else
         {
             result = NO;
             AKARegisterErrorInErrorStore(localError, error);
         }

         *stop = !result;
     }];

    return result;
}

/**
 Creates and adds a new binding to the specified binding target based on the specified bindingExpression associated with the target's binding expression property.

 Please note that you have to specify a defined error parameter to distinguish errors from vetoes to add the binding (delegate).

 @param target            the target (typically a UIView)
 @param property          the view's property containing the binding expression
 @param bindingExpression the binding expression
 @param error             error details.

 @return The new binding or nil if an error occured or the delegate vetoed the addition.
 */
- (AKABinding*)                  addBindingForTarget:(req_id)target
                                            property:(req_SEL)property
                                   bindingExpression:(req_AKABindingExpression)bindingExpression
                                               error:(out_NSError)error
{
    NSError* localError = nil;
    AKABinding* binding = nil;

    Class bindingType = bindingExpression.specification.bindingType;
    NSAssert([bindingType isSubclassOfClass:[AKABinding class]],
             @"Failed to add binding for view %@: Binding expression %@'s binding type is not an instance of AKABinding", target, bindingExpression);

    if ([self shouldAddBindingOfType:bindingType
                           forTarget:target
                            property:property
                   bindingExpression:bindingExpression])
    {
        binding = [bindingType bindingToTarget:target
                                withExpression:bindingExpression
                                       context:self
                                      delegate:self
                                         error:&localError];
        if (binding)
        {
            [self willAddBinding:binding forTarget:target property:property bindingExpression:bindingExpression];

            [self.bindings addObject:binding];

            [self didAddBinding:binding forTarget:target property:property bindingExpression:bindingExpression];

            if (self.isObservingChanges)
            {
                [binding startObservingChanges];
            }
        }
        else
        {
            [self failedToCreateBindingOfType:bindingType
                                    forTarget:target
                                     property:property
                            bindingExpression:bindingExpression
                                    withError:localError];
            if (error)
            {
                *error = localError;
            }
        }
    }

    return binding;
}

#pragma mark - Delegate Support

- (void)                          willUpdateBindings
{
    return;
}

- (BOOL)                      shouldAddBindingOfType:(req_Class)bindingType
                                           forTarget:(req_id)target
                                            property:(req_SEL)bindingProperty
                                   bindingExpression:(req_AKABindingExpression)bindingExpression
{
    BOOL result = YES;

    id<AKABindingControllerDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(shouldController:addBindingOfType:forTarget:property:bindingExpression:)])
    {
        result = [delegate shouldController:self
                           addBindingOfType:bindingType
                                  forTarget:target
                                   property:bindingProperty
                          bindingExpression:bindingExpression];
    }

    return result;
}

- (void)                              willAddBinding:(req_AKABinding)binding
                                           forTarget:(req_id)target
                                            property:(req_SEL)bindingProperty
                                   bindingExpression:(req_AKABindingExpression)bindingExpression
{
    id<AKABindingControllerDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(controller:willAddBinding:forTarget:property:bindingExpression:)])
    {
        [delegate controller:self
              willAddBinding:binding
                   forTarget:target
                    property:bindingProperty
           bindingExpression:bindingExpression];
    }
}

- (void)                 failedToCreateBindingOfType:(req_Class)bindingType
                                           forTarget:(req_id)target
                                            property:(req_SEL)bindingProperty
                                   bindingExpression:(req_AKABindingExpression)bindingExpression
                                           withError:(req_NSError)error
{
    id<AKABindingControllerDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(controller:failedToCreateBindingOfType:forTarget:property:bindingExpression:withError:)])
    {
        [delegate           controller:self
           failedToCreateBindingOfType:bindingType
                             forTarget:target
                              property:bindingProperty
                     bindingExpression:bindingExpression
                             withError:error];
    }
}

- (void)                               didAddBinding:(req_AKABinding)binding
                                           forTarget:(req_id)target
                                            property:(req_SEL)bindingProperty
                                   bindingExpression:(req_AKABindingExpression)bindingExpression
{
    if ([binding conformsToProtocol:@protocol(AKAKeyboardActivationSequenceItemProtocol)])
    {
        [self.keyboardActivationSequence setNeedsUpdate];
    }

    id<AKABindingControllerDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(controller:didAddBinding:forTarget:property:bindingExpression:)])
    {
        [delegate controller:self
               didAddBinding:binding
                   forTarget:target
                    property:bindingProperty
           bindingExpression:bindingExpression];
    }
}

- (void)                           didUpdateBindings
{
    [self.keyboardActivationSequence updateIfNeeded];
}

@end
