//
//  AKACompositeControl.m
//  AKACommons
//
//  Created by Michael Utech on 12.03.15.
//  Copyright (c) 2015 AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAConcurrencyTools;

#import "AKACompositeControl.h"
#import "AKATableViewCellCompositeControl.h"
#import "AKAControl_Internal.h"
#import "AKAControlViewProtocol.h"
#import "AKAControlsErrors_Internal.h"

// next gen binding
#import "AKABindingProvider.h"
@import AKACommons.NSObject_AKAAssociatedValues; // TODO: remove when viewBindings property is implemented
@import AKACommons.UIView_AKAHierarchyVisitor;

@interface AKACompositeControl() <AKABindingDelegate, AKABindingContextProtocol>

@property(nonatomic, strong) NSMutableArray<AKAControl*>* controlsStorage;
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

#pragma mark - Binding Context Protocol

- (opt_AKAProperty)dataContextPropertyForKeyPath:(opt_NSString)keyPath withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange
{
    return [self.dataContextProperty propertyAtKeyPath:keyPath
                                    withChangeObserver:valueDidChange];
}

- (opt_id)dataContextValueForKeyPath:(req_NSString)keyPath
{
    return [self.dataContextProperty targetValueForKeyPath:keyPath];
}

- (opt_AKAProperty)rootDataContextPropertyForKeyPath:(opt_NSString)keyPath withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange
{
    return [[self rootControl] dataContextPropertyForKeyPath:keyPath withChangeObserver:valueDidChange];
}

- (opt_id)rootDataContextValueForKeyPath:(req_NSString)keyPath
{
    return [self rootDataContextPropertyForKeyPath:keyPath withChangeObserver:nil].value;
}

- (opt_AKAProperty)controlPropertyForKeyPath:(req_NSString)keyPath withChangeObserver:(opt_AKAPropertyChangeObserver)valueDidChange
{
    return [AKAProperty propertyOfWeakKeyValueTarget:self keyPath:keyPath changeObserver:valueDidChange];
}

- (opt_id)controlValueForKeyPath:(req_NSString)keyPath
{
    return [self controlPropertyForKeyPath:keyPath withChangeObserver:nil].value;
}

- (AKACompositeControl*)rootControl
{
    AKACompositeControl* result;
    for (result = self; result.owner != nil; result = result.owner)
        ;
    return result;
}

#pragma mark - Binding Delegate

- (void)                                binding:(req_AKABinding)binding
         targetUpdateFailedToConvertSourceValue:(opt_id)sourceValue
                         toTargetValueWithError:(opt_NSError)error
{
    // TODO: implement
}

- (void)                                binding:(req_AKABinding)binding
        targetUpdateFailedToValidateTargetValue:(opt_id)targetValue
                       convertedFromSourceValue:(opt_id)sourceValue
                                      withError:(opt_NSError)error
{
    // TODO: implement
}

- (void)                                binding:(req_AKABinding)binding
         sourceUpdateFailedToConvertTargetValue:(opt_id)targetValue
                         toSourceValueWithError:(opt_NSError)error
{
    // TODO: implement
}

- (void)                                binding:(req_AKABinding)binding
        sourceUpdateFailedToValidateSourceValue:(opt_id)sourceValue
                       convertedFromTargetValue:(opt_id)targetValue
                                      withError:(opt_NSError)error
{
    // TODO: implement
}

#pragma mark Access to Member Controls

- (NSArray*)controls
{
    return [NSArray arrayWithArray:self.controlsStorage];
}

- (NSUInteger)countOfControls
{
    return self.controlsStorage.count;
}

- (id)objectInControlsAtIndex:(NSUInteger)index
{
    return [self.controlsStorage objectAtIndex:index];
}

- (NSUInteger)indexOfControl:(AKAControl*)control
{
    return [self.controlsStorage indexOfObjectIdenticalTo:control];
}

#pragma mark Adding and Removing Member Controls

- (AKAControl*)createControlForView:(UIView*)view
                  withConfiguration:(AKAObsoleteViewBindingConfiguration *)configuration
{
    Class controlType = configuration.preferredControlType;
    AKAControl* control = [[controlType alloc] initWithOwner:self
                                               configuration:configuration];

    Class bindingType = configuration.preferredBindingType;
    AKAObsoleteViewBinding * binding = [[bindingType alloc] initWithView:view
                                                  configuration:configuration
                                                       delegate:control];
    control.viewBinding = binding;

    if ([control isKindOfClass:[AKACompositeControl class]] && binding.view != nil)
    {
        AKACompositeControl* composite = (AKACompositeControl*)control;
        [composite autoAddControlsForBoundView];
    }

    return control;
}

- (NSUInteger)autoAddControlsForBoundView
{
    return [self addControlsForBoundView];
}

- (NSUInteger)addControlsForBoundView
{
    return [self addControlsForControlViewsInViewHierarchy:self.viewBinding.view];
}

- (BOOL)insertControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    NSParameterAssert(control != nil);
    NSParameterAssert(index <= self.controlsStorage.count);

    BOOL result = [self shouldAddControl:control atIndex:index];
    if (result)
    {
        [self willAddControl:control atIndex:index];
        [self.controlsStorage insertObject:control atIndex:index];
        [self didAddControl:control atIndex:index];
    }
    return result;
}

- (BOOL)removeControlAtIndex:(NSUInteger)index
{
    BOOL result = index <= self.controlsStorage.count;
    if (result)
    {
        AKAControl* control = [self.controlsStorage objectAtIndex:index];
        [control stopObservingChanges];
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

- (NSUInteger)removeAllControls
{
    NSUInteger result = 0;

    NSAssert(self.countOfControls <= NSIntegerMax, @"index overflow");
    for (NSInteger i=self.countOfControls - 1; i >= 0; --i)
    {
        if ([self removeControlAtIndex:(NSUInteger)i])
        {
            ++result;
        }
    }
    return result;
}

#pragma mark Delegat'ish Methods for Notifications and Customization

- (BOOL)  shouldControl:(AKACompositeControl *)compositeControl
             addControl:(AKAControl *)memberControl
                atIndex:(NSUInteger)index
{
    BOOL result = YES;

    if (result)
    {
        id<AKAControlMembershipDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(shouldControl:addControl:atIndex:)])
        {
            result = [delegate shouldControl:compositeControl addControl:memberControl atIndex:index];
        }
    }

    if (result)
    {
        AKACompositeControl* owner = self.owner;
        if (owner != nil)
        {
            result = [owner shouldControl:compositeControl addControl:memberControl atIndex:index];
        }
    }

    return result;
}

- (void)        control:(AKACompositeControl *)compositeControl
         willAddControl:(AKAControl *)memberControl
                atIndex:(NSUInteger)index
{
    id<AKAControlMembershipDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(control:willAddControl:atIndex:)])
    {
        [delegate control:self willAddControl:memberControl atIndex:index];
    }
    [self.owner control:self willAddControl:memberControl atIndex:index];
}

- (void)        control:(AKACompositeControl *)compositeControl
          didAddControl:(AKAControl *)memberControl
                atIndex:(NSUInteger)index
{
    id<AKAControlMembershipDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(control:didAddControl:atIndex:)])
    {
        [delegate control:self didAddControl:memberControl atIndex:index];
    }
    [self.owner control:self didAddControl:memberControl atIndex:index];
}

- (BOOL)  shouldControl:(AKACompositeControl *)compositeControl
          removeControl:(AKAControl *)memberControl
                atIndex:(NSUInteger)index
{
    BOOL result = YES;

    if (result)
    {
        id<AKAControlMembershipDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(shouldControl:removeControl:atIndex:)])
        {
            result = [delegate shouldControl:compositeControl removeControl:memberControl atIndex:index];
        }
    }

    if (result)
    {
        AKACompositeControl* owner = self.owner;
        if (owner != nil)
        {
            result = [owner shouldControl:compositeControl removeControl:memberControl atIndex:index];
        }
    }

    return result;
}

- (void)        control:(AKACompositeControl *)compositeControl
      willRemoveControl:(AKAControl *)memberControl
              fromIndex:(NSUInteger)index
{
    id<AKAControlMembershipDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(control:willRemoveControl:fromIndex:)])
    {
        [delegate control:self willRemoveControl:memberControl fromIndex:index];
    }
    [self.owner control:self willRemoveControl:memberControl fromIndex:index];
}

- (void)        control:(AKACompositeControl *)compositeControl
       didRemoveControl:(AKAControl *)memberControl
              fromIndex:(NSUInteger)index
{
    id<AKAControlMembershipDelegate> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(control:didRemoveControl:fromIndex:)])
    {
        [delegate control:self didRemoveControl:memberControl fromIndex:index];
    }
    [self.owner control:self didRemoveControl:memberControl fromIndex:index];
}

- (BOOL)shouldAddControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    AKACompositeControl* owner = control.owner;
    BOOL result = (index <= self.controlsStorage.count &&
                   (owner == nil || owner == self) &&
                   ![self.controlsStorage containsObject:control]);

    if (result)
    {
        result = [self shouldControl:self addControl:control atIndex:index];
    }

    return result;
}

- (void)willAddControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    [self control:self willAddControl:control atIndex:index];

    // If by some ugly means the control changed ownership after we
    // tested it in shouldAddControl, this should throw an exception:
    [control setOwner:self];
}

- (void)didAddControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    [self control:self didAddControl:control atIndex:index];
    if (self.isObservingChanges)
    {
        [control startObservingChanges];
    }
}

- (BOOL)shouldRemoveControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    BOOL result = (index <= self.controlsStorage.count &&
                   control.owner == self &&
                   control == [self.controlsStorage objectAtIndex:index]);

    if (result)
    {
        result = [self shouldControl:self removeControl:control atIndex:index];
    }

    return result;
}

- (void)willRemoveControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    [self control:self willRemoveControl:control fromIndex:index];
    [control stopObservingChanges];
}

- (void)didRemoveControl:(AKAControl*)control atIndex:(NSUInteger)index
{
    (void)index; // not used
    [control setOwner:nil];
    [self control:self didRemoveControl:control fromIndex:index];
}

#pragma mark - Change Tracking

#pragma mark Controlling Observation

- (void)startObservingChanges
{
    NSAssert([[NSThread currentThread] isMainThread], @"Observation started outside main thread");

    [self aka_performBlockInMainThreadOrQueue:^{
        if (!self.isObservingChanges)
        {
            [super startObservingChanges];
            for (AKAControl* control in self.controlsStorage)
            {
                [control startObservingChanges];
            }
        }
    } waitForCompletion:YES];
}

- (void)stopObservingChanges
{
    NSAssert([[NSThread currentThread] isMainThread], @"Observation stopped outside main thread");

    [self aka_performBlockInMainThreadOrQueue:^{
        // We are not checking if we are observing changes to make double sure to
        // not to leave observations behind which will end in a crash.
        //if (self.isObservingChanges)
        //{
        for (AKAControl* control in self.controlsStorage)
        {
            [control stopObservingChanges];
        }
        [super stopObservingChanges];
        //}
    } waitForCompletion:YES];
}

#pragma mark - Activation

- (BOOL)activate
{
    BOOL result = self.isActive;

    if (!result)
    {
        result = [super activate];
    }

    AKAControl* activeMemberLeafControl = [self activeMemberLeafControl];
    if (self.shouldAutoActivate && (activeMemberLeafControl == nil ||[activeMemberLeafControl isKindOfClass:[AKACompositeControl class]]))
    {
        __block AKAControl* autoActivatable;
        __block AKAControl* activatable;
        [self enumerateControlsUsingBlock:^(AKAControl *control, NSUInteger index, BOOL *stop) {
            (void)index; // not needed

            if ([control canActivate])
            {
                if (!activatable)
                {
                    activatable = control;
                }
                if ([control shouldAutoActivate])
                {
                    autoActivatable = control;
                }
                *stop = autoActivatable != nil;
            }
        }];
        if (autoActivatable)
        {
            result = [autoActivatable activate];
        }
        else if (activatable)
        {
            result = [activatable activate];
        }
    }
    return result;
}

- (BOOL)deactivate
{
    BOOL result = !self.isActive;
    if (!result)
    {
        if (self.activeControl)
        {
            result = [self.activeControl deactivate];
        }
        if (!result)
        {
            // Do not deactivate if active member failed to deactivate
            result = [super deactivate];
        }
    }
    return result;
}

/**
 * Determines whether this control can be activated. This is true if either the associated
 * view binding indicates that the bound view supports activation or if any of the member
 * controls can activate.
 *
 * @return YES if the composite control directly or any of its members can be activated.
 */
- (BOOL)canActivate
{
    __block BOOL result = [super canActivate];
    if (!result)
    {
        [self enumerateControlsUsingBlock:^(AKAControl *control, NSUInteger index, BOOL *stop) {
            result = *stop = control.canActivate;
        }];
    }
    return result;
}

/**
 * Determines whether this control should be activated automatically. This is true if either the
 * associated view binding indicates that the bound view or any of the member controls should
 * be automatically activated.
 *
 * @return YES if the composite control directly or any of its members should be activated automatically.
 */
- (BOOL)shouldAutoActivate
{
    __block BOOL result = [super shouldAutoActivate];
    if (!result)
    {
        [self enumerateControlsUsingBlock:^(AKAControl *control, NSUInteger index, BOOL *stop) {
            result = *stop = [control shouldAutoActivate];
        }];
    }
    return result;
}

- (BOOL)shouldActivate
{
    return [super shouldActivate];
}

- (BOOL)shouldDeactivate
{
    return [super shouldActivate];
}

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

- (AKAKeyboardActivationSequence*)keyboardActivationSequence
{
    return self.owner.keyboardActivationSequence;
}

// TODO: probably not needed, each control defines by itself if it participates
- (BOOL)recursiveMembersParticipatesInKeyboardActivationSequence
{
    BOOL __block result = NO;
    [self enumerateControlsUsingBlock:^(AKAControl *control, NSUInteger index, BOOL *stop) {
        result |= control.participatesInKeyboardActivationSequence;
        *stop = result;
    }];
    return result;
}

#pragma mark Member Activation

/**
 * Determines if the specified control should be activated by first consulting
 * the delegate and then owner controls (transitively). If no delegate or owner
 * (including their delegates) vetoed and then all controls that would have to
 * be deactivate should do so, the result is YES.
 *
 * @param memberControl the member control
 *
 * @return YES if the specified member control should be updated.
 */
- (BOOL)shouldControlActivate:(AKAControl*)memberControl
{
    BOOL result = !memberControl.isActive;

    if (result)
    {
        // Let this instances delegate decide first
        id<AKAControlDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(shouldControlActivate:)])
        {
            result = [delegate shouldControlActivate:memberControl];
        }
    }

    if (result)
    {
        AKACompositeControl* owner = self.owner;
        if (owner != nil)
        {
            // Ascend the control tree to ensure all delegates
            // have been consulted first.
            result = [owner shouldControlActivate:memberControl];
        }

        // At this point, all ancestor delegates approved activation

        if (result && memberControl.owner == self)
        {
            if (self.isActive)
            {
                if (self.activeControl != nil)
                {
                    // This is the junction point between the current
                    // and future active control path and it is responsible to
                    // check if a currently active control and its transitive
                    // owners should be deactivated.
                    result = [self shouldDeactivateActiveSubtree];
                }
            }
            else if (owner != nil)
            {
                result = [self.owner shouldControlActivate:self];
            }
        }
    }

    return result;
}

- (void)controlWillActivate:(AKAControl *)memberControl
{
    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controlWillActivate:)])
    {
        [delegate controlWillActivate:memberControl];
    }
    [self.owner controlWillActivate:memberControl];
}

- (void)controlDidActivate:(AKAControl*)memberControl
{
    if (memberControl.owner == self)
    {
        if (self.activeControl != nil && self.activeControl != memberControl)
        {
            // This should not be necessary, because they should have deactivated
            // before another control activated, just to be sure:
            [self.activeControl didDeactivate];
            if (self.activeControl != nil)
            {
                [self controlDidDeactivate:self.activeControl];
            }
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

- (void)controlWillDeactivate:(AKAControl *)memberControl
{
    id<AKAControlDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(controlWillDeactivate:)])
    {
        [delegate controlWillDeactivate:memberControl];
    }
    [self.owner controlWillDeactivate:memberControl];
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

@implementation AKACompositeControl(Conveniences)

#pragma mark Adding and Removing Member Controls

- (BOOL)addControl:(AKAControl*)control
{
    return [self insertControl:control atIndex:self.controlsStorage.count];
}

- (BOOL)removeControl:(AKAControl*)control
{
    NSUInteger index = [self.controlsStorage indexOfObjectIdenticalTo:control];
    return [self removeControl:control atIndex:index];
}

- (NSUInteger)addControlsForControlViewsInViewHierarchy:(UIView*)rootView
{
    return [self insertControlsForControlViewsInViewHierarchy:rootView
                                                      atIndex:self.controlsStorage.count];
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
            AKAControl* control = [self createControlForView:controlView
                                           withConfiguration:controlView.bindingConfiguration];
            [self insertControl:control atIndex:index + count];
            ++count;
            if ([control isKindOfClass:[AKACompositeControl class]])
            {
                *doNotDescend = YES;
            }
        }
        else
        {
            [self addBindingsForView:view];
        }
    }];
    return count;
}

- (void)addControlsForControlViewsInOutletCollection:(NSArray*)outletCollection
{
    [self insertControlsForControlViewsInOutletCollection:outletCollection
                                                  atIndex:0];
}

- (void)insertControlsForControlViewsInOutletCollection:(NSArray*)outletCollection
                                                      atIndex:(NSUInteger)index
{
    NSUInteger count = 0;
    for (UIView* view in outletCollection)
    {
        if ([view conformsToProtocol:@protocol(AKAControlViewProtocol)])
        {
            UIView<AKAControlViewProtocol>* controlView = (id)view;
            AKAControl* control = [self createControlForView:controlView
                                           withConfiguration:controlView.bindingConfiguration];
            [self insertControl:control atIndex:index + count];
            ++count;
        }
        else
        {
            count += [self insertControlsForControlViewsInViewHierarchy:view
                                                                atIndex:index + count];
        }
    }
}

- (void)addControlsForControlViewsInOutletCollections:(NSArray*)arrayOfOutletCollections
{
    [self insertControlsForControlViewsInOutletCollections:arrayOfOutletCollections
                                                          atIndex:0];
}

- (void)insertControlsForControlViewsInOutletCollections:(NSArray*)arrayOfOutletCollections
                                                 atIndex:(NSUInteger)index
{
    NSUInteger count = 0;
    for (NSArray* outletCollection in arrayOfOutletCollections)
    {
        AKACompositeControl* collectionControl = [[AKACompositeControl alloc] initWithOwner:self configuration:nil];
        if ([self insertControl:collectionControl atIndex:index + count])
        {
            ++count;
            [collectionControl addControlsForControlViewsInOutletCollection:outletCollection];
        }
    }
}

- (void)addControlsForControlViewsInStaticTableView:(UITableView*)tableView
                                               dataSource:(id<UITableViewDataSource>)dataSource
{
    [self insertControlsForControlViewsInStaticTableView:tableView
                                              dataSource:dataSource
                                                 atIndex:self.controlsStorage.count];
}

- (void)insertControlsForControlViewsInStaticTableView:(UITableView*)tableView
                                                  dataSource:(id<UITableViewDataSource>)dataSource
                                                     atIndex:(NSUInteger)index
{
    NSUInteger count = 0;
    NSUInteger numberOfSections = [dataSource numberOfSectionsInTableView:tableView];
    for (NSInteger sectionIndex = 0; sectionIndex < numberOfSections; ++sectionIndex)
    {
        NSUInteger numberOfRows = (NSUInteger)[dataSource tableView:tableView numberOfRowsInSection:sectionIndex];
        for (NSInteger rowIndex = 0; rowIndex < numberOfRows; ++rowIndex)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell == nil)
            {
                // Offscreen cells will not be delivered by the table view. Since this method
                // is restricted to static table views, we can reasonably expect that
                // the cells returned by the data source will be the same instances that
                // we would get from the table view. Handling dynamic cells is much more
                // complicated and will hopefully be implemented in a later version.
                cell = [dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
            }
            if ([cell conformsToProtocol:@protocol(AKAControlViewProtocol)])
            {
                UIView<AKAControlViewProtocol>* controlView = (id)cell;
                AKAControl* control = [self createControlForView:controlView
                                               withConfiguration:controlView.bindingConfiguration];

                if ([control isKindOfClass:[AKATableViewCellCompositeControl class]])
                {
                    // Record the indexPath (and while we are at it, also tableView and dataSource)
                    // because it's otherwise very hard to find the right indexPath for a given
                    // cell. We want this to provide the means to AKAFormTableViewController to
                    // hide and show (or perform other operations on) rows which correspond to controls.
                    // TODO: this is quite a bit hacky, review the architecture
                    AKATableViewCellCompositeControl* tvccp = (AKATableViewCellCompositeControl*)control;
                    tvccp.indexPath = indexPath;
                    tvccp.tableView = tableView;
                    tvccp.dataSource = dataSource;
                    // Content controls are handled below
                }

                [self insertControl:control atIndex:index + count];
                ++count;
            }
            else if (cell != nil)
            {
                // If the cell is not a control view, handle is like any other view (scanning its
                // view hierarchy for control views).
                UIView* rootView = cell.contentView;
                count += [self insertControlsForControlViewsInViewHierarchy:rootView
                                                                    atIndex:index + count];
            }
        }
    }
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
        [self.controlsStorage enumerateObjectsAtIndexes:indexSet
                                                options:(NSEnumerationOptions)0
                                             usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                 block(obj, idx, &localStop);
                                                 *stop = localStop;
                                             }];
    }
    AKACompositeControl* owner = self.owner;
    if (!localStop && continueInOwner && owner)
    {
        NSUInteger index = [owner indexOfControl:self];
        [owner enumerateControlsUsingBlock:block startIndex:index+1 continueInOwner:continueInOwner];
    }
}

- (void)enumerateControlsRecursivelyUsingBlock:(void(^)(AKAControl* control, AKACompositeControl* owner, NSUInteger index, BOOL* stop))block
{
    [self enumerateControlsRecursivelyUsingBlock:block
                                      startIndex:0
                                 continueInOwner:NO];
}

- (void)enumerateControlsRecursivelyUsingBlock:(void(^)(AKAControl* control, AKACompositeControl* owner, NSUInteger index, BOOL* stop))block
                             startIndex:(NSUInteger)startIndex
                        continueInOwner:(BOOL)continueInOwner
{
    [self enumerateControlsUsingBlock:^(AKAControl* control, NSUInteger idx, BOOL *stop) {
        __block BOOL localStop = NO;
        block(control, self, idx, &localStop);
        if (!localStop && [control isKindOfClass:[AKACompositeControl class]])
        {
            AKACompositeControl* composite = (AKACompositeControl*)control;
            [composite enumerateControlsRecursivelyUsingBlock:^(AKAControl* control, AKACompositeControl* owner, NSUInteger idx, BOOL* stop) {
                block(control, owner, idx, &localStop);
                *stop = localStop;
            }];
        }
        *stop = localStop;
    }
                           startIndex:startIndex
                      continueInOwner:continueInOwner];
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
        __block BOOL localStop = NO;
        if ([control isKindOfClass:[AKACompositeControl class]])
        {
            AKACompositeControl* composite = (AKACompositeControl*)control;
            [composite enumerateLeafControlsUsingBlock:^(AKAControl* control, AKACompositeControl* owner, NSUInteger idx, BOOL* stop) {
                block(control, owner, idx, &localStop);
                *stop = localStop;
            }
                                            startIndex:0
                                       continueInOwner:NO]; // NO: this instance handles siblings
        }
        else
        {
            block(control, self, idx, &localStop);
        }
        *stop = localStop;
    }
                           startIndex:startIndex
                      continueInOwner:continueInOwner];
}

@end
