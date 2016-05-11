//
//  AKAControl.m
//  AKABeacon
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons;

#import <objc/runtime.h>

#import "AKAControl_Internal.h"
#import "AKACompositeControl.h"

#import "AKABeaconErrors_Internal.h"

// New bindings infrastructure
#import "AKABindingExpression+Accessors.h"
#import "AKAControl+BindingDelegate.h"
#import "NSObject+AKAAssociatedValues.h"

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
    NSAssert(result == nil ||
        [result isKindOfClass:[AKAControl class]],
        @"Item %@ registered as control in view %@ is not an instance of AKAControl", result, view);
    return (AKAControl*)result;
}

#pragma mark - Value Access

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
    return keyPath.length > 0 ? [self.dataContextProperty targetValueForKeyPath:keyPath] : self.dataContextProperty.value;
}

- (opt_AKAProperty) rootDataContextPropertyForKeyPath:(opt_NSString)keyPath
                                   withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange
{
    return [[self rootControl] dataContextPropertyForKeyPath:keyPath withChangeObserver:valueDidChange];
}

- (opt_id)             rootDataContextValueForKeyPath:(opt_NSString)keyPath
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

- (opt_id)                     controlValueForKeyPath:(opt_NSString)keyPath
{
    // TODO: consider using controlPropertyForKeyPath to use the AKAProperty keyPath
    // accessors
    return keyPath.length > 0 ? [self valueForKeyPath:(req_NSString)keyPath] : self.dataContextProperty.value;
}

@end


@implementation AKAControl(BindingsOwner)

- (NSUInteger)                     addBindingsForView:(req_UIView)view
{
    __block NSUInteger result = 0;

    [AKABindingExpression enumerateBindingExpressionsForTarget:view
                                                     withBlock:
     ^(req_SEL property, req_AKABindingExpression expression, outreq_BOOL stop)
     {
         (void)property;
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
                                             property:(SEL)bindingProperty
                                withBindingExpression:(req_AKABindingExpression)bindingExpression
{
    return [self addBindingForView:view
                          property:bindingProperty
             withBindingExpression:bindingExpression
                             error:nil];
}

- (BOOL)                            addBindingForView:(req_UIView)view
                                             property:(SEL)bindingProperty
                                withBindingExpression:(req_AKABindingExpression)bindingExpression
                                                error:(out_NSError)error
{
    __block BOOL result = NO;

    NSAssert([NSThread isMainThread],
             @"Control binding manipulation is only valid from main thread, please check the call stack and dispatch the action leading to this call to the main thread.");

    // Paranoia, if assert does not fire, dispatch to main thread as fallback:
    [self aka_performBlockInMainThreadOrQueue:
     ^{
         NSError* localError = nil;

         Class bindingType = bindingExpression.specification.bindingType;
         NSAssert([bindingType isSubclassOfClass:[AKAViewBinding class]],
                  @"Failed to add binding for view %@: Binding expression %@'s binding type is not an instance of AKAViewBinding", view, bindingExpression);

         if ([self shouldAddBindingOfType:bindingType
                                  forView:view
                                 property:bindingProperty
                    withBindingExpression:bindingExpression])
         {
             AKABinding* binding = [bindingType bindingToView:view
                                               withExpression:bindingExpression
                                                      context:self
                                                     delegate:self
                                                        error:&localError];
             if (binding)
             {
                 [self       willAddBinding:binding
                                    forView:view
                                   property:bindingProperty
                      withBindingExpression:bindingExpression];

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


                 [self        didAddBinding:binding
                                    forView:view
                                   property:bindingProperty
                      withBindingExpression:bindingExpression];

                 if (result && self.isObservingChanges)
                 {
                     [binding startObservingChanges];
                 }
             }
             else if (error == nil)
             {
                 @throw [NSException exceptionWithName:@"Unhandled error"
                                                reason:localError.localizedDescription
                                              userInfo:nil];
             }
             else
             {
                 *error = localError;
             }
         }
    } waitForCompletion:YES];

    return result;
}

- (BOOL)                                removeBinding:(AKABinding*)binding
{
    NSAssert([NSThread isMainThread],
             @"Control binding manipulation is only valid from main thread, please check the call stack and dispatch the action leading to this call to the main thread.");


    __block BOOL result = NO;

    // Paranoia, if assert does not fire, dispatch to main thread as fallback:
    [self aka_performBlockInMainThreadOrQueue:
     ^{
        NSUInteger index = [self.bindings indexOfObjectIdenticalTo:binding];
        BOOL localResult = index != NSNotFound;
        if (localResult)
        {
            [self willRemoveBinding:binding];

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

            [self didRemoveBinding:binding];
        }
    } waitForCompletion:YES];
    return result;
}

- (BOOL)                       shouldAddBindingOfType:(Class)bindingType
                                              forView:(req_UIView)view
                                             property:(SEL)bindingProperty
                                withBindingExpression:(req_AKABindingExpression)bindingExpression
{
    BOOL result = YES;

    AKACompositeControl* owner = self.owner;
    if (owner)
    {
        result = [owner control:self
              shouldAddBindingOfType:bindingType
                             forView:view
                            property:bindingProperty
               withBindingExpression:bindingExpression];
    }

    return result;
}

- (void)                               willAddBinding:(AKABinding*)binding
                                              forView:(req_UIView)view
                                             property:(SEL)bindingProperty
                                withBindingExpression:(req_AKABindingExpression)bindingExpression
{
    [self.owner         control:self
                 willAddBinding:binding
                        forView:view
                       property:bindingProperty
          withBindingExpression:bindingExpression];
}

- (void)                                didAddBinding:(AKABinding*)binding
                                              forView:(req_UIView)view
                                             property:(SEL)bindingProperty
                                withBindingExpression:(req_AKABindingExpression)bindingExpression
{
    [self.owner         control:self
                  didAddBinding:binding
                        forView:view
                       property:bindingProperty
          withBindingExpression:bindingExpression];
}

- (void)                            willRemoveBinding:(AKABinding*)binding
{
    [self.owner         control:self
              willRemoveBinding:binding];
}

- (void)                             didRemoveBinding:(AKABinding*)binding
{
    [self.owner         control:self
               didRemoveBinding:binding];
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

