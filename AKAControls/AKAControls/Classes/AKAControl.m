//
//  AKAControl.m
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKAControl_Internal.h"
#import "AKACompositeControl.h"

#import "AKAControlsErrors.h"

@interface AKAControl() {
    AKAProperty* _modelValueProperty;
}
@end

@implementation AKAControl

@synthesize owner = _owner;
@synthesize isActive = _isActive;

#pragma mark - Initialization

+ (instancetype)controlWithDataContext:(id)dataContext keyPath:(NSString *)keyPath
{
    return [[self alloc] initWithDataContext:dataContext keyPath:keyPath];
}

+ (instancetype)controlWithOwner:(AKACompositeControl *)owner keyPath:(NSString *)keyPath
{
    return [[self alloc] initWithOwner:owner keyPath:keyPath];
}

- (instancetype)initWithDataContext:(id)dataContext keyPath:(NSString*)keyPath
{
    self = [self init];
    if (self)
    {
        self.modelValueProperty =
            [AKAProperty propertyOfKeyValueTarget:dataContext
                                          keyPath:keyPath
                                   changeObserver:^(id oldValue, id newValue) {
                                       [self modelValueDidChangeFrom:oldValue
                                                                  to:newValue];
                                   }];
    }
    return self;
}

- (instancetype)initWithOwner:(AKACompositeControl *)owner keyPath:(NSString *)keyPath
{
    self = [self init];
    if (self)
    {
        self.modelValueProperty =
            [owner.modelValueProperty propertyAtKeyPath:keyPath
                                     withChangeObserver:^(id oldValue, id newValue) {
                                         [self modelValueDidChangeFrom:oldValue
                                                                    to:newValue];
                                     }];
        [self setOwner:owner];
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
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                          reason:[NSString stringWithFormat:@"Invalid attempt to set owner of control %@ to %@: control already owned by %@", self, owner, currentOwner] userInfo:nil];
        }
        _owner = owner;
    }
}

#pragma mark - Value Access

- (AKAProperty*)viewValueProperty
{
    return self.viewBinding.viewValueProperty;
}

- (id)viewValue
{
    return self.viewBinding.viewValueProperty.value;
}

- (void)setViewValue:(id)viewValue
{
    self.viewBinding.viewValueProperty.value = viewValue;
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

#pragma mark - Change Tracking

#pragma mark Handling Changes

- (void)viewValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    (void)oldValue; // not used.
    [self updateModelValueForViewValueChangeTo:newValue];
}

- (void)modelValueDidChangeFrom:(id)oldValue to:(id)newValue
{
    (void)oldValue; // not used.
    if ([NSThread isMainThread])
    {
        [self updateViewValueForModelValueChangeTo:newValue];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateViewValueForModelValueChangeTo:newValue];
        });
    }
}

- (void)updateViewValueForModelValueChangeTo:(id)newValue
{
    // TODO: conversion, error handling
    self.viewValue = newValue;
}

- (void)updateModelValueForViewValueChangeTo:(id)newValue
{
    // TODO: conversion, validation, error handling
    self.modelValue = newValue;
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
    return self.viewBinding.controlViewCanActivate;
}

- (BOOL)shouldActivate
{
    BOOL result = self.canActivate;
    if (result && self.owner)
    {
        result = [self.owner shouldControlActivate:self];
    }
    return result;
}

- (BOOL)activate
{
    return [self.viewBinding activateControlView];
}

- (void)didActivate
{
    [self setIsActive:YES];
    [self.owner controlDidActivate:self];
}

- (BOOL)shouldDeactivate
{
    BOOL result = YES;
    if (result && self.owner)
    {
        result = [self.owner shouldControlDeactivate:self];
    }
    return YES;
}

- (BOOL)deactivate
{
    return [self.viewBinding deactivateControlView];
}

- (void)didDeactivate
{
    [self setIsActive:NO];
    [self.owner controlDidDeactivate:self];
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
    [self.viewBinding setupKeyboardActivationSequenceWithPredecessor:previous
                                                           successor:next];
}

@end
