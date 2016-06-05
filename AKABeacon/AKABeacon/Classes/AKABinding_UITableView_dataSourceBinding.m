//
//  AKABinding_UITableView_dataSourceBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 03.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAArrayComparer.h"
@import CoreData;

#import "AKABinding_UITableView_dataSourceBinding.h"

#import "AKABinding_Protected.h"
#import "AKABinding+SubclassInitialization.h"
#import "AKABinding+BindingOwner.h"
#import "AKABinding_BindingOwnerProperties.h"
#import "AKABinding+DelegateSupport.h"
#import "AKABinding+SubclassObservationEvents.h"

#import "AKAArrayPropertyBinding.h"
#import "AKAPredicatePropertyBinding.h"

#import "AKABindingErrors.h"
#import "AKABindingSpecification.h"
#import "AKANSEnumerations.h"
#import "AKAViewSizeTransitionListener.h"

#import "AKATableViewCellFactoryPropertyBinding.h"
#import "AKABindingExpressionEvaluator.h"
#import "AKATableViewCellFactory.h"
#import "AKATableViewSectionDataSourceInfoPropertyBinding.h"
#import "AKATableViewDataSourceAndDelegateDispatcher.h"

#import "AKABindingController+ChildBindingControllers.h"


#pragma mark - AKABinding_UITableView_dataSourceBinding Private Interface
#pragma mark -

@interface AKABinding_UITableView_dataSourceBinding () <
    UITableViewDataSource,
    UITableViewDelegate,
    AKAArrayPropertyBindingDelegate,
    AKAViewSizeTransitionListener
    >

#pragma mark - Binding Configuration

@property(nonatomic) AKABindingExpression*                                  dynamicSectionBindingExpression;

@property(nonatomic, readonly) NSArray<AKATableViewSectionDataSourceInfo*>* sections;
@property(nonatomic) AKABindingExpressionEvaluator*                         defaultCellMapping;
@property(nonatomic) UITableViewRowAnimation                                insertAnimation;
@property(nonatomic) UITableViewRowAnimation                                updateAnimation;
@property(nonatomic) UITableViewRowAnimation                                deleteAnimation;
@property(nonatomic, weak) void                                           (^animatorBlock)(void(^)());

#pragma mark - Dynamic Sections

@property(nonatomic) BOOL                                                   usesDynamicSections;
@property(nonatomic) NSMutableArray<AKATableViewSectionDataSourceInfo*>*    dynamicSections;
@property(nonatomic) NSArray*                                               dynamicSectionsSource;

#pragma mark - Data Source

@property(nonatomic) BOOL                                                   usesTableViewDataSource;
@property(nonatomic) id<UITableViewDataSource>                              tableViewDataSource;

#pragma mark - Observation

@property(nonatomic) BOOL                                                   isObserving;
@property(nonatomic) BOOL                                                   startingChangeObservation;

#pragma mark - UITableView data source and delegate dispatcher

@property(nonatomic, readonly) AKATableViewDataSourceAndDelegateDispatcher* delegateDispatcher;

#pragma mark - UITableView updates

@property(nonatomic) BOOL                                                   tableViewUpdateDispatched;
@property(nonatomic) BOOL                                                   tableViewReloadDispatched;
@property(nonatomic) NSMutableDictionary<NSNumber*, AKAArrayComparer*>*     pendingTableViewChanges;

@end


#pragma mark - AKABinding_UITableView_dataSourceBinding Implementation
#pragma mark -

@implementation AKABinding_UITableView_dataSourceBinding

@dynamic delegate;

#pragma mark - Specification

+ (AKABindingSpecification*)                  specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    [self registerEnumerationAndOptionTypes];

    dispatch_once(&onceToken, ^{
        NSDictionary* spec = @{
                               @"bindingType":          [AKABinding_UITableView_dataSourceBinding class],
                               @"targetType":           [UITableView class],
                               @"expressionType":       @(AKABindingExpressionTypeArray | AKABindingExpressionTypeAnyKeyPath),
                               @"arrayItemBindingType": [AKATableViewSectionDataSourceInfoPropertyBinding class],
                               @"attributes":           @{
                                       @"defaultCellMapping":  @{
                                               @"bindingType":         [AKATableViewCellFactoryPropertyBinding class],
                                               @"use":                 @(AKABindingAttributeUseAssignEvaluatorToBindingProperty)
                                               },
                                       @"dynamic":             @{
                                               @"bindingType":         [AKATableViewSectionDataSourceInfoPropertyBinding class],
                                               @"use":                 @(AKABindingAttributeUseAssignExpressionToBindingProperty),
                                               @"bindingProperty":     @"dynamicSectionBindingExpression"
                                               },
                                       @"insertAnimation":     @{
                                               @"expressionType":      @((AKABindingExpressionTypeEnumConstant|
                                                                          AKABindingExpressionTypeAnyKeyPath)),
                                               @"enumerationType":     @"UITableViewRowAnimation",
                                               @"use":                 @(AKABindingAttributeUseBindToBindingProperty)
                                               },
                                       @"deleteAnimation":     @{
                                               @"expressionType":      @((AKABindingExpressionTypeEnumConstant|
                                                                          AKABindingExpressionTypeAnyKeyPath)),
                                               @"enumerationType":     @"UITableViewRowAnimation",
                                               @"use":                 @(AKABindingAttributeUseBindToBindingProperty)
                                               },
                                       @"animatorBlock":       @{
                                               @"expressionType":      @(AKABindingExpressionTypeAnyKeyPath),
                                               @"use":                 @(AKABindingAttributeUseBindToBindingProperty)
                                               },
                                       }
                               };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    
    return result;
}

+ (void)                  registerEnumerationAndOptionTypes
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AKABindingExpressionSpecification registerEnumerationType:@"UITableViewRowAnimation"
                                                  withValuesByName:[AKANSEnumerations
                                                                    uitableViewRowAnimationsByName]];
    });
}

#pragma mark - Initialization

- (instancetype)                                       init
{
    if (self = [super init])
    {
        _pendingTableViewChanges = [NSMutableDictionary new];

        _deleteAnimation = UITableViewRowAnimationAutomatic;
        _insertAnimation = UITableViewRowAnimationAutomatic;
        _updateAnimation = UITableViewRowAnimationAutomatic;
    }
    return self;
}

#pragma mark - Initialization - Source Value Property

- (AKAProperty*)          defaultBindingSourceForExpression:(req_AKABindingExpression __unused)bindingExpression
                                                    context:(req_AKABindingContext __unused)bindingContext
                                             changeObserver:(AKAPropertyChangeObserver __unused)changeObserver
                                                      error:(NSError* __autoreleasing _Nullable* __unused)error
{
    return [AKAProperty constantNilProperty];
}

- (AKAProperty *)               bindingSourceForExpression:(AKABindingExpression *)bindingExpression
                                                   context:(req_AKABindingContext)bindingContext
                                            changeObserver:(AKAPropertyChangeObserver)changeObserver
                                                     error:(NSError *__autoreleasing  _Nullable *)error
{
    // Determine whether section infos are static (array constant) or dynamic (key path):
    self.usesDynamicSections = (bindingExpression.expressionType != AKABindingExpressionTypeArray);

    return [super bindingSourceForExpression:bindingExpression
                                     context:bindingContext
                              changeObserver:changeObserver
                                       error:error];
}

#pragma mark - Initialization - Target Value Property

- (req_AKAProperty)     createTargetValuePropertyForTarget:(req_id __unused)unusedTarget
                                                     error:(out_NSError)error
{
    // Implementation note: self.sections contains the current array of section infos, which is what
    // the targetValueProperty returns. When dynamic sections change, then the target setter is called
    // Observation is implemented by assigning the table views data source and delegate.

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UITableView_dataSourceBinding* binding = target;

                return binding.sections;
            }
                                      setter:
            ^(id target __unused, id value __unused)
            {
                NSAssert(self.usesDynamicSections, @"Attempt to update non-dynamic table view section infos");
                if (self.usesDynamicSections && self.dynamicSectionsSource != value)
                {
                    [self updateBindingsForDynamicSectionsSourceValue:self.dynamicSectionsSource
                                                             changeTo:value
                                                                error:error];
                }
            }
                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UITableView_dataSourceBinding* binding = target;
                UITableView* tableView = binding.tableView;
                if (binding.delegateDispatcher == nil)
                {
                    binding->_delegateDispatcher = [[AKATableViewDataSourceAndDelegateDispatcher alloc] initWithTableView:tableView
                                                                                                     dataSourceOverwrites:binding
                                                                                                       delegateOverwrites:binding];
                }

                return binding.isObserving;
            }

                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UITableView_dataSourceBinding* binding = target;

                if (binding.delegateDispatcher)
                {
                    [binding.delegateDispatcher restoreOriginalDataSourceAndDelegate];
                    binding->_delegateDispatcher = nil;

                    // TODO: cleanup deinitialization:
                    [self.pendingTableViewChanges removeAllObjects];
                    if (self.usesDynamicSections)
                    {
                        binding.dynamicSections = nil;
                        binding.dynamicSectionsSource = nil;
                        [self removeArrayItemBindings];
                    }

                    // TODO: deselect currently selected rows, maybe restore previously selected
                    [self reloadTableViewAnimated:NO];
                }
                
                return !binding.isObserving;
            }];
}

#pragma mark - Dynamic Sections


- (AKABinding*)                   bindingForDynamicSection:(NSUInteger)section
                                                inSections:(NSMutableArray*)sectionInfos
                                     withBindingExpression:(AKABindingExpression*)bindingExpression
                                               dataContext:(id)dataContext
                                                     error:(out_NSError)error
{
    AKABinding* binding = nil;

    __weak typeof(self) weakSelf = self;
    AKAProperty* bindingTarget = [AKAIndexedProperty propertyOfWeakIndexedTarget:sectionInfos
                                                                    index:(NSInteger)section
                                                           changeObserver:
                                  ^(id  _Nullable oldValue, id  _Nullable newValue)
                                  {
                                      [weakSelf targetArrayItemAtIndex:section
                                                                 value:oldValue == [NSNull null] ? nil : oldValue
                                                           didChangeTo:newValue == [NSNull null] ? nil : newValue];
                                  }];


    // TODO: manage life cycle of sections binding controllers
    AKABindingController* bindingController = self.controller;

    opt_AKABindingContext itemBindingContext =
        [bindingController createOrReuseBindingControllerForTargetObjectHierarchy:sectionInfos[section]
                                                                  withDataContext:dataContext
                                                                            error:error];

    if (itemBindingContext)
    {
        Class bindingType = bindingExpression.specification.bindingType;
        if (bindingType == nil)
        {
            // TODO: Should be AKATableViewSectionDataSourceInfoPropertyBinding? Maybe even assert the type
            bindingType = [AKAPropertyBinding class];
        }

        binding = [bindingType bindingToTarget:sectionInfos
                           targetValueProperty:bindingTarget
                                withExpression:bindingExpression
                                       context:(req_AKABindingContext)itemBindingContext
                                         owner:self
                                      delegate:[self delegateForSectionInfoBindingForSection:section]
                                         error:error];
    }

    return binding;
}

- (void)       updateBindingsForDynamicSectionsSourceValue:(NSArray*)oldSourceValue
                                                  changeTo:(NSArray*)newSourceValue
                                                     error:(out_NSError)error
{
    __weak typeof(self) weakSelf = self;

    AKABindingExpression* itemExpression = self.dynamicSectionBindingExpression;

    // Get or create dynamic section infos array
    NSMutableArray* sectionInfos = self.dynamicSections;
    if (sectionInfos == nil)
    {
        sectionInfos = [NSMutableArray new];
        self.dynamicSections = sectionInfos;
    }

    AKAArrayComparer* comparer = [[AKAArrayComparer alloc] initWithOldArray:oldSourceValue
                                                                   newArray:newSourceValue];

    NSMutableArray* stoppedBindings = [NSMutableArray new];

    // Update indexed binding target properties for relocated section bindings
    [comparer enumerateRelocatedItemsUsingBlock:
     ^(id  _Nonnull item __unused, NSUInteger oldIndex, NSUInteger newIndex)
     {
         AKABinding* binding = weakSelf.arrayItemBindings[oldIndex];
         [binding stopObservingChanges];
         [stoppedBindings addObject:binding];

         NSAssert([binding.targetValueProperty isKindOfClass:[AKAIndexedProperty class]],
                  @"Expected binding %@ target %@ to be an indexed property", binding, binding.targetValueProperty);

         AKAIndexedProperty* bindingTarget = (AKAIndexedProperty*)binding.targetValueProperty;

         NSAssert(bindingTarget.index == oldIndex, @"Binding target %@'s index %ld does not match old index %ld", bindingTarget, (long)bindingTarget.index, (long)oldIndex);

         bindingTarget.index = (NSInteger)newIndex;
     }];

    // Update sectionInfos for deleted, moved and inserted sections:
    [comparer applyChangesToTransformedArray:sectionInfos
                     blockBeforeDeletingItem:NULL
                       blockMappingMovedItem:NULL
                    blockMappingInsertedItem:
     ^id(id newSourceItem __unused, NSUInteger index __unused)
     {
         return [AKATableViewSectionDataSourceInfo new];
     }];

    // Get or create mutable array or array item bindings
    NSMutableArray<AKABinding*>* arrayItemBindings = ([self.arrayItemBindings isKindOfClass:[NSMutableArray class]]
                                                      ? (NSMutableArray*)self.arrayItemBindings
                                                      : [NSMutableArray arrayWithArray:(self.arrayItemBindings
                                                                                        ? self.arrayItemBindings
                                                                                        : @[])]);
    [comparer applyChangesToTransformedArray:arrayItemBindings
                     blockBeforeDeletingItem:
     ^(id deletedItem)
     {
         [((AKABinding*)deletedItem) stopObservingChanges];
     }
                       blockMappingMovedItem:NULL
                    blockMappingInsertedItem:
     ^id(id dataContext, NSUInteger section)
     {
         AKABinding* binding = [weakSelf bindingForDynamicSection:section
                                                       inSections:sectionInfos
                                            withBindingExpression:itemExpression
                                                      dataContext:dataContext
                                                            error:error];
         [stoppedBindings addObject:binding];

         return binding;
     }];

    // Install array item bindings, if changes were not made inline
    if (self.arrayItemBindings != arrayItemBindings)
    {
        self.arrayItemBindings = arrayItemBindings;
    }

    self.dynamicSectionsSource = newSourceValue;
    
    for (AKABinding* binding in stoppedBindings)
    {
        [binding startObservingChanges];
    }

    if (!self.startingChangeObservation)
    {
        //  Use dispatchTableViewReload?
        [self reloadTableViewAnimated:YES];
    }
}


#pragma mark - Properties

- (UITableView*)                                 tableView
{
    return (UITableView*)self.target;
}

- (NSArray<AKATableViewSectionDataSourceInfo *> *)sections
{
    // For static sections (primary binding expression is a manifest array), the section infos are
    // provided in syntheticTargetValue - implemented in AKABinding, for dynamic sections, this
    // binding maintains self.dynamicSections.

    NSArray* result = self.usesDynamicSections ? self.dynamicSections : self.syntheticTargetValue;
    return result;
}

#pragma mark - Change Tracking

- (void)                          willStartObservingChanges
{
    // We need to skip table view updates while the binding is starting change tracking, which
    // would in some cases result in table view updates being performed after a table view reload
    // or before the data is available.
    self.startingChangeObservation = YES;
}

- (void)                           didStartObservingChanges
{
    self.startingChangeObservation = NO;

    self.isObserving = YES;

    // Perform a reload of the table view once the change observation start process if finished.
    // From this point on, the binding will synchronize the table view with changes to row data.
    [self reloadTableViewAnimated:NO];
}

- (void)                            willStopObservingChanges
{
    self.isObserving = NO;
}

#pragma mark - AKABindingDelegate (Sub Bindings)

- (BOOL)shouldReceiveDelegateMessagesForImmediateSubBindings
{
    return NO;
}

- (BOOL)shouldReceiveDelegateMessagesForTransitiveSubBindings
{
    return NO;
}

- (id<AKABindingDelegate>)delegateForSectionInfoBindingForSection:(NSUInteger __unused)section
{
    return self;
}

- (id<AKABindingDelegate>)delegateForArrayItemBindingAtIndex:(NSUInteger)index
{
    return [self delegateForSectionInfoBindingForSection:index];
}

- (void)                                            binding:(req_AKABinding)binding
                                       didUpdateTargetValue:(opt_id)oldTargetValue
                                                         to:(opt_id)newTargetValue
                                             forSourceValue:(opt_id __unused)oldSourceValue
                                                   changeTo:(opt_id __unused)newSourceValue
{
    // Update table view, if a section's rows have been updated and the responsible array property
    // binding is not configured to generate content change events.
    // Do not update if the binding is starting to observe changes (a table view reload will be
    // performed when start is completed).
    // Also do not update if target value did not change (assuming immutable arrays)
    if (!self.startingChangeObservation)
    {
        if (oldTargetValue != newTargetValue)
        {
            if ([binding isKindOfClass:[AKAArrayPropertyBinding class]])
            {
                if ([binding.owner isKindOfClass:[AKATableViewSectionDataSourceInfoPropertyBinding class]])
                {
                    AKATableViewSectionDataSourceInfoPropertyBinding* sectionBinding = (id)binding.owner;
                    if (sectionBinding.target == self.sections)
                    {
                        AKAArrayPropertyBinding* apBinding = (id)binding;
                        if (!apBinding.generateContentChangeEventsForSourceArrayChanges)
                        {
                            NSUInteger section = NSNotFound;
                            id value = sectionBinding.targetValueProperty.value;
                            if (value)
                            {
                                section = [self.sections indexOfObject:value];
                            }

                            NSAssert(section != NSNotFound, @"Section info not found");
                            
                            [self dispatchTableViewUpdateForSection:section
                                                 forChangesFromRows:oldTargetValue
                                                             toRows:newTargetValue];
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - AKAViewSizeTransitionListener

- (void)                                     viewController:(UIViewController *)viewController
                                   viewWillTransitionToSize:(CGSize)size
                                  withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self updateTableViewRowHeightsAnimated:YES];
}

#pragma mark - Table View Updates

- (void)                             beginUpdatingTableView:(UITableView*)tableView
{
    id <AKABindingDelegate_UITableView_dataSourceBinding> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(bindingWillUpdateDynamicBindings:)])
    {
        [delegate bindingWillUpdateDynamicBindings:self];
    }
    [tableView beginUpdates];
}

- (void)                               endUpdatingTableView:(UITableView*)tableView
{
    [tableView endUpdates];
    id <AKABindingDelegate_UITableView_dataSourceBinding> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(bindingDidUpdateDynamicBindings:)])
    {
        [delegate bindingDidUpdateDynamicBindings:self];
    }
}

- (void)                            reloadTableViewAnimated:(BOOL)animated
{
    [self.pendingTableViewChanges removeAllObjects];

    UITableView* tableView = self.tableView;

    if (!animated)
    {
        BOOL animationsWereEnabled = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [tableView reloadData];
        [UIView setAnimationsEnabled:animationsWereEnabled];
    }
    else
    {
        [tableView reloadData];
    }
    //[self updateTableViewRowHeightsAnimated:NO]; // No animation for row height updates because it looks clumsy to have two successive animations
}

- (void)                  updateTableViewRowHeightsAnimated:(BOOL)animated
{
    UITableView* tableView = self.tableView;
    if (!animated)
    {
        BOOL animationsWereEnabled = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [tableView beginUpdates];
        [tableView endUpdates];
        [UIView setAnimationsEnabled:animationsWereEnabled];
    }
    else
    {
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

#pragma mark - Table View Updates - Delayed Updates


- (BOOL)tableViewIsEmpty
{
    UITableView* tableView = self.tableView;

    BOOL result = (tableView.numberOfSections == 0 ||
                   (tableView.numberOfSections == 1 && [tableView numberOfRowsInSection:0] == 0));

    return result;
}

- (void)                            dispatchTableViewReload:(BOOL)animated
{
    if (!self.tableViewReloadDispatched)
    {
        self.tableViewUpdateDispatched = NO;
        self.tableViewReloadDispatched = YES;
        [self.pendingTableViewChanges removeAllObjects];

        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf performPendingTableViewReload];
        });
    }
}

- (void)                  dispatchTableViewUpdateForSection:(NSUInteger)section
                                         forChangesFromRows:(NSArray*)oldRows
                                                     toRows:(NSArray*)newRows
{
    if ([self tableViewIsEmpty])
    {
        [self dispatchTableViewReload:YES];
        return;
    }

    if (!self.tableViewReloadDispatched)
    {
        AKAArrayComparer* pendingChanges = self.pendingTableViewChanges[@(section)];
        if (pendingChanges == nil)
        {
            pendingChanges = [[AKAArrayComparer alloc] initWithOldArray:oldRows newArray:newRows];
        }
        else
        {
            // Merge previous changes with new ones:
            pendingChanges = [[AKAArrayComparer alloc] initWithOldArray:pendingChanges.oldArray newArray:newRows];
        }
        self.pendingTableViewChanges[@(section)] = pendingChanges;

        if (!self.tableViewReloadDispatched)
        {
            self.tableViewUpdateDispatched = YES;

            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf performPendingTableViewUpdates];
            });
        }
    }
}

- (void)                      performPendingTableViewReload
{
    if (self.tableViewReloadDispatched)
    {
        // Disable pending updates (since the table view is being reloaded, updates are obsolete
        // and would probably fail after the reload)
        self.tableViewUpdateDispatched = NO;
        [self.pendingTableViewChanges removeAllObjects];

        void (^block)() = ^{
            UITableView* tableView = self.tableView;
            if (tableView)
            {
                if (!tableView.isDragging && !tableView.isDecelerating)
                {
                    [self reloadTableViewAnimated:YES];
                    self.tableViewReloadDispatched = NO;
                }
                else
                {
                    // It's not safe to update, redispatch and try again.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performPendingTableViewReload];
                    });
                }
            }
        };

        // Wrap reload in an animator block - if defined. This can be used to synchronize table view
        // updates with other animations that should be performed alongside. TODO: use delegate to implement
        // this (will begin/did end update table view); the implementation via block binding is ugly.
        void (^animatorBlock)() = self.animatorBlock;
        if (animatorBlock != NULL)
        {
            animatorBlock(block);
        }
        else
        {
            block();
        }
    }
}

- (void)                     performPendingTableViewUpdates
{
    if (self.tableViewUpdateDispatched)
    {
        void (^block)() = ^{
            UITableView* tableView = self.tableView;
            if (tableView)
            {
                if (!tableView.isDragging && !tableView.isDecelerating)
                {
                    [self beginUpdatingTableView:tableView];
                    for (NSNumber* sectionN in self.pendingTableViewChanges.allKeys)
                    {
                        AKAArrayComparer* pendingChanges = self.pendingTableViewChanges[sectionN];

                        [pendingChanges updateTableView:tableView
                                                section:sectionN.unsignedIntegerValue
                                        deleteAnimation:self.deleteAnimation
                                        insertAnimation:self.insertAnimation];
                        [self.pendingTableViewChanges removeObjectForKey:sectionN];

                        [self updateTableViewRowHeightsAnimated:YES];
                    }
                    [self endUpdatingTableView:tableView];


                    // Perform update for self-sizing cells now to ensure this will be done
                    //[self updateTableViewRowHeightsAnimated:NO];

                    // Everything is up to date, disable already dispatched updates.
                    self.tableViewUpdateDispatched = NO;
                }
                else
                {
                    // It's not safe to update, redispatch and try again.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performPendingTableViewUpdates];
                    });
                }
            }
        };

        // Wrap updates in an animator block - if defined. This can be used to synchronize table view
        // updates with other animations that should be performed alongside. TODO: use delegate to implement
        // this (will begin/did end update table view); the implementation via block binding is ugly.
        void (^animatorBlock)() = self.animatorBlock;
        if (animatorBlock != NULL)
        {
            animatorBlock(block);
        }
        else
        {
            block();
        }
    }
}

#pragma mark - Table View Updates - Row Updates

- (AKATableViewSectionDataSourceInfoPropertyBinding*)sectionInfoBindingForArrayBinding:(AKAArrayPropertyBinding*)binding
{
    AKATableViewSectionDataSourceInfoPropertyBinding* result = nil;
    if ([binding.owner isKindOfClass:[AKATableViewSectionDataSourceInfoPropertyBinding class]])
    {
        result = (id)binding.owner;
        if (result.target != self.sections)
        {
            result = nil;
        }
    }
    return result;
}

- (AKATableViewSectionDataSourceInfo* _Nullable)sectionInfoForArrayBinding:(AKAArrayPropertyBinding*)binding
{
    return [self sectionInfoBindingForArrayBinding:binding].targetValueProperty.value;
}

- (void)                                            binding:(AKAArrayPropertyBinding* __unused)binding
                      collectionControllerWillChangeContent:(opt_id __unused)controller
{
    NSAssert([NSThread isMainThread], @"Collection updates affecting table views have to be called from main thread!");

    // TODO: defer updates if scrolling
    // TODO: don't begin updates if already updating (increment counter)

    [self beginUpdatingTableView:self.tableView];
}

- (void)                                            binding:(AKAArrayPropertyBinding *)binding
                                       collectionController:(id __unused)controller
                                            didInsertObject:(id __unused)object
                                                    atIndex:(NSUInteger)index
{
    AKATableViewSectionDataSourceInfo* sectionInfo = [self sectionInfoForArrayBinding:binding];
    if (sectionInfo != nil)
    {
        // TODO: defer updates if scrolling

        NSInteger section = (NSInteger)[self.sections indexOfObject:sectionInfo];
        NSAssert(section != NSNotFound, @"Invalid section info %@: not found in %@", sectionInfo, self.sections);

        [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:(NSInteger)index inSection:section] ]
                              withRowAnimation:self.insertAnimation];
    }
}

- (void)                                            binding:(AKAArrayPropertyBinding *)binding
                                       collectionController:(id __unused)controller
                                            didUpdateObject:(id __unused)object
                                                    atIndex:(NSUInteger)index
{
    NSAssert([NSThread isMainThread], @"Collection updates affecting table views have to be called from main thread!");

    AKATableViewSectionDataSourceInfo* sectionInfo = [self sectionInfoForArrayBinding:binding];
    if (sectionInfo != nil)
    {
        // TODO: defer updates if scrolling

        NSInteger section = (NSInteger)[self.sections indexOfObject:sectionInfo];
        NSAssert(section != NSNotFound, @"Invalid section info %@: not found in %@", sectionInfo, self.sections);

        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:(NSInteger)index inSection:section] ]
                              withRowAnimation:self.updateAnimation];
    }
}

- (void)                                            binding:(AKAArrayPropertyBinding *)binding
                                       collectionController:(id __unused)controller
                                            didDeleteObject:(id __unused)object
                                                    atIndex:(NSUInteger)index
{
    NSAssert([NSThread isMainThread], @"Collection updates affecting table views have to be called from main thread!");

    AKATableViewSectionDataSourceInfo* sectionInfo = [self sectionInfoForArrayBinding:binding];
    if (sectionInfo != nil)
    {
        // TODO: defer updates if scrolling

        NSInteger section = (NSInteger)[self.sections indexOfObject:sectionInfo];
        NSAssert(section != NSNotFound, @"Invalid section info %@: not found in %@", sectionInfo, self.sections);

        [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:(NSInteger)index inSection:section] ]
                              withRowAnimation:self.deleteAnimation];
    }
}

- (void)                                            binding:(AKAArrayPropertyBinding *)binding
                                       collectionController:(id __unused)controller
                                              didMoveObject:(id __unused)object
                                                  fromIndex:(NSUInteger)oldIndex
                                                    toIndex:(NSUInteger)newIndex
{
    NSAssert([NSThread isMainThread], @"Collection updates affecting table views have to be called from main thread!");

    AKATableViewSectionDataSourceInfo* sectionInfo = [self sectionInfoForArrayBinding:binding];
    if (sectionInfo != nil)
    {
        // TODO: defer updates if scrolling

        NSInteger section = (NSInteger)[self.sections indexOfObject:sectionInfo];
        NSAssert(section != NSNotFound, @"Invalid section info %@: not found in %@", sectionInfo, self.sections);

        [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:(NSInteger)oldIndex inSection:section]
                               toIndexPath:[NSIndexPath indexPathForRow:(NSInteger)newIndex inSection:section]];
    }
}

- (void)                                            binding:(AKAArrayPropertyBinding* __unused)binding
                       collectionControllerDidChangeContent:(opt_id __unused)controller
{
    NSAssert([NSThread isMainThread], @"Collection updates affecting table views have to be called from main thread!");

    // TODO: defer end updates if scrolling
    // TODO: don't end updates if still updating (decrement counter)

    [self endUpdatingTableView:self.tableView];
}

#pragma mark - Table View - Data Mapping

- (AKATableViewSectionDataSourceInfo*)            tableView:(UITableView*)tableView
                                             infoForSection:(NSInteger)section
{
    (void)tableView;

    id result = self.sections[(NSUInteger)section];

    if (result == [NSNull null])
    {
        result = nil;
    }

    return result;
}

#pragma mark - UITableViewDataSource

- (NSInteger)                   numberOfSectionsInTableView:(UITableView*)tableView
{
    (void)tableView;
    NSAssert(tableView == self.tableView,
             @"numberOfSectionsInTableView: Invalid tableView, expected binding target tableView");

    // Return 0 sections if change observation start process is active, this will reload the
    // table when completed.
    NSInteger result = 0;
    if (!self.startingChangeObservation)
    {
        result = (NSInteger)self.sections.count;
    }
    return result;
}

- (NSInteger)                                     tableView:(UITableView*)tableView
                                      numberOfRowsInSection:(NSInteger)section
{
    NSAssert(tableView == self.tableView,
             @"tableView:numberOfRowsInSection: Invalid tableView, expected binding target tableView");

    AKATableViewSectionDataSourceInfo* sectionInfo = [self tableView:tableView infoForSection:section];
    NSInteger result = (NSInteger)sectionInfo.rows.count;
    return result;
}

- (UITableViewCell*)                              tableView:(UITableView*)tableView
                                      cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    AKATableViewSectionDataSourceInfo* sectionInfo = [self tableView:tableView infoForSection:indexPath.section];
    id item = sectionInfo.rows[(NSUInteger)indexPath.row];

    AKATableViewCellFactory* factory = [sectionInfo.cellMapping valueForDataContext:item];
    UITableViewCell* result = [factory tableView:tableView
                           cellForRowAtIndexPath:indexPath];

    if (!result)
    {
        factory = [self.defaultCellMapping valueForDataContext:item];
        result = [factory tableView:tableView cellForRowAtIndexPath:indexPath];
    }

    if (!result)
    {
        result = [self.delegateDispatcher.originalDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    }

    return result;
}

- (NSString*)                                     tableView:(UITableView*)tableView
                                    titleForHeaderInSection:(NSInteger)section
{
    NSString* result = nil;

    if (self.isObserving)
    {
        result = [self tableView:tableView infoForSection:section].headerTitle;

        if (!result)
        {
            id<UITableViewDataSource> original = self.delegateDispatcher.originalDataSource;

            if ([original respondsToSelector:@selector(tableView:titleForHeaderInSection:)])
            {
                result = [original tableView:tableView titleForHeaderInSection:section];
            }
        }
    }

    return result;
}

- (NSString*)                                     tableView:(UITableView*)tableView
                                    titleForFooterInSection:(NSInteger)section
{
    NSString* result = nil;

    if (self.isObserving)
    {
        result = [self tableView:tableView infoForSection:section].footerTitle;

        if (!result)
        {
            id<UITableViewDataSource> original = self.delegateDispatcher.originalDataSource;

            if ([original respondsToSelector:@selector(tableView:titleForFooterInSection:)])
            {
                result = [original tableView:tableView titleForFooterInSection:section];
            }
        }
    }

    return result;
}

#pragma mark - UITableViewDelegate

- (void)                                          tableView:(UITableView* __unused)tableView
                                            willDisplayCell:(UITableViewCell*)cell
                                          forRowAtIndexPath:(NSIndexPath*)indexPath
{
    AKATableViewSectionDataSourceInfo* sectionInfo = [self tableView:tableView infoForSection:indexPath.section];
    id item = sectionInfo.rows[(NSUInteger)indexPath.row];

    id<AKABindingDelegate_UITableView_dataSourceBinding> controller = self.controller;

    if ([controller respondsToSelector:@selector(binding:addDynamicBindingsForCell:indexPath:dataContext:)])
    {
        [controller               binding:self
              addDynamicBindingsForCell:cell
                              indexPath:indexPath
                            dataContext:item];
    }

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;

    if ([original respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)])
    {
        [original tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)                                          tableView:(UITableView*)tableView
                                       didEndDisplayingCell:(UITableViewCell*)cell
                                          forRowAtIndexPath:(NSIndexPath*)indexPath
{
    (void)tableView;

    id<AKABindingDelegate_UITableView_dataSourceBinding> controller = self.controller;

    if ([controller respondsToSelector:@selector(binding:removeDynamicBindingsForCell:indexPath:)])
    {
        [controller               binding:self
           removeDynamicBindingsForCell:cell
                              indexPath:indexPath];
    }

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;

    if ([original respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)])
    {
        [original tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (CGFloat)                                       tableView:(UITableView *)tableView
                                    heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = UITableViewAutomaticDimension;

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;
    if ([original respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
    {
        result = [original tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return result;
}

- (CGFloat)                                       tableView:(UITableView *)tableView
                           estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat result = UITableViewAutomaticDimension;

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;
    if ([original respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)])
    {
        result = [original tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return result;
}

- (void)                                          tableView:(UITableView*__unused)tableView
                                      willDisplayHeaderView:(nonnull UIView *)view
                                                 forSection:(NSInteger)section
{
    AKATableViewSectionDataSourceInfo* sectionInfo = [self tableView:tableView infoForSection:section];

    id<AKABindingDelegate_UITableView_dataSourceBinding> controller = self.controller;

    if ([controller respondsToSelector:@selector(binding:addDynamicBindingsForSection:headerView:dataContext:)])
    {
        [controller               binding:self
           addDynamicBindingsForSection:section
                             headerView:view
                            dataContext:sectionInfo];
    }

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;
    if ([original respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)])
    {
        [original tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)                                          tableView:(UITableView*)tableView
                                      willDisplayFooterView:(nonnull UIView *)view
                                                 forSection:(NSInteger)section
{
    (void)tableView;

    AKATableViewSectionDataSourceInfo* sectionInfo = [self tableView:tableView infoForSection:section];

    id<AKABindingDelegate_UITableView_dataSourceBinding> controller = self.controller;

    if ([controller respondsToSelector:@selector(binding:addDynamicBindingsForSection:footerView:dataContext:)])
    {
        [controller               binding:self
           addDynamicBindingsForSection:section
                             footerView:view
                            dataContext:sectionInfo];
    }

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;

    if ([original respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)])
    {
        [original tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)                                          tableView:(UITableView*)tableView
                                 didEndDisplayingHeaderView:(nonnull UIView *)view
                                                 forSection:(NSInteger)section
{
    (void)tableView;

    id<AKABindingDelegate_UITableView_dataSourceBinding> controller = self.controller;

    AKATableViewSectionDataSourceInfo* sectionInfo = [self tableView:tableView infoForSection:section];

    if ([controller respondsToSelector:@selector(binding:removeDynamicBindingsForSection:headerView:dataContext:)])
    {
        [controller               binding:self
        removeDynamicBindingsForSection:section
                             headerView:view
                            dataContext:sectionInfo];
    }

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;

    if ([original respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)])
    {
        [original tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)                                          tableView:(UITableView*)tableView
                                 didEndDisplayingFooterView:(nonnull UIView *)view
                                                 forSection:(NSInteger)section
{
    (void)tableView;

    id<AKABindingDelegate_UITableView_dataSourceBinding> controller = self.controller;
    if ([controller respondsToSelector:@selector(binding:removeDynamicBindingsForSection:footerView:dataContext:)])
    {
        AKATableViewSectionDataSourceInfo* sectionInfo = [self tableView:tableView infoForSection:section];
        
        [controller               binding:self
        removeDynamicBindingsForSection:section
                             footerView:view
                            dataContext:sectionInfo];
    }

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;
    if ([original respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)])
    {
        [original tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

@end


#import "AKABindingController+ChildBindingControllers.h"


#pragma mark - AKABindingController(BindingDelegate_UITableView_dataSourceBinding) - Interface
#pragma mark -

@interface AKABindingController(BindingDelegate_UITableView_dataSourceBinding) <AKABindingDelegate_UITableView_dataSourceBinding>
@end


#pragma mark - AKABindingController(BindingDelegate_UITableView_dataSourceBinding) - Implementation
#pragma mark -

@implementation AKABindingController(BindingDelegate_UITableView_dataSourceBinding)

- (void)                bindingWillUpdateDynamicBindings:(AKABinding_UITableView_dataSourceBinding *)binding
{
    [self beginUpdatingChildControllers];
}

- (void)                bindingDidUpdateDynamicBindings:(AKABinding_UITableView_dataSourceBinding *)binding
{
    [self endUpdatingChildControllers];
}


- (void)                binding:(AKABinding_UITableView_dataSourceBinding *)binding
      addDynamicBindingsForCell:(UITableViewCell *)cell
                      indexPath:(NSIndexPath *)indexPath
                    dataContext:(id)dataContext
{
    [self createOrReuseBindingControllerForTargetObjectHierarchy:cell
                                                 withDataContext:dataContext
                                                           error:nil];
}

- (void)                binding:(AKABinding_UITableView_dataSourceBinding *)binding
   removeDynamicBindingsForCell:(UITableViewCell *)cell
                      indexPath:(NSIndexPath *)indexPath
{
    [self removeBindingControllerForTargetObjectHierarchy:cell
                                            enqueForReuse:cell.reuseIdentifier.length > 0];
}

- (void)                binding:(AKABinding_UITableView_dataSourceBinding *)binding
   addDynamicBindingsForSection:(NSInteger)section
                     headerView:(UIView *)headerView
                    dataContext:(id)dataContext
{
    [self createOrReuseBindingControllerForTargetObjectHierarchy:headerView
                                                 withDataContext:dataContext
                                                           error:nil];
}

- (void)                binding:(AKABinding_UITableView_dataSourceBinding *)binding
removeDynamicBindingsForSection:(NSInteger)section
                     headerView:(UIView *)headerView
                    dataContext:(id)dataContext
{
    [self removeBindingControllerForTargetObjectHierarchy:headerView
                                            enqueForReuse:NO];
}

- (void)                binding:(AKABinding_UITableView_dataSourceBinding *)binding
   addDynamicBindingsForSection:(NSInteger)section
                     footerView:(UIView *)footerView
                    dataContext:(id)dataContext
{
    [self createOrReuseBindingControllerForTargetObjectHierarchy:footerView
                                                 withDataContext:dataContext
                                                           error:nil];
}

- (void)                binding:(AKABinding_UITableView_dataSourceBinding *)binding
removeDynamicBindingsForSection:(NSInteger)section
                     footerView:(UIView *)headerView
                    dataContext:(id)dataContext
{
    [self removeBindingControllerForTargetObjectHierarchy:headerView
                                            enqueForReuse:NO];
}

@end
