//
//  AKAControl.m
//  AKABeacon
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKALog;
@import AKACommons.NSObject_AKAConcurrencyTools;
@import AKACommons.NSObject_AKAAssociatedValues;

#import <objc/runtime.h>

#import "AKAControl_Internal.h"
#import "AKACompositeControl.h"

#import "AKABeaconErrors_Internal.h"

// New bindings infrastructure
#import "UIView+AKABindingSupport.h"
#import "AKAKeyboardControlViewBinding.h"
#import "AKABinding.h"
#import "AKAControl+BindingDelegate.h"

@interface AKAControl()
{
    AKAProperty*  _dataContextProperty;}

#pragma mark - Bindings Storage

@property(nonatomic, nonnull) NSMutableArray<AKABinding*>*                  bindings;

#pragma mark - Theme Support

@property(nonatomic)NSMutableDictionary*                                    themeNameByType;

#pragma mark - Data Context

@property(nonatomic, strong, readonly, nullable) AKAProperty*               dataContextProperty;

#pragma mark - Change Tracking

@property(nonatomic, readonly) BOOL                                         isObservingChanges;

@end


@implementation AKAControl

@synthesize owner = _owner;

#pragma mark - Initialization

- (instancetype)                                 init
{
    if (self = [super init])
    {
        _bindings = [NSMutableArray new];
    }
    return self;
}

- (instancetype)                initWithConfiguration:(opt_AKAControlConfiguration)configuration
{
    if (self = [self init])
    {
        if (configuration != nil)
        {
            Class controlType = configuration[kAKAControlTypeKey];
            NSParameterAssert(controlType == nil || [[self class] isSubclassOfClass:controlType]);
            (void)controlType; // prevent unused warning in release build

            _name = configuration[kAKAControlNameKey];

            _role = configuration[kAKAControlRoleKey];

            NSString* controlTags = configuration[kAKAControlTagsKey];
            if (controlTags.length > 0)
            {
                NSCharacterSet* separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSArray<NSString*>* tags = [controlTags componentsSeparatedByCharactersInSet:separators];
                if (tags.count > 0)
                {
                    _tags = [NSSet setWithArray:tags];
                }
            }
        }
    }
    return self;
}

- (instancetype)                  initWithDataContext:(opt_id)dataContext
                                        configuration:(opt_AKAControlConfiguration)configuration
{
    if (self = [self initWithConfiguration:configuration])
    {
        self.dataContextProperty = [AKAProperty propertyOfWeakKeyValueTarget:dataContext
                                                                     keyPath:nil
                                                              changeObserver:nil];
    }
    return self;
}

- (instancetype)                        initWithOwner:(req_AKACompositeControl)owner
                                        configuration:(opt_AKAControlConfiguration)configuration
{
    if (self = [self initWithConfiguration:configuration])
    {
        [self setOwner:owner];
    }
    return self;
}

#pragma mark - Control Hierarchy

- (void)                                     setOwner:(AKACompositeControl *)owner
{
    AKACompositeControl* currentOwner = _owner;
    if (currentOwner != owner)
    {
        if (currentOwner != nil && owner != nil)
        {
            [AKABeaconErrors invalidAttemptToSetOwnerOfControl:self ownedBy:currentOwner toNewOwner:owner];
        }
        _owner = owner;
    }
}

- (void)                                      setView:(UIView *)view
{
    UIView* selfView = _view;
    NSParameterAssert(view == selfView || view == nil || selfView == nil);

    if (selfView == nil)
    {
        if ([self registerControlInControlView:view])
        {
            _view = view;
        }
    }
    else if (view == nil)
    {
        [self unregisterControlFromControlView:selfView];
        _view = view;
    }
}

static NSString* const kRegisteredControlKey = @"aka_control";

- (BOOL)registerControlInControlView:(UIView*)view
{
    AKAControl* registeredControl = [AKAControl registeredControlForView:view];
    BOOL result = registeredControl == nil;
    if (result)
    {
        [view aka_setAssociatedValue:[AKAWeakReference weakReferenceTo:self]
                              forKey:kRegisteredControlKey];
    }
    return result;
}

- (void)unregisterControlFromControlView:(UIView*)view
{
    [view aka_removeValueAssociatedWithKey:kRegisteredControlKey];
}

+ (opt_AKAControl)registeredControlForView:(req_UIView)view
{
    id result = [view aka_associatedValueForKey:kRegisteredControlKey];
    if ([result isKindOfClass:[AKAWeakReference class]])
    {
        result = ((AKAWeakReference*)result).value;
    }
    NSAssert(result == nil || [result isKindOfClass:[AKAControl class]], @"Item %@ registered as control in view %@ is not an instance of AKAControl", result, view);
    return (AKAControl*)result;
}

#pragma mark - Value Access

#pragma mark - Value access

- (opt_id)dataContext
{
    return self.dataContextProperty.value;
}

- (AKAProperty *)                 dataContextProperty
{
    return _dataContextProperty != nil ? _dataContextProperty : self.owner.dataContextProperty;
}

- (void)                       setDataContextProperty:(AKAProperty *)dataContextProperty
{
    _dataContextProperty = dataContextProperty;
}

#pragma mark - Validation

- (BOOL)                                      isValid
{
    return self.validationError == nil;
}

- (void)                           setValidationState:(AKAControlValidationState)validationState
                                            withError:(opt_NSError)error
{
    // TODO: refactor error handling again...
    _validationState = validationState;
    _validationError = error;
}

#pragma mark Controlling Observation

- (void)                        startObservingChanges
{
    for (AKABinding* binding in self.bindings)
    {
        [binding startObservingChanges];
    }
    _isObservingChanges = YES;
}

- (void)                         stopObservingChanges
{
    for (AKABinding* binding in self.bindings)
    {
        [binding stopObservingChanges];
    }
    _isObservingChanges = NO;
}

@end


#pragma mark - AKAControl(BindingContext)
#pragma mark -

@implementation AKAControl(BindingContext)

- (AKAControl*)                           rootControl
{
    AKAControl* result = self;
    while (result.owner != nil)
    {
        result = result.owner;
    }
    return result;
}

- (opt_AKAProperty)     dataContextPropertyForKeyPath:(opt_NSString)keyPath
                                   withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange
{
    opt_AKAProperty result = nil;
    // TODO: check if there are cases where callers expect an undefined result for an undefined keyPath
    // Binding expression "$data" results in an empty key path and should evaluate to the data context
    // itself.
    result = [self.dataContextProperty propertyAtKeyPath:(req_NSString)keyPath
                                      withChangeObserver:valueDidChange];
    return result;
}

- (id)                     dataContextValueForKeyPath:(NSString *)keyPath
{
    return [self.dataContextProperty targetValueForKeyPath:keyPath];
}

- (opt_AKAProperty) rootDataContextPropertyForKeyPath:(opt_NSString)keyPath
                                   withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange
{
    return [[self rootControl] dataContextPropertyForKeyPath:keyPath withChangeObserver:valueDidChange];
}

- (opt_id)             rootDataContextValueForKeyPath:(req_NSString)keyPath
{
    return [[self rootControl] dataContextValueForKeyPath:keyPath];
}

- (opt_AKAProperty)         controlPropertyForKeyPath:(req_NSString)keyPath
                                   withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self
                                             keyPath:keyPath
                                      changeObserver:valueDidChange];
}

- (opt_id)                     controlValueForKeyPath:(req_NSString)keyPath
{
    // TODO: consider using controlPropertyForKeyPath to use the AKAProperty keyPath
    // accessors
    return [self valueForKeyPath:keyPath];
}

@end


@implementation AKAControl(BindingsOwner)

- (NSUInteger)                     addBindingsForView:(req_UIView)view
{
    __block NSUInteger result = 0;

    [view aka_enumerateBindingExpressionsWithBlock:^(req_SEL property,
                                                     req_AKABindingExpression expression,
                                                     outreq_BOOL stop)
     {
         (void)stop;

         if ([self addBindingForView:view
                            property:property
               withBindingExpression:expression])
         {
             ++result;
         }
     }];

    return result;
}

- (BOOL)                            addBindingForView:(req_UIView)view
                                             property:(req_SEL)property
                                withBindingExpression:(req_AKABindingExpression)bindingExpression
{
    NSAssert([[NSThread currentThread] isMainThread], @"Binding manipulation outside of main thread");

    BOOL result = NO;
    NSError* error;

    Class bindingType = bindingExpression.specification.bindingType;
    NSAssert([bindingType isSubclassOfClass:[AKAViewBinding class]],
             @"Failed to add binding for view %@: Binding expression %@'s binding type is not an instance of AKAViewBinding", view, bindingExpression);

    AKAViewBinding* binding = [bindingType alloc];
    binding = [binding   initWithView:view
                             property:property
                           expression:bindingExpression
                              context:self
                             delegate:self
                                error:&error];
    if (binding)
    {
        result = [self addBinding:binding];
        if (result && self.isObservingChanges)
        {
            [binding startObservingChanges];
        }
    }
    return result;
}

- (BOOL)                                   addBinding:(AKABinding*)binding
{
    __block BOOL result = NO;

    // Paranoia: Binding should only be manipulated from main thread, on the other hand
    // if this is called from a different thread, there is a possibility for a dead lock
    // since we are and probably have to wait for completion. So better make sure this
    // is called from main than to rely on this:
    [self aka_performBlockInMainThreadOrQueue:^{
        if ([binding isKindOfClass:[AKAControlViewBinding class]])
        {
            AKAControlViewBinding* oldCVB = self.controlViewBinding;
            NSAssert(oldCVB == nil, @"Invalid attempt to add control view binding %@ to control %@: control already has a defined control view binding %@", binding, self, oldCVB);
            if (oldCVB == nil)
            {
                self.view = ((AKAControlViewBinding*)binding).view;
                result = YES;
                self->_controlViewBinding = (id)binding;
            }
        }
        else
        {
            // TODO: consider testing if a binding to the same property&view is already present
            result = YES;
        }

        if (result)
        {
            [self.bindings addObject:binding];
        }
    } waitForCompletion:YES];

    return result;
}

- (BOOL)                                removeBinding:(AKABinding*)binding
{
    NSAssert([[NSThread currentThread] isMainThread], @"Binding manipulation outside of main thread");

    __block BOOL result = NO;
    // Paranoia: Binding should only be manipulated from main thread, on the other hand
    // if this is called from a different thread, there is a possibility for a dead lock
    // since we are and probably have to wait for completion. So better make sure this
    // is called from main than to rely on this:
    [self aka_performBlockInMainThreadOrQueue:^{
        NSUInteger index = [self.bindings indexOfObjectIdenticalTo:binding];
        BOOL localResult = index != NSNotFound;
        if (localResult)
        {
            [binding stopObservingChanges];
            [self.bindings removeObjectAtIndex:index];

            if ([binding isKindOfClass:[AKAControlViewBinding class]])
            {
                AKAControlViewBinding* controlViewBinding = self.controlViewBinding;
                if (binding == controlViewBinding)
                {
                    // TODO: what about other bindings? They don't need self.view, but it might
                    // have been set directly. Probably not really a problem
                    self.view = nil;
                    self->_controlViewBinding = nil;
                }
                else
                {
                    NSAssert(NO, @"Internal inconsistency: control view binding %@ removed from control %@ which references another control view binding %@", binding, self, controlViewBinding);
                }
            }
        }
    } waitForCompletion:YES];
    return result;
}

@end


@implementation UIView(AKARegisteredControl)

- (opt_AKAControl)aka_boundControl
{
    return [AKAControl registeredControlForView:self];
}

@end


////

@implementation AKAControl(ObsoleteThemeSupport)

#pragma mark - Theme Selection

- (AKAProperty*)themeNamePropertyForView:(UIView*)view
                          changeObserver:(void(^)(id oldValue, id newValue))themeNameChanged
{
    AKAProperty* result = nil;
    NSString* themeName;
    if (self.themeNameByType != nil)
    {
        for (Class type = view.class; [type isSubclassOfClass:[UIView class]]; type = [type superclass])
        {
            NSString* typeName = NSStringFromClass(type);
            themeName = self.themeNameByType[typeName];
            if (themeName)
            {
                result = [AKAProperty propertyOfWeakKeyValueTarget:self.themeNameByType
                                                           keyPath:typeName
                                                    changeObserver:themeNameChanged];
                break;
            }
        }
    }
    if (!result)
    {
        result = [self.owner themeNamePropertyForView:view
                                       changeObserver:themeNameChanged];
    }
    return result;
}

- (void)setThemeName:(NSString*)themeName forClass:(Class)type
{
    if (!self.themeNameByType)
    {
        self.themeNameByType = NSMutableDictionary.new;
    }
    self.themeNameByType[NSStringFromClass(type)] = themeName;
}

@end

