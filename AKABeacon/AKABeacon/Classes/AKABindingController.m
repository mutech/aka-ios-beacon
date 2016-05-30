//
//  AKABindingController.m
//  AKABeacon
//
//  Created by Michael Utech on 18.05.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABindingController_Internal.h"

#import "AKABindingController_BindingInitializationProperties.h"
#import "AKABindingController_ChildBindingControllersProperties.h"
#import "AKABindingController_KeyboardActivationSequenceProperties.h"

#import "AKABindingController+ChildBindingControllers.h"
#import "AKABindingController+BindingInitialization.h"
#import "AKABindingController+BindingContextProtocol.h"
#import "AKABindingController+KeyboardActivationSequence.h"


#import "AKAErrors.h"

#import <objc/runtime.h>


#pragma mark - AKABindingController - Private Interface
#pragma mark -

@interface AKABindingController()

#pragma mark - Data Properties

@property(nonatomic, weak)           id<AKABindingControllerDelegate>       delegate;
@property(nonatomic, weak)           AKABindingController*                  parent;
@property(nonatomic, weak)           id                                     targetObjectHierarchy;
@property(nonatomic)                 BOOL                                   isObservingChanges;

/**
 This has to be set by concrete sub classes after calling initWithParent:targetObjectHierarchy:delegate:error: and cannot be changed once set to a defined value.
 */
@property(nonatomic, nonnull, strong) AKAProperty* dataContextProperty;

#pragma mark - Private

/**
 A set of target object hierarchies which should be ignored when creating bindings.
 
 The default implementation returns a set of all top-level views of child view controllers of this binding context's viewController or nil if there are none or if viewController is nil.
 */
@property(nonatomic, readonly) NSSet<id>*                                   excludedTargetObjectHieraries;

@end


#pragma mark - AKABindingController - Implementation
#pragma mark -

@implementation AKABindingController

#pragma mark - Initialization

+ (opt_instancetype)bindingControllerForViewController:(req_UIViewController)viewController
                                       withDataContext:(opt_id)dataContext
                                              delegate:(opt_AKABindingControllerDelegate)delegate
                                                 error:(out_NSError)error
{
    return [[AKAIndependentBindingController alloc] initWithParent:nil
                                             targetObjectHierarchy:viewController
                                                       dataContext:dataContext
                                                          delegate:delegate
                                                             error:error];
}

- (instancetype)                                  init
{
    if (self = [super init])
    {
        _bindings = [NSMutableSet new];
    }

    return self;
}

- (instancetype)                        initWithParent:(opt_AKABindingController)parent
                                 targetObjectHierarchy:(req_id)targetObjectHierarchy
                                              delegate:(opt_AKABindingControllerDelegate)delegate
{
    if (self = [self init])
    {
        _parent = parent;
        _targetObjectHierarchy = targetObjectHierarchy;
        _delegate = delegate;
    }
    return self;
}

- (void)                                       dealloc
{
    [self stopObservingChanges];
}


#pragma mark - Access

- (id)                                     dataContext
{
    AKAErrorAbstractMethodImplementationMissing();
}

- (id)                              dataContextForView:(UIView *)view
{
    id result = nil;

    if (view == self.view)
    {
        result = self.dataContext;
    }
    else
    {
        AKABindingController* controller = [AKABindingController bindingControllerManagingView:view];

        if (controller)
        {
            result = controller.dataContext;
        }
    }
    return result;
}

- (void)enumerateBindingsUsingBlock:(void (^)(AKABinding * _Nonnull, BOOL * _Nonnull))block
{
    [self.bindings enumerateObjectsUsingBlock:block];
}

- (void)enumerateBindingControllersUsingBlock:(void (^)(AKABindingController *, BOOL * _Nonnull))block
{
    BOOL stop = NO;
    for (AKABindingController* childController in self.childBindingControllers.objectEnumerator)
    {
        block(childController, &stop);
        if (stop)
        {
            break;
        }
    }
}

#pragma mark - Change Tracking

- (void)                         startObservingChanges
{
    [self.bindings enumerateObjectsUsingBlock:
     ^(AKABinding * _Nonnull binding, BOOL * _Nonnull stop __unused)
     {
         [binding startObservingChanges];
     }];
    [self startObservingChangesInChildBindingControllers];

    [self.dataContextProperty startObservingChanges];
    self.isObservingChanges = YES;
}

- (void)                          stopObservingChanges
{
    [self.dataContextProperty stopObservingChanges];

    [self stopObservingChangesInChildBindingControllers];
    [self removeAllBindingControllersEnqueueForReuse:NO];

    [self.bindings enumerateObjectsWithOptions:NSEnumerationReverse
                                    usingBlock:
     ^(AKABinding * _Nonnull binding, BOOL * _Nonnull stop __unused)
     {
         [binding stopObservingChanges];
     }];

    self.isObservingChanges = NO;
}

#pragma mark - Private

- (NSSet<id> *)          excludedTargetObjectHieraries
{
    NSSet* result = nil;

    UIViewController* viewController = self.viewController;
    if (viewController)
    {
        NSArray* rootViews = [viewController valueForKeyPath:@"childViewControllers.view"];
        if (rootViews.count > 0)
        {
            result = [NSSet setWithArray:rootViews];
        }
    }

    return result;
}

@end


#pragma mark - AKAIndependentBindingController
#pragma mark -

@implementation AKAIndependentBindingController

- (instancetype)                        initWithParent:(opt_AKABindingController)parent
                                 targetObjectHierarchy:(req_id)targetObjectHierarchy
                                           dataContext:(opt_id)dataContext
                                              delegate:(opt_AKABindingControllerDelegate)delegate
                                                 error:(out_NSError)error
{
    if (self = [self initWithParent:parent
              targetObjectHierarchy:targetObjectHierarchy
                           delegate:delegate])
    {
        _dataContext = dataContext;
        self.dataContextProperty = [AKAProperty propertyOfWeakTarget:self
                                                          getter:
                                ^id _Nullable(id  _Nonnull target) {
                                    return ((AKABindingController*)target).dataContext;
                                }
                                                          setter:
                                ^(id  _Nonnull target, id  _Nullable value) {
                                    ((AKAIndependentBindingController*)target).dataContext = value;
                                }
                                              observationStarter:nil
                                              observationStopper:nil];

        if ([self addBindingsForTargetObjectHierarchy:targetObjectHierarchy
                                 excludeTargetObjects:self.excludedTargetObjectHieraries
                                                error:error])
        {
            if (parent == nil)
            {
                [self initializeKeyboardActivationSequence];
            }
        }
        else
        {
            self = nil;
        }
    }
    return self;
}

@synthesize dataContext = _dataContext;

- (id)dataContext
{
    return _dataContext;
}

- (void)setDataContext:(id)dataContext
{
    id oldDataContext = self.dataContext;
    _dataContext = dataContext;
    [self.dataContextProperty notifyPropertyValueDidChangeFrom:oldDataContext
                                                            to:dataContext];
}

@end


#pragma mark - AKADependentBindingController
#pragma mark -

@implementation AKADependentBindingController

- (instancetype)                        initWithParent:(req_AKABindingController)parent
                                 targetObjectHierarchy:(req_id)targetObjectHierarchy
                                  dataContextAtKeyPath:(opt_NSString)keyPath
                                              delegate:(opt_AKABindingControllerDelegate)delegate
                                                 error:(out_NSError)error
{
    if (self = [self initWithParent:parent
              targetObjectHierarchy:targetObjectHierarchy
                           delegate:delegate])
    {
        self.dataContextProperty = [parent dataContextPropertyForKeyPath:keyPath
                                                      withChangeObserver:nil];

        if ([self addBindingsForTargetObjectHierarchy:targetObjectHierarchy
                                 excludeTargetObjects:self.excludedTargetObjectHieraries
                                                error:error])
        {
            if (parent == nil)
            {
                [self initializeKeyboardActivationSequence];
            }
        }
        else
        {
            self = nil;
        }
    }
    return self;
}

- (id)dataContext
{
    return self.dataContextProperty.value;
}

@end


#pragma mark - AKABindingController(Conveniences) - Implementation
#pragma mark -

@implementation AKABindingController(Conveniences)

- (UIView *)                                      view
{
    UIView* result;

    id targetObjectHierarchy = self.targetObjectHierarchy;
    if ([targetObjectHierarchy isKindOfClass:[UIViewController class]])
    {
        result = ((UIViewController*)targetObjectHierarchy).view;
    }
    else if ([targetObjectHierarchy isKindOfClass:[UIView class]])
    {
        result = self.targetObjectHierarchy;
    }

    return result;
}

- (UIViewController *)                  viewController
{
    UIViewController* result;

    id targetObjectHierarchy = self.targetObjectHierarchy;
    if ([targetObjectHierarchy isKindOfClass:[UIViewController class]])
    {
        result = targetObjectHierarchy;
    }
    else
    {
        result = self.parent.viewController;
    }

    return result;
}

@end