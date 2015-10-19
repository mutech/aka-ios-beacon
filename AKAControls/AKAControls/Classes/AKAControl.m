//
//  AKAControl.m
//  AKAControls
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.AKALog;
@import AKACommons.NSObject_AKAConcurrencyTools;

#import <objc/runtime.h>

#import "AKAControl_Internal.h"
#import "AKACompositeControl.h"

#import "AKAControlsErrors_Internal.h"

// New bindings infrastructure
#import "UIView+AKABindingSupport.h"
#import "AKAKeyboardControlViewBinding.h"
#import "AKABindingProvider.h"
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
            [AKAControlsErrors invalidAttemptToSetOwnerOfControl:self
                                                        ownedBy:currentOwner
                                                     toNewOwner:owner];
        }
        _owner = owner;
    }
}

- (void)                                      setView:(UIView *)view
{
    UIView* selfView = _view;
    NSParameterAssert(view == selfView || view == nil || selfView == nil);
    (void)selfView; // prevent warning in release build
    
    _view = view;
}

#pragma mark - Value Access

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
}

- (void)                         stopObservingChanges
{
    for (AKABinding* binding in self.bindings)
    {
        [binding stopObservingChanges];
    }
}

@end

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
    if (keyPath.length > 0)
    {
        result = [self.dataContextProperty propertyAtKeyPath:(req_NSString)keyPath
                                          withChangeObserver:valueDidChange];
    }
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
    // TODO: consider perserving the property for diagnostics & error reporting:
    (void)property;

    NSAssert([[NSThread currentThread] isMainThread], @"Binding manipulation outside of main thread");

    BOOL result = NO;
    AKABindingProvider* provider = bindingExpression.bindingProvider;
    AKABinding* binding = [provider bindingWithTarget:view
                                           expression:bindingExpression
                                              context:self
                                             delegate:self];
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
        [self.bindings addObject:binding];
        result = YES;
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
        }
    } waitForCompletion:YES];
    return result;
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

