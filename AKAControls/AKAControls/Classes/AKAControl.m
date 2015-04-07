//
//  AKAControl.m
//  AKAControls
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl_Internal.h"
#import "AKAControl_Protected.h" // To make appledoc find it
#import "AKACompositeControl.h"
#import "AKAViewBinding.h"

#import "AKAControlsErrors_Internal.h"

#import <AKACommons/AKALog.h>
#import <AKACommons/NSObject+AKAConcurrencyTools.h>
#import <objc/runtime.h>

@interface AKAControl() {
    AKAProperty* _dataContextProperty;
    AKAProperty* _modelValueProperty;
    AKAViewBinding* _viewBinding;
}

@property(nonatomic)NSMutableDictionary* themeNameByType;
@property(nonatomic)id synchronizedViewValue;

@end

@implementation AKAControl

@synthesize owner = _owner;
@synthesize isActive = _isActive;

#pragma mark - Initialization

+ (instancetype)controlWithDataContext:(id)dataContext
{
    NSParameterAssert(dataContext != nil);

    return [[self alloc] initWithDataContext:dataContext keyPath:nil];
}

+ (instancetype)controlWithDataContext:(id)dataContext keyPath:(NSString *)keyPath
{
    NSParameterAssert(dataContext != nil);
    NSParameterAssert(keyPath.length > 0);

    return [[self alloc] initWithDataContext:dataContext keyPath:keyPath];
}

+ (instancetype)controlWithOwner:(AKACompositeControl *)owner
{
    NSParameterAssert(owner != nil);

    return [[self alloc] initWithOwner:owner keyPath:nil];
}

+ (instancetype)controlWithOwner:(AKACompositeControl *)owner keyPath:(NSString *)keyPath
{
    NSParameterAssert(owner != nil);
    NSParameterAssert(keyPath.length > 0);

    return [[self alloc] initWithOwner:owner keyPath:keyPath];
}

- (instancetype)initWithDataContext:(id)dataContext
                            keyPath:(NSString*)keyPath
{
    self = [self init];
    if (self)
    {
        self.dataContextProperty =
            [AKAProperty propertyOfWeakKeyValueTarget:dataContext
                                              keyPath:nil
                                       changeObserver:nil];
        self.modelValueProperty =
            [self.dataContextProperty propertyAtKeyPath:keyPath
                                     withChangeObserver:^(id oldValue, id newValue)
             {
                 [self modelValueDidChangeFrom:oldValue
                                            to:newValue];
             }];
    }
    return self;
}

- (instancetype)initWithOwner:(AKACompositeControl *)owner
                      keyPath:(NSString *)keyPath
{
    self = [self init];
    if (self)
    {
        [self setOwner:owner];
        // Data context inherited from owner
        self.modelValueProperty =
            [self.dataContextProperty propertyAtKeyPath:keyPath
                                        withChangeObserver:^(id oldValue, id newValue)
             {
                 [self modelValueDidChangeFrom:oldValue
                                            to:newValue];
             }];
    }
    return self;
}

#pragma mark - Control Hierarchy

- (void)setOwner:(AKACompositeControl *)owner
{
    AKACompositeControl* currentOwner = _owner;
    if (currentOwner != owner)
    {
        if (currentOwner != nil)
        {
            [AKAControlsErrors invalidAttemptToSetOwnerOfControl:self
                                                        ownedBy:currentOwner
                                                     toNewOwner:owner];
        }
        _owner = owner;
    }
}

#pragma mark - Binding

- (AKAViewBinding *)viewBinding
{
    return _viewBinding;
}

- (void)setViewBinding:(AKAViewBinding *)viewBinding
{
    if (viewBinding != _viewBinding)
    {
        if (_viewBinding != nil && viewBinding != nil)
        {
            // TODO: error handling
        }
        else
        {
            _viewBinding = viewBinding;
            if (viewBinding != nil)
            {
                NSString* converterKeyPath = viewBinding.configuration.converterKeyPath;
                if (converterKeyPath.length > 0)
                {
                    _converterProperty = [self.dataContextProperty propertyAtKeyPath:converterKeyPath
                                                                      withChangeObserver:nil];
                }
                NSString* validatorKeyPath = viewBinding.configuration.validatorKeyPath;
                if (validatorKeyPath.length > 0)
                {
                    _validatorProperty = [self.dataContextProperty propertyAtKeyPath:validatorKeyPath
                                                                      withChangeObserver:nil];
                }
            }
        }

    }
}

#pragma mark - Value Access

- (UIView *)view
{
    return self.viewBinding.view;
}

- (AKAProperty*)viewValueProperty
{
    return self.viewBinding.viewValueProperty;
}

- (id)viewValue
{
    return self.viewValueProperty.value;
}

- (void)setViewValue:(id)viewValue
{
    self.viewValueProperty.value = viewValue;
}

- (AKAProperty *)dataContextProperty
{
    return _dataContextProperty != nil ? _dataContextProperty : self.owner.dataContextProperty;
}

- (void)setDataContextProperty:(AKAProperty *)dataContextProperty
{
    _dataContextProperty = dataContextProperty;
}

- (AKAProperty *)modelValueProperty
{
    return _modelValueProperty;
}

- (void)setModelValueProperty:(AKAProperty *)modelValueProperty
{
    _modelValueProperty = modelValueProperty;
}

- (id)modelValue
{
    return self.modelValueProperty.value;
}

- (void)setModelValue:(id)modelValue
{
    self.modelValueProperty.value = modelValue;
}

- (AKAProperty*)dataContextPropertyAtKeyPath:(NSString*)keyPath
                          withChangeObserver:(void(^)(id oldValue, id newValue))changeObserver
{
    // TODO: create a data context property
    if (self.owner)
    {
        // data context is the owners model value
        return [self.owner.modelValueProperty propertyAtKeyPath:keyPath
                                             withChangeObserver:changeObserver];
    }
    else
    {
        // without owner, data context is the controls model value
        return [self.modelValueProperty propertyAtKeyPath:keyPath
                                       withChangeObserver:changeObserver];
    }
}

- (id<AKAControlValidatorProtocol>)validator
{
    return self.validatorProperty.value;
}

#pragma mark - Change Tracking

#pragma mark Handling Changes

- (void)viewValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    if (self.synchronizedViewValue == nil)
    {
        self.synchronizedViewValue = oldValue;
    }
    [self updateModelValueForViewValueChangeTo:newValue];
}

- (void)modelValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    (void)oldValue; // not used.

    // Model changes can occur in any thread. Since such changes will most likely
    // result in UI updates, we have to make sure that updates are performed in
    // the main thread.
    __weak typeof(self)weakSelf = self;
    [self aka_performBlockInMainThreadOrQueue:^{
        [weakSelf updateViewValueForModelValueChangeTo:newValue];
    }];
}

- (BOOL)validateModelValue:(inout id*)valueStorage error:(out NSError *__autoreleasing *)error
{
    NSParameterAssert(valueStorage != nil);

    BOOL result = YES;
    id validatedValue = *valueStorage;

    id<AKAControlValidatorProtocol> validator = self.validator;
    if (validator != nil)
    {
        result = [validator validateModelValue:validatedValue error:error];
    }

    // Perform additional validation provided by KVC after custom validation,
    // assuming that custom validation will provide better error messages.
    if (result)
    {
        result = [self.modelValueProperty validateValue:&validatedValue error:error];
        if (validatedValue != *valueStorage)
        {
            AKALogWarn(@"Model value KVC validation replaced model value %@ with %@, this indicates potentially invalid model data",
                       *valueStorage, validatedValue);
            *valueStorage = validatedValue;
        }
    }

    return result;
}

- (void)updateViewValueForModelValueChangeTo:(id)newValue
{
    NSError* error;
    if (![self updateViewValueForModelValueChangeTo:newValue
                                 validateModelValue:YES
                                              error:&error])
    {
        // TODO: error handling
    }
}

- (BOOL)updateViewValueForModelValueChangeTo:(id)newValue
                          validateModelValue:(BOOL)validateModelValue
                                       error:(NSError*__autoreleasing*)error
{
    BOOL result = YES;

    id validatedValue = newValue;
    if (validateModelValue)
    {
        result = [self validateModelValue:&validatedValue error:error];
    }

    if (result)
    {
        id viewValue = validatedValue;
        id<AKAControlConverterProtocol> converter = self.converter;
        if (converter != nil)
        {
            result = [converter convertModelValue:validatedValue toViewValue:&viewValue error:error];
        }
        if (result)
        {
            self.synchronizedViewValue = viewValue;
            self.viewValue = viewValue;
        }
    }

    // Invalid model values should either be handled somehow or displayed as good as possible

    return result;
}

- (void)updateModelValueForViewValueChangeTo:(id)newValue
{
    NSError* error = nil;
    if (![self updateModelValueForViewValueChangeTo:newValue error:&error])
    {
        // TODO: error handling
    }
}

- (BOOL)updateModelValueForViewValueChangeTo:(id)newValue error:(NSError*__autoreleasing*)error
{
    BOOL result = YES;

    id modelValue = newValue;
    id<AKAControlConverterProtocol> converter = self.converter;
    if (converter != nil)
    {
        result = [converter convertViewValue:newValue toModelValue:&modelValue error:error];
    }

    if (result)
    {
        result = [self validateModelValue:&modelValue error:error];
        if (result)
        {
            // change of model value will have updated view value when returning from assignment
            // that's why synchronizedViewValue has to be reset before.
            self.synchronizedViewValue = nil;
            self.modelValue = modelValue;
        }
    }

    return result;
}

#pragma mark Controlling Observation

- (void)startObservingChanges
{
    [self startObservingModelValueChanges];
    [self startObservingViewValueChanges];
}

- (void)stopObservingChanges
{
    [self stopObservingModelValueChanges];
    [self stopObservingViewValueChanges];
}

- (BOOL)isObservingViewValueChanges
{
    return self.viewValueProperty.isObservingChanges;
}

- (BOOL)startObservingViewValueChanges
{
    return [self.viewValueProperty startObservingChanges];
}

- (BOOL)stopObservingViewValueChanges
{
    return [self.viewValueProperty stopObservingChanges];
}

- (BOOL)isObservingModelValueChanges
{
    return self.modelValueProperty.isObservingChanges;
}

- (BOOL)startObservingModelValueChanges
{
    BOOL result = self.modelValueProperty.isObservingChanges;
    if (!result)
    {
        // We don't get prior change events, so here is where we set the initial view value.
        [self updateViewValueForModelValueChangeTo:self.modelValueProperty.value];
        result = [self.modelValueProperty startObservingChanges];
    }
    return result;
}

- (BOOL)stopObservingModelValueChanges
{
    return [self.modelValueProperty stopObservingChanges];
}

#pragma mark - Activation

- (void)setIsActive:(BOOL)isActive
{
    // TODO: error handling
    _isActive = isActive;
}

- (BOOL)canActivate
{
    return self.viewBinding.supportsActivation;
}

- (BOOL)shouldActivate
{
    BOOL result = self.canActivate;
    if (result && [self.delegate respondsToSelector:@selector(shouldControlActivate:)])
    {
        result = [self.delegate shouldControlActivate:self];
    }
    if (result && self.owner)
    {
        result = [self.owner shouldControlActivate:self];
    }
    return result;
}

- (BOOL)activate
{
    BOOL result = self.canActivate;
    if (result)
    {
        result = [self.viewBinding activate];
    }
    return result;
}

- (void)willActivate
{
    if ([self.delegate respondsToSelector:@selector(controlWillActivate:)])
    {
        [self.delegate controlWillActivate:self];
    }
    [self.owner controlWillActivate:self];
}

- (void)didActivate
{
    [self setIsActive:YES];
    [self.owner controlDidActivate:self];
    if ([self.delegate respondsToSelector:@selector(controlDidActivate:)])
    {
        [self.delegate controlDidActivate:self];
    }
}

- (BOOL)shouldDeactivate
{
    BOOL result = YES;
    if (result && [self.delegate respondsToSelector:@selector(shouldControlDeactivate:)])
    {
        result = [self.delegate shouldControlDeactivate:self];
    }
    if (result && self.owner)
    {
        result = [self.owner shouldControlDeactivate:self];
    }
    return result;
}

- (BOOL)deactivate
{
    BOOL result = self.canActivate;
    if (result)
    {
        result = [self.viewBinding deactivate];
    }
    return result;
}

- (void)willDeactivate
{
    if ([self.delegate respondsToSelector:@selector(controlWillDeactivate:)])
    {
        [self.delegate controlWillDeactivate:self];
    }
    [self.owner controlWillDeactivate:self];
}

- (void)didDeactivate
{
    [self setIsActive:NO];
    [self.owner controlDidDeactivate:self];
    if ([self.delegate respondsToSelector:@selector(controlDidDeactivate:)])
    {
        [self.delegate controlDidDeactivate:self];
    }
}

- (BOOL)shouldActivateNextControl
{
    return [self.owner shouldActivateNextControl];
}

- (BOOL)activateNextControl
{
    return [self.owner activateNextControl];
}

- (BOOL)shouldAutoActivate
{
    return [self.viewBinding shouldAutoActivate];
}

- (BOOL)participatesInKeyboardActivationSequence
{
    return [self.viewBinding participatesInKeyboardActivationSequence];
}

- (AKAControl*)nextControlInKeyboardActivationSequence
{
    return [self.owner nextControlInKeyboardActivationSequenceAfter:self];
}

- (void)setupKeyboardActivationSequenceWithPredecessor:(AKAControl*)previous
                                             successor:(AKAControl*)next
{
    [self.viewBinding setupKeyboardActivationSequenceWithPredecessor:previous.view
                                                           successor:next.view];
}

#pragma mark - View Binding Delegate

- (void)viewBinding:(AKAViewBinding *)viewBinding
               view:(UIView *)view
 valueDidChangeFrom:(id)oldValue
                 to:(id)newValue
{
    NSParameterAssert(view == self.view);
    NSParameterAssert(viewBinding == self.viewBinding);

    [self viewValueDidChangeFrom:oldValue to:newValue];
}

- (BOOL)viewBindingShouldActivate:(AKAViewBinding *)viewBinding
{
    NSParameterAssert(viewBinding == self.viewBinding);
    return [self shouldActivate];
}

- (void)viewBinding:(AKAViewBinding *)viewBinding viewWillActivate:(UIView *)view
{
    NSParameterAssert(viewBinding == self.viewBinding);
    [self willActivate];
}

- (void)viewBinding:(AKAViewBinding *)viewBinding viewDidActivate:(UIView *)view
{
    NSParameterAssert(viewBinding == self.viewBinding);
    [self didActivate];
}

- (BOOL)viewBindingShouldDeactivate:(AKAViewBinding *)viewBinding
{
    NSParameterAssert(viewBinding == self.viewBinding);
    return [self shouldDeactivate];
}

- (void)viewBinding:(AKAViewBinding *)viewBinding viewWillDeactivate:(UIView *)view
{
    NSParameterAssert(viewBinding == self.viewBinding);
    [self willDeactivate];
}

- (void)viewBinding:(AKAViewBinding *)viewBinding viewDidDeactivate:(UIView *)view
{
    NSParameterAssert(viewBinding == self.viewBinding);
    [self didDeactivate];
}

- (BOOL)viewBindingRequestsActivateNextInKeyboardActivationSequence:(AKAViewBinding *)viewBinding
{
    BOOL result = NO;
    AKAControl* next = [self nextControlInKeyboardActivationSequence];
    if ([next shouldActivate])
    {
        [next activate];
    }
    return result;
}

#pragma mark - Theme Selection

- (AKAProperty*)themeNamePropertyForView:(UIView*)view
                  changeObserver:(void(^)(id oldValue, id newValue))themeNameChanged
{
    AKAProperty* result = nil;
    NSString* themeName;
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
