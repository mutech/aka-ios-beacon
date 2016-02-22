//
//  AKABinding_UITableView_dataSourceBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 03.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKAArrayComparer;

#import "AKABinding_UITableView_dataSourceBinding.h"

#import "AKABinding_Protected.h"
#import "AKAPredicatePropertyBinding.h"
#import "AKABindingErrors.h"
#import "AKABindingSpecification.h"
#import "AKANSEnumerations.h"

#import "AKATableViewCellFactoryArrayPropertyBinding.h"
#import "AKATableViewCellFactory.h"
#import "AKATableViewSectionDataSourceInfoPropertyBinding.h"
#import "AKATableViewDataSourceAndDelegateDispatcher.h"


#pragma mark - AKABinding_UITableView_dataSourceBinding Private Interface
#pragma mark -

@interface AKABinding_UITableView_dataSourceBinding () <
    UITableViewDataSource,
    UITableViewDelegate,
    AKAArrayPropertyBindingDelegate
    >

#pragma mark - Binding Configuration

@property(nonatomic, readonly) NSArray<AKATableViewSectionDataSourceInfo*>* sections;
@property(nonatomic) NSMutableArray<AKATableViewCellFactory*>*              defaultCellMapping;
@property(nonatomic) UITableViewRowAnimation                                insertAnimation;
@property(nonatomic) UITableViewRowAnimation                                deleteAnimation;
@property(nonatomic, weak) void                                           (^animatorBlock)(void(^)());

#pragma mark - Observation

@property(nonatomic, readonly) BOOL                                         isObserving;

#pragma mark - UITableView data source and delegate dispatcher

@property(nonatomic, readonly) AKATableViewDataSourceAndDelegateDispatcher* delegateDispatcher;

#pragma mark - UITableView updates

@property(nonatomic) BOOL                                                   tableViewUpdateDispatched;
@property(nonatomic) BOOL                                                   tableViewReloadDispatched;
@property(nonatomic) NSMutableDictionary<NSNumber*, AKAArrayComparer*>*     pendingTableViewChanges;
@property(nonatomic) BOOL                                                   startingChangeObservation;

@end


#pragma mark - AKABinding_UITableView_dataSourceBinding Implementation
#pragma mark -

@implementation AKABinding_UITableView_dataSourceBinding

@dynamic delegate;

#pragma mark - Initialization

+ (AKABindingSpecification*)                  specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    [self registerEnumerationAndOptionTypes];

    dispatch_once(&onceToken, ^{
        NSDictionary* spec = @{
            @"bindingType":          [AKABinding_UITableView_dataSourceBinding class],
            @"targetType":           [UITableView class],
            @"expressionType":       @(AKABindingExpressionTypeArray),
            @"arrayItemBindingType": [AKATableViewSectionDataSourceInfoPropertyBinding class],
            @"attributes":           @{
                @"defaultCellMapping":   @{
                    @"bindingType":          [AKATableViewCellFactoryArrayPropertyBinding class],
                    @"use":                  @(AKABindingAttributeUseBindToBindingProperty)
                },
                @"insertAnimation":      @{
                        @"expressionType":       @((AKABindingExpressionTypeEnumConstant|
                                                    AKABindingExpressionTypeAnyKeyPath)),
                        @"enumerationType":      @"UITableViewRowAnimation",
                        @"use":                  @(AKABindingAttributeUseBindToBindingProperty)
                        },
                @"deleteAnimation":      @{
                        @"expressionType":       @((AKABindingExpressionTypeEnumConstant|
                                                    AKABindingExpressionTypeAnyKeyPath)),
                        @"enumerationType":      @"UITableViewRowAnimation",
                        @"use":                  @(AKABindingAttributeUseBindToBindingProperty)
                        },
                @"animatorBlock":        @{
                        @"expressionType":       @(AKABindingExpressionTypeAnyKeyPath),
                        @"use":                  @(AKABindingAttributeUseBindToBindingProperty)
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

- (instancetype)                                       init
{
    if (self = [super init])
    {
        _pendingTableViewChanges = [NSMutableDictionary new];

        _deleteAnimation = UITableViewRowAnimationAutomatic;
        _insertAnimation = UITableViewRowAnimationAutomatic;
    }
    return self;
}

- (AKAProperty*)          defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                                    context:(req_AKABindingContext)bindingContext
                                             changeObserver:(AKAPropertyChangeObserver)changeObserver
                                                      error:(NSError* __autoreleasing _Nullable*)error
{
    (void)bindingExpression;
    (void)bindingContext;
    (void)error;

    // The resulting binding source property will always return nil as binding source. This is because
    // we require an array binding expression as primary expression.
    // TODO: too hacky, refactor this
    return [AKAProperty propertyOfWeakKeyValueTarget:nil keyPath:nil changeObserver:changeObserver];
}

#pragma mark - Properties

- (NSArray<AKATableViewSectionDataSourceInfo *> *)sections
{
    return self.syntheticTargetValue;
}

#pragma mark - Change Tracking

- (BOOL)                                        isObserving
{
    return self.delegateDispatcher != nil;
}

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

    // Perform a reload of the table view once the change observation start process if finished.
    // From this point on, the binding will synchronize the table view with changes to row data.
    [self.tableView reloadData];

    [self updateTableViewRowHeights];
}

- (void)                             targetArrayItemAtIndex:(NSUInteger)index
                                         valueDidChangeFrom:(id)oldValue
                                                         to:(id)newValue
{
    if (!self.startingChangeObservation)
    {
        // Do not update table view if change observation is starting, because this is a rather
        // fuzzy state. We are going to reload the table as soon as the observation start proceess
        // completed.
        AKATableViewSectionDataSourceInfo* oldSectionInfo = oldValue;
        AKATableViewSectionDataSourceInfo* newSectionInfo = newValue;

        if (oldSectionInfo.rows != newSectionInfo.rows)
        {
            [self dispatchTableViewUpdateForSection:index
                                 forChangesFromRows:oldSectionInfo.rows
                                             toRows:newSectionInfo.rows];
        }
    }
    [super targetArrayItemAtIndex:index valueDidChangeFrom:oldValue to:newValue];
}

#pragma mark - Table View Updates

- (void)                          updateTableViewRowHeights
{
    UITableView* tableView = self.tableView;
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)                  dispatchTableViewUpdateForSection:(NSUInteger)section
                                         forChangesFromRows:(NSArray*)oldRows
                                                     toRows:(NSArray*)newRows
{
    AKAArrayComparer* pendingChanges = self.pendingTableViewChanges[@(section)];
    if (pendingChanges == nil)
    {
        pendingChanges = [[AKAArrayComparer alloc] initWithOldArray:oldRows newArray:newRows];
    }
    else
    {
        // Merge previous changes with new ones:
        pendingChanges = [[AKAArrayComparer alloc] initWithOldArray:pendingChanges.oldArray newArray:pendingChanges.array];
    }
    self.pendingTableViewChanges[@(section)] = pendingChanges;

    if (!self.tableViewReloadDispatched)
    {
        self.tableViewReloadDispatched = YES;

        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf performPendingTableViewUpdates];
        });
    }}

- (void)                     performPendingTableViewUpdates
{
    void (^block)() = ^{
        UITableView* tableView = self.tableView;
        if (tableView)
        {
            if (!tableView.isDragging && !tableView.isDecelerating)
            {
                // It's only safe to update if the tableview is not scrolling:
                [tableView beginUpdates];
                for (NSNumber* sectionN in self.pendingTableViewChanges.allKeys)
                {
                    AKAArrayComparer* pendingChanges = self.pendingTableViewChanges[sectionN];

                    [pendingChanges updateTableView:tableView
                                            section:sectionN.unsignedIntegerValue
                                    deleteAnimation:self.deleteAnimation
                                    insertAnimation:self.insertAnimation];
                    [self.pendingTableViewChanges removeObjectForKey:sectionN];
                }
                [tableView endUpdates];
                self.tableViewReloadDispatched = NO;

                // Perform update for self-sizing cells now to ensure this will be done, disable
                // deferred updates which have already been scheduled (not necessary if done now).
                [self updateTableViewRowHeights];
                self.tableViewUpdateDispatched = NO;
            }
            else
            {
                // It's not safe to update, redispatch and try again.
                // TODO: replace this busy waiting by something more sensible
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

- (AKAProperty*)         createBindingTargetPropertyForView:(req_UIView)view
{
    (void)view;

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UITableView_dataSourceBinding* binding = target;
                (void)binding;

                return nil;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UITableView_dataSourceBinding* binding = target;
                (void)binding;
                (void)value;
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
                UITableView* tableView = binding.tableView;

                if (binding.delegateDispatcher)
                {
                    [binding.delegateDispatcher restoreOriginalDataSourceAndDelegate];
                    binding->_delegateDispatcher = nil;

                    // TODO: deselect currently selected rows, maybe restore previously selected
                    [tableView reloadData];
                }

                return !binding.isObserving;
            }];
}

- (UITableView*)                                  tableView
{
    return (UITableView*)self.view;
}

- (UITableViewCell*)                              tableView:(UITableView*)tableView
                                                cellForItem:(id)item
                                                atIndexPath:(NSIndexPath*)indexPath
                                                withMapping:(NSArray<AKATableViewCellFactory*>*)itemToCellMapping
{
    UITableViewCell* result = nil;

    for (AKATableViewCellFactory* factory in itemToCellMapping)
    {
        if (factory.predicate == nil || [factory.predicate evaluateWithObject:item])
        {
            result = [self tableView:tableView cellForRowAtIndexPath:indexPath withFactory:factory];
        }

        if (result)
        {
            break;
        }
    }

    return result;
}

- (UITableViewCell*)                              tableView:(UITableView*)tableView
                                      cellForRowAtIndexPath:(NSIndexPath*)indexPath
                                                withFactory:(AKATableViewCellFactory*)factory
{
    UITableViewCell* result = nil;

    NSString* cellIdentifier = factory.cellIdentifier;

    if (cellIdentifier)
    {
        result = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                 forIndexPath:indexPath];
    }

    if (!result)
    {
        Class cellType = factory.cellType;

        if ([cellType isSubclassOfClass:[UITableViewCell class]])
        {
            UITableViewCellStyle cellStyle = factory.cellStyle;
            result = [cellType alloc];
            result = [result initWithStyle:cellStyle reuseIdentifier:cellIdentifier];
        }
    }

    return result;
}

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

    UITableViewCell* result = [self tableView:tableView cellForItem:item
                                  atIndexPath:indexPath
                                  withMapping:sectionInfo.cellMapping];

    if (!result)
    {
        result = [self tableView:tableView
                     cellForItem:item
                     atIndexPath:indexPath
                     withMapping:self.defaultCellMapping];
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

- (void)                                          tableView:(UITableView*)tableView
                                            willDisplayCell:(UITableViewCell*)cell
                                          forRowAtIndexPath:(NSIndexPath*)indexPath
{
    (void)tableView;

    AKATableViewSectionDataSourceInfo* sectionInfo = [self tableView:tableView infoForSection:indexPath.section];
    id item = sectionInfo.rows[(NSUInteger)indexPath.row];

    id<AKABindingDelegate_UITableView_dataSourceBinding> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:addDynamicBindingsForCell:indexPath:dataContext:)])
    {
        [delegate               binding:self
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

    id<AKABindingDelegate_UITableView_dataSourceBinding> delegate = self.delegate;

    if ([delegate respondsToSelector:@selector(binding:removeDynamicBindingsForCell:indexPath:)])
    {
        [delegate               binding:self
           removeDynamicBindingsForCell:cell
                              indexPath:indexPath];
    }

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;

    if ([original respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)])
    {
        [original tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = UITableViewAutomaticDimension;

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;
    if ([original respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
    {
        result = [original tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = UITableViewAutomaticDimension;

    id<UITableViewDelegate> original = self.delegateDispatcher.originalDelegate;
    if ([original respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)])
    {
        result = [original tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return result;
}

@end
