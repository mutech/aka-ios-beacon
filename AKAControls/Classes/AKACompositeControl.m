//
//  AKACompositeControl.m
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

#import "AKACompositeControl.h"
#import "AKAControl_Internal.h"
#import "AKAControlViewProtocol.h"

#import "UIView+AKAHierarchyVisitor.h"

@interface AKACompositeControl()

@property(nonatomic, strong) NSMutableArray* controlsStorage;

@end

@implementation AKACompositeControl

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.controlsStorage = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark Member Controls

- (NSArray*)controls
{
    return [NSArray arrayWithArray:self.controlsStorage];
}

#pragma mark Control Membership

- (NSUInteger)addControlsForControlViewsInViewHierarchy:(UIView*)rootView
{
    return [self insertControlsForControlViewsInViewHierarchy:rootView atIndex:self.controlsStorage.count];
}

- (NSUInteger)insertControlsForControlViewsInViewHierarchy:(UIView*)rootView
                                                   atIndex:(NSUInteger)index
{
    NSUInteger __block count = 0;
    [rootView enumerateSubviewsUsingBlock:^(UIView *view, BOOL *stop, BOOL *doNotDescend) {
        (void)stop; // not used
        if ([view conformsToProtocol:@protocol(AKAControlViewProtocol)])
        {
            UIView<AKAControlViewProtocol>* controlView = (id)view;
            AKAControl* control = [controlView createControlWithOwner:self];
            if ([self insertControl:control atIndex:index + count])
            {
                ++count;
                *doNotDescend = YES;
            }
        }
    }];
    return count;
}

- (BOOL)addControl:(AKAControl*)control
{
    return [self insertControl:control atIndex:self.controlsStorage.count];
}

- (BOOL)insertControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    BOOL result = [self shouldAddControl:control atIndex:index];
    if (result)
    {
        [self willAddControl:control atIndex:index];
        [self.controlsStorage insertObject:control atIndex:index];
        [self didAddControl:control atIndex:index];
    }
    return result;
}

- (BOOL)removeControl:(AKAControl*)control
{
    NSUInteger index = [self.controlsStorage indexOfObjectIdenticalTo:control];
    return [self removeControl:control atIndex:index];
}

- (BOOL)removeControlAtIndex:(NSUInteger)index
{
    BOOL result = index <= self.controlsStorage.count;
    if (result)
    {
        AKAControl* control = [self.controlsStorage objectAtIndex:index];
        result = [self removeControl:control atIndex:index];
    }
    return result;
}

- (BOOL)removeControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    BOOL result = [self shouldRemoveControl:control atIndex:index];
    if (result)
    {
        [self willRemoveControl:control atIndex:index];
        [self.controlsStorage removeObjectAtIndex:index];
        [self didRemoveControl:control atIndex:index];
    }
    return result;
}

- (BOOL)shouldAddControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    AKACompositeControl* owner = control.owner;
    return (index <= self.controlsStorage.count &&
            (owner == nil || owner == self) &&
            ![self.controlsStorage containsObject:control]);
}

- (void)willAddControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    (void)index; // not used

    // If by some ugly means the control changed ownership after we
    // tested it in shouldAddControl, this should throw an exception:
    [control setOwner:self];
}

- (void)didAddControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    (void)control; // not used
    (void)index; // not used
}

- (BOOL)shouldRemoveControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    return (index <= self.controlsStorage.count &&
            control.owner == self &&
            control == [self.controlsStorage objectAtIndex:index]);
}

- (void)willRemoveControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    (void)control; // not used
    (void)index; // not used
}

- (void)didRemoveControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    (void)index; // not used

    [control setOwner:nil];
}

#pragma mark - Change Tracking

#pragma mark Controlling Observation

- (BOOL)isObservingViewValueChanges
{
    // return YES if any control is observing
    BOOL result = NO;

    result |= [super isObservingViewValueChanges];
    for (AKAControl* control in self.controlsStorage)
    {
        result |= control.isObservingViewValueChanges;
        if (result)
        {
            break;
        }
    }

    return result;
}

- (BOOL)startObservingViewValueChanges
{
    // return YES if any control started, start self then members
    BOOL result = NO;

    result |= [super startObservingViewValueChanges];
    for (AKAControl* control in self.controlsStorage)
    {
        result |= [control startObservingViewValueChanges];
    }

    return result;
}

- (BOOL)stopObservingViewValueChanges
{
    // return YES if all controls stopped, stop members then self
    BOOL result = YES;

    for (AKAControl* control in self.controlsStorage)
    {
        result &= [control stopObservingViewValueChanges];
    }
    result &= [super stopObservingViewValueChanges];

    return result;
}

- (BOOL)isObservingModelValueChanges
{
    // return YES if any control is observing
    BOOL result = NO;

    result |= [super isObservingModelValueChanges];
    for (AKAControl* control in self.controlsStorage)
    {
        result |= control.isObservingModelValueChanges;
        if (result)
        {
            break;
        }
    }
    return result;
}

- (BOOL)startObservingModelValueChanges
{
    // return YES if any control started, start self then members
    BOOL result = NO;

    result |= [super startObservingModelValueChanges];
    for (AKAControl* control in self.controlsStorage)
    {
        result |= [control startObservingModelValueChanges];
    }

    return result;
}

- (BOOL)stopObservingModelValueChanges
{
    // return YES if all controls stopped, stop members then self
    BOOL result = YES;

    for (AKAControl* control in self.controlsStorage)
    {
        result &= [control stopObservingModelValueChanges];
    }
    result &= [super stopObservingModelValueChanges];

    return result;
}

@end
