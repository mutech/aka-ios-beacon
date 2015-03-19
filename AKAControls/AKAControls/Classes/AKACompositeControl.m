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

#import "AKAControlsErrors.h"

#import "UIView+AKAHierarchyVisitor.h"

@interface AKACompositeControl()

@property(nonatomic, strong) NSMutableArray* controlsStorage;
@property(nonatomic) NSUInteger activeControlIndex;

@end

@implementation AKACompositeControl

@synthesize activeControl = _activeControl;

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

#pragma mark - Member Controls

#pragma mark Access to Member Controls

- (NSArray*)controls
{
    return [NSArray arrayWithArray:self.controlsStorage];
}

- (NSUInteger)indexOfControl:(AKAControl*)control
{
    return [self.controlsStorage indexOfObjectIdenticalTo:control];
}

- (void)enumerateControlsUsingBlock:(void(^)(AKAControl* control, NSUInteger index, BOOL* stop))block
{
    [self enumerateControlsUsingBlock:block startIndex:0 continueInOwner:NO];
}

- (void)enumerateControlsUsingBlock:(void(^)(AKAControl* control, NSUInteger index, BOOL* stop))block
                         startIndex:(NSUInteger)startIndex
                    continueInOwner:(BOOL)continueInOwner
{
    __block BOOL localStop = NO;
    if (startIndex < self.controlsStorage.count)
    {
        NSRange range = NSMakeRange(startIndex, self.controlsStorage.count - startIndex);
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        NSEnumerationOptions options = 0;
        [self.controlsStorage enumerateObjectsAtIndexes:indexSet
                                                options:options
                                             usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                 block(obj, idx, &localStop);
                                                 *stop = localStop;
                                             }];
    }
    if (!localStop && continueInOwner && self.owner)
    {
        NSUInteger index = [self.owner indexOfControl:self];
        [self.owner enumerateControlsUsingBlock:block startIndex:index+1 continueInOwner:continueInOwner];
    }
}

- (void)enumerateLeafControlsUsingBlock:(void(^)(AKAControl* control, AKACompositeControl* owner, NSUInteger index, BOOL* stop))block
{
    [self enumerateLeafControlsUsingBlock:block startIndex:0 continueInOwner:NO];
}

- (void)enumerateLeafControlsUsingBlock:(void(^)(AKAControl* control, AKACompositeControl* owner, NSUInteger index, BOOL* stop))block
                             startIndex:(NSUInteger)startIndex
                        continueInOwner:(BOOL)continueInOwner
{
    [self enumerateControlsUsingBlock:^(AKAControl* control, NSUInteger idx, BOOL *stop) {
        if ([control isKindOfClass:[AKACompositeControl class]])
        {
            AKACompositeControl* composite = (AKACompositeControl*)control;
            [composite enumerateLeafControlsUsingBlock:block
                                            startIndex:0
                                       continueInOwner:NO]; // NO: this instance handles siblings
        }
        else
        {
            block(control, self, idx, stop);
        }
    }
                                          startIndex:startIndex
                                     continueInOwner:continueInOwner];
}

- (void)enumerateKeyboardActivationSequenceUsingBlock:(void(^)(AKAControl* control, AKACompositeControl* owner, NSUInteger index, BOOL* stop))block
{
    [self enumerateKeyboardActivationSequenceUsingBlock:block startIndex:0 continueInOwner:NO];
}

- (void)enumerateKeyboardActivationSequenceUsingBlock:(void(^)(AKAControl* control, AKACompositeControl* owner, NSUInteger index, BOOL* stop))block
                                           startIndex:(NSUInteger)startIndex
                                      continueInOwner:(BOOL)continueInOwner
{
    [self enumerateLeafControlsUsingBlock:^(AKAControl *control, AKACompositeControl *owner, NSUInteger index, BOOL *stop) {
            if ([control participatesInKeyboardActivationSequence])
            {
                block(control, owner, index, stop);
            }
        }
                               startIndex:startIndex
                          continueInOwner:continueInOwner];
}

#pragma mark Adding and Removing Member Controls

- (NSUInteger)addControlsForControlViewsInViewHierarchy:(UIView*)rootView
{
    return [self insertControlsForControlViewsInViewHierarchy:rootView atIndex:self.controlsStorage.count];
}

- (NSUInteger)insertControlsForControlViewsInViewHierarchy:(UIView*)rootView
                                                   atIndex:(NSUInteger)index
{
    NSUInteger __block count = 0;
    [rootView aka_enumerateSubviewsUsingBlock:^(UIView *view, BOOL *stop, BOOL *doNotDescend) {
        (void)stop; // not used
        if ([view conformsToProtocol:@protocol(AKAControlViewProtocol)])
        {
            UIView<AKAControlViewProtocol>* controlView = (id)view;
            UIView<AKAControlViewBindingConfigurationProtocol>* configuration = controlView;
            Class bindingType = controlView.preferredBindingType;

            AKAControlViewBinding* binding =
            [AKAControlViewBinding bindingOfType:bindingType
                               withConfiguration:configuration
                                            view:view
                                    controlOwner:self];
            AKAControl* control = binding.control;
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

#pragma mark Delegat'ish Methods for Notifications and Customization

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

#pragma mark - Activation

- (void)setActiveControl:(AKAControl *)activeControl
{
    AKAControl* oldActive = self.activeControl;
    if (activeControl == nil)
    {
        _activeControl = nil;
        _activeControlIndex = NSNotFound;
    }
    else
    {
        NSUInteger index = [self.controlsStorage indexOfObjectIdenticalTo:activeControl];
        if (index == NSNotFound)
        {
            [AKAControlsErrors invalidAttemptToActivateNonMemberControl:activeControl
                                                             inComposite:self];
        }
        if (activeControl != nil && oldActive != nil)
        {
            [AKAControlsErrors invalidAttemptToActivate:activeControl
                                            inComposite:self
                        whileAnotherMemberIsStillActive:oldActive
                                               recovery:^BOOL
            {
                [self setActiveControl:nil];
                return YES;
            }];

        }
        [self controlDidActivate:oldActive];
        _activeControl = activeControl;
        _activeControlIndex = index;
    }
}

#pragma mark Keyboard Activation Sequence

- (BOOL)participatesInKeyboardActivationSequence
{
    BOOL __block result = NO;
    [self enumerateControlsUsingBlock:^(AKAControl *control, NSUInteger index, BOOL *stop) {
        result |= control.participatesInKeyboardActivationSequence;
        *stop = result;
    }];
    return result;
}

- (AKAControl*)nextControlInKeyboardActivationSequenceAfter:(AKAControl*)control
{
    __block AKAControl* result = nil;
    NSUInteger index = [self indexOfControl:control];
    [self enumerateKeyboardActivationSequenceUsingBlock:^(AKAControl *control, AKACompositeControl *owner, NSUInteger index, BOOL *stop)
    {
        result = control;
        *stop = YES;
    }
                                             startIndex:index+1
                                        continueInOwner:YES];
    return result;
}

- (void)setupKeyboardActivationSequence
{
    __block AKAControl* previous = nil;
    __block AKAControl* current = nil;
    __block AKAControl* next = nil;
    [self enumerateKeyboardActivationSequenceUsingBlock:^(AKAControl *control, AKACompositeControl *owner, NSUInteger index, BOOL *stop) {
        previous = current;
        current = next;
        next = control;
        if (current != nil)
        {
            [current setupKeyboardActivationSequenceWithPredecessor:(AKAControl*)previous
                                                          successor:(AKAControl*)next];
        }
    }];
    if (next != nil)
    {
        [next setupKeyboardActivationSequenceWithPredecessor:(AKAControl*)current
                                                      successor:(AKAControl*)nil];
    }
}

#pragma mark Member Activation

- (BOOL)shouldControlActivate:(AKAControl*)memberControl
{
    BOOL result = memberControl != self.activeControl;

    // Let this instances delegate decide first
    id<AKAControlDelegate> delegate = self.delegate;
    if (result && [delegate respondsToSelector:@selector(shouldControlActivate:)])
    {
        result = [delegate shouldControlActivate:memberControl];
    }

    AKACompositeControl* owner = self.owner;
    if (result && owner)
    {
        // Ascend the control tree to ensure all delegates
        // have been consulted first.
        result = [owner shouldControlActivate:memberControl];

        if (result && !self.isActive && owner.isActive && owner.activeControl != nil)
        {
            // The owner is the junction point between the current
            // and future active control path and it is responsible to
            // check if a currently active control and its transitive
            // owners should be deactivated.
            result = [self shouldDeactivateActiveSubtree];
        }
    }

    return result;
}

- (void)controlDidActivate:(AKAControl*)memberControl
{
    if (memberControl.owner == self)
    {
        // Deactivate formerly active composite controls which
        // will no longer be part of the active control path:
        AKACompositeControl* activeControlPathJunction = [self activeControlPathJunction];
        if (activeControlPathJunction != nil)
        {
            [activeControlPathJunction activeSubtreeDidDeactivate];
        }

        [self setActiveControl:memberControl];
        if (!self.isActive)
        {
            [self didActivate];
        }
    }

    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controlDidActivate:)])
    {
        [delegate controlDidActivate:memberControl];
    }
    [self.owner controlDidActivate:memberControl];
}

- (BOOL)shouldControlDeactivate:(AKAControl*)memberControl
{
    BOOL result = memberControl.isActive;

    // Let this instances delegate decide first
    id<AKAControlDelegate> delegate = self.delegate;
    if (result && [delegate respondsToSelector:@selector(shouldControlDeactivate:)])
    {
        result = [delegate shouldControlDeactivate:memberControl];
    }

    AKACompositeControl* owner = self.owner;
    if (result && owner)
    {
        result = [owner shouldControlDeactivate:memberControl];
    }

    return result;
}

- (void)controlDidDeactivate:(AKAControl*)memberControl
{
    if (memberControl.owner == self)
    {
        [self setActiveControl:nil];
    }
    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controlDidDeactivate:)])
    {
        [delegate controlDidDeactivate:memberControl];
    }
    [self.owner controlDidDeactivate:memberControl];
}

#pragma mark - Implementation

- (BOOL)shouldDeactivateActiveSubtree
{
    // TODO: implement
    return YES;
}

- (void)activeSubtreeDidDeactivate
{
    // Composite controls are activated when one of their members become
    // active. They are not immediately deactivated when the member
    // deactivates but will be deactivated here whenever a control
    // which is not part of the currently active control path is
    // activated.
    AKAControl* active = self.activeControl;
    if (active != nil)
    {
        if ([active isKindOfClass:[AKACompositeControl class]])
        {
            AKACompositeControl* composite = (AKACompositeControl*)active;
            [composite activeSubtreeDidDeactivate];
            [composite didDeactivate];
        }
        else
        {
            NSAssert(NO, @"%@ received subtree deactivation notification while non-composite control %@ was marked active. It should have detected its deactivation before!", self, active);
            [active didDeactivate];
        }
    }
}

- (AKACompositeControl*)activeControlPathJunction
{
    AKACompositeControl* result = self;
    if (!self.isActive)
    {
        result = [self.owner activeControlPathJunction];
    }
    return result;
}

- (AKAControl*)activeMemberLeafControl
{
    AKAControl* result = nil;
    if (self.isActive)
    {
        result = self.activeControl;
        if ([result isKindOfClass:[AKACompositeControl class]])
        {
            AKACompositeControl* control = (AKACompositeControl*)result;
            if (control.activeControl)
            {
                result = [control activeMemberLeafControl];
            }
        }
    }
    return result;
}

- (AKAControl*)activeLeafControl
{
    AKAControl* result = nil;
    if (self.isActive)
    {
        result = [self activeMemberLeafControl];
        if (result == nil)
        {
            result = self;
        }
    }
    else
    {
        result = [self.owner activeLeafControl];
    }
    return result;
}

- (AKAControl*)directMemberControl:(AKAControl*)control
{
    AKAControl* result = nil;

    if (control != nil && control != self)
    {
        if (control.owner == self)
        {
            result = control;
        }
        else
        {
            result = [self directMemberControl:control.owner];
        }
    }
    return result;
}

@end
