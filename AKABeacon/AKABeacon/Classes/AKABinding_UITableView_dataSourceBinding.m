//
//  AKABinding_UITableView_dataSourceBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 03.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.AKAArrayComparer;
#import "AKABinding_UITableView_dataSourceBinding.h"
#import "AKATableViewCellFactoryArrayPropertyBinding.h"
#import "AKATableViewCellFactory.h"
#import "AKAPredicatePropertyBinding.h"
#import "AKADelegateDispatcher.h"
#import "AKABindingErrors.h"
#import "AKABindingSpecification.h"
#import "AKANSEnumerations.h"

#pragma mark - AKATableViewSectionDataSourceInfo Interface
#pragma mark -

@interface AKATableViewSectionDataSourceInfo: NSObject

@property(nonatomic) NSArray* rows;
@property(nonatomic) NSString* headerTitle;
@property(nonatomic) NSString* footerTitle;
@property(nonatomic) NSArray<AKATableViewCellFactory*>* cellMapping;

@end


#pragma mark - AKATableViewSectionDataSourceInfo Implementation
#pragma mark -

@implementation AKATableViewSectionDataSourceInfo

- (void)setRows:(NSArray*)rows
{
    _rows = rows;
}

@end

#pragma mark - AKATableViewSectionDataSourceInfoPropertyBinding Interface
#pragma mark -

@interface AKATableViewSectionDataSourceInfoPropertyBinding: AKAPropertyBinding<AKAArrayPropertyBindingDelegate>

@property(nonatomic) id sourceValue;
@property(nonatomic) AKATableViewSectionDataSourceInfo* cachedTargetValue;

@end


#pragma mark - AKATableViewSectionDataSourceInfoPropertyBinding Implementation
#pragma mark -

@implementation AKATableViewSectionDataSourceInfoPropertyBinding

+ (AKABindingSpecification*)specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
            @{ @"bindingType":          [AKATableViewSectionDataSourceInfoPropertyBinding class],
               @"targetType":           [UITableView class],
               @"expressionType":       @(AKABindingExpressionTypeAnyKeyPath),
               @"attributes":           @{
                   @"headerTitle":          @{
                       @"use":                  @(AKABindingAttributeUseBindToTargetProperty),
                       @"expressionType":       @(AKABindingExpressionTypeStringConstant)
                   },
                   @"footerTitle":          @{
                       @"use":                  @(AKABindingAttributeUseBindToTargetProperty),
                       @"expressionType":       @(AKABindingExpressionTypeStringConstant)
                   },
                   @"cellMapping":          @{
                       @"use":                  @(AKABindingAttributeUseBindToTargetProperty),
                       @"bindingType":          [AKATableViewCellFactoryArrayPropertyBinding class]
                   }
               }
        };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

- (BOOL)convertSourceValue:(id)sourceValue
             toTargetValue:(id _Nullable __autoreleasing*)targetValueStore
                     error:(NSError* __autoreleasing _Nullable*)error
{
    BOOL result = sourceValue == nil || [sourceValue isKindOfClass:[NSArray class]];

    if (result)
    {
        if (!self.cachedTargetValue)
        {
            self.cachedTargetValue = [AKATableViewSectionDataSourceInfo new];
        }

        if (sourceValue != self.sourceValue || sourceValue == nil)
        {
            self.cachedTargetValue.rows = sourceValue;
        }
        *targetValueStore = self.cachedTargetValue;
    }
    else
    {
        if (error)
        {
            *error = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                           sourceValue:sourceValue
                                         failedWithInvalidTypeExpected:[NSArray class]];
        }
    }

    return result;
}

#pragma mark - Binding Delegate

@end


#pragma mark - AKATableViewDataSourceAndDelegateDispatcher Interface
#pragma mark -

@interface AKATableViewDataSourceAndDelegateDispatcher: AKADelegateDispatcher<UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableView:(UITableView*)tableView
             dataSourceOverwrites:(id<UITableViewDataSource>)dataSource
               delegateOverwrites:(id<UITableViewDelegate>)delegate;
- (void)restoreOriginalDataSourceAndDelegate;

@property(nonatomic, readonly, weak) UITableView*              tableView;
@property(nonatomic, readonly, weak) id<UITableViewDataSource> originalDataSource;
@property(nonatomic, readonly, weak) id<UITableViewDelegate>   originalDelegate;

@end


#pragma mark - AKATableViewDataSourceAndDelegateDispatcher Implementation
#pragma mark -

// Ignore warning about missing protocol implementations, these are provided dynamically
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation AKATableViewDataSourceAndDelegateDispatcher

- (instancetype)initWithTableView:(UITableView*)tableView
             dataSourceOverwrites:(id<UITableViewDataSource>)dataSource
               delegateOverwrites:(id<UITableViewDelegate>)delegate
{
    static NSArray<Protocol*>* protocols;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        protocols = @[ @protocol(UITableViewDataSource),
                       @protocol(UITableViewDelegate) ];
    });

    id<UITableViewDataSource> tableViewDataSource = tableView.dataSource;
    id<UITableViewDelegate>   tableViewDelegate = tableView.delegate;
    NSMutableArray* delegates = [NSMutableArray new];

    if (dataSource)
    {
        [delegates addObject:dataSource];
    }

    if (delegate && (id)delegate != (id)dataSource)
    {
        [delegates addObject:delegate];
    }

    if (tableViewDataSource)
    {
        [delegates addObject:tableViewDataSource];
    }

    if (tableViewDelegate && (id)tableViewDelegate != (id)tableViewDataSource)
    {
        [delegates addObject:tableViewDelegate];
    }

    if (self = [super initWithProtocols:protocols
                              delegates:delegates])
    {
        _tableView = tableView;
        tableView.dataSource = self;
        tableView.delegate = self;
        _originalDataSource = tableViewDataSource;
        _originalDelegate = tableViewDelegate;
    }

    return self;
}

- (void)dealloc
{
    [self restoreOriginalDataSourceAndDelegate];
}

- (void)restoreOriginalDataSourceAndDelegate
{
    UITableView* tableView = self.tableView;

    if (tableView)
    {
        tableView.dataSource = self.originalDataSource;
        tableView.delegate = self.originalDelegate;
        _originalDataSource = nil;
        _originalDelegate = nil;
        _tableView = nil;
    }
}

@end
#pragma clang diagnostic pop


#pragma mark - AKABinding_UITableView_dataSourceBinding Private Interface
#pragma mark -

@interface AKABinding_UITableView_dataSourceBinding () <
    UITableViewDataSource,
    UITableViewDelegate,
    AKAArrayPropertyBindingDelegate
    >

#pragma mark - Binding Configuration

@property(nonatomic) NSMutableArray<AKATableViewCellFactory*>*              defaultCellMapping;
@property(nonatomic) NSArray<AKATableViewSectionDataSourceInfo*>*           sections;
@property(nonatomic) UITableViewRowAnimation                                insertAnimation;
@property(nonatomic) UITableViewRowAnimation                                deleteAnimation;

#pragma mark - Observation

@property(nonatomic, readonly) BOOL isObserving;

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

+ (AKABindingSpecification*)            specification
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
            }
        };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

+ (void)registerEnumerationAndOptionTypes
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AKABindingExpressionSpecification registerEnumerationType:@"UITableViewRowAnimation"
                                                  withValuesByName:[AKANSEnumerations
                                                                    uitableViewRowAnimationsByName]];
    });
}

- (instancetype)init
{
    if (self = [super init])
    {
        _pendingTableViewChanges = [NSMutableDictionary new];

        _deleteAnimation = UITableViewRowAnimationAutomatic;
        _insertAnimation = UITableViewRowAnimationAutomatic;
    }
    return self;
}

- (NSArray<AKATableViewSectionDataSourceInfo *> *)sections
{
    return self.syntheticTargetValue;
}

- (BOOL)                                  isObserving
{
    return self.delegateDispatcher != nil;
}

- (void)                             sourceArrayItemAtIndex:(NSUInteger)index
                                         valueDidChangeFrom:(id)oldValue
                                                         to:(id)newValue
{
    [self dispatchTableViewUpdateForSection:index
                         forChangesFromRows:oldValue
                                     toRows:newValue];
    [super sourceArrayItemAtIndex:index valueDidChangeFrom:oldValue to:newValue];
}

- (void)                             targetArrayItemAtIndex:(NSUInteger)index
                                         valueDidChangeFrom:(id)oldValue
                                                         to:(id)newValue
{
    AKATableViewSectionDataSourceInfo* oldSectionInfo = oldValue;
    AKATableViewSectionDataSourceInfo* newSectionInfo = newValue;

    if (oldSectionInfo.rows != newSectionInfo.rows)
    {
        [self dispatchTableViewUpdateForSection:index
                             forChangesFromRows:oldSectionInfo.rows
                                         toRows:newSectionInfo.rows
                     updateTableViewImmediately:YES];
    }
    [super targetArrayItemAtIndex:index valueDidChangeFrom:oldValue to:newValue];
}

- (void)updateTableViewRowHeights
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)dispatchTableViewUpdateForSection:(NSUInteger)section
                       forChangesFromRows:(NSArray*)oldRows
                                   toRows:(NSArray*)newRows
{
    [self dispatchTableViewUpdateForSection:section
                         forChangesFromRows:oldRows
                                     toRows:newRows
                 updateTableViewImmediately:NO];
}

- (void)initializeTableView
{
    if (!self.tableViewReloadDispatched)
    {
        if (self.pendingTableViewChanges.count == 0)
        {
            for (NSUInteger section=0; section < self.sections.count; ++section)
            {
                AKATableViewSectionDataSourceInfo* sectionInfo = self.sections[section];
                NSArray* rows = sectionInfo.rows == (id)[NSNull null] ? nil : sectionInfo.rows;
                self.pendingTableViewChanges[@(section)] =
                    [[AKAArrayComparer alloc] initWithOldArray:@[] newArray:rows];
            }
            [self dispatchTableViewUpdateImmediately:YES];
        }
    }
}

- (void)dispatchTableViewUpdateImmediately:(BOOL)updateTableViewImmediately
{
    __weak typeof(self) weakSelf = self;

    if (!self.tableViewReloadDispatched)
    {
        self.tableViewReloadDispatched = YES;
        void(^update)() = ^{
            typeof(weakSelf) strongSelf = weakSelf;

            [weakSelf.tableView beginUpdates];
            for (NSNumber* sectionN in strongSelf.pendingTableViewChanges.keyEnumerator)
            {
                AKAArrayComparer* pendingChanges = strongSelf.pendingTableViewChanges[sectionN];

                [pendingChanges updateTableView:strongSelf.tableView
                                        section:sectionN.integerValue
                                deleteAnimation:strongSelf.deleteAnimation
                                insertAnimation:strongSelf.insertAnimation];
                [strongSelf.pendingTableViewChanges removeObjectForKey:sectionN];
            }
            [strongSelf.tableView endUpdates];
            strongSelf.tableViewReloadDispatched = NO;

            // Perform update for self-sizing cells now to ensure this will be done, disable
            // deferred updates which have already been scheduled (not necessary if done now).
            [strongSelf updateTableViewRowHeights];
            strongSelf.tableViewUpdateDispatched = NO;
        };

        // We generally want to update the TV in a newly dispatched job, which will allow subsequent
        // changes to binding sources to accumulate updates and perform them in one batch (better animations)
        // But since Cocoa loads the table view in a job scheduled before this code is executed,
        // the TV is already loaded when update() is run and this fails because the TV already is set up
        // for the state of the data source, so we call the update synchronously the first time (or
        // whenever self.updateTableViewSynchronously is YES) and then revert to deferred updates.
        if (updateTableViewImmediately)
        {
            update();
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), update);
        }
    }
}

- (void)dispatchTableViewUpdateForSection:(NSUInteger)section
                       forChangesFromRows:(NSArray*)oldRows
                                   toRows:(NSArray*)newRows
               updateTableViewImmediately:(BOOL)updateTableViewImmediately
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

    // The tableview delegate method cellwilldisappear that also triggers removal of cell controls
    // is not reliably called. To ensure that AKAControls in charge of table view cells will detach
    // observers, we are )also) removing member controls here, because at that point in time, oldRows
    // still holds strong references to data contexts used by these controls.
    //
    id<AKABindingDelegate_UITableView_dataSourceBinding> delegate = self.delegate;
    if (![delegate respondsToSelector:@selector(binding:suspendDynamicBindingsForCell:indexPath:)])
    {
        delegate = nil;
    }
    if (delegate)
    {
        [pendingChanges.deletedItemIndexes enumerateIndexesUsingBlock:
         ^(NSUInteger idx, BOOL * _Nonnull stop)
         {
             NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)idx
                                                         inSection:(NSInteger)section];
             UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
             [delegate               binding:self
               suspendDynamicBindingsForCell:cell
                                   indexPath:indexPath];

         }];
    }

    [self dispatchTableViewUpdateImmediately:updateTableViewImmediately];
}

- (AKAProperty*)    defaultBindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                              context:(req_AKABindingContext)bindingContext
                                       changeObserver:(AKAPropertyChangeObserver)changeObserver
                                                error:(NSError* __autoreleasing _Nullable*)error
{
    (void)bindingExpression;
    (void)bindingContext;
    (void)error;

    return [AKAProperty propertyOfWeakKeyValueTarget:nil keyPath:nil changeObserver:changeObserver];
}

- (AKAProperty*)   createBindingTargetPropertyForView:(req_UIView)view
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

- (UITableView*)                           tableView
{
    return (UITableView*)self.view;
}

- (UITableViewCell*)                        tableView:(UITableView*)tableView
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

- (UITableViewCell*)                        tableView:(UITableView*)tableView
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

- (AKATableViewSectionDataSourceInfo*)      tableView:(UITableView*)tableView
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

- (NSInteger)             numberOfSectionsInTableView:(UITableView*)tableView
{
    (void)tableView;
    NSAssert(tableView == self.tableView,
             @"numberOfSectionsInTableView: Invalid tableView, expected binding target tableViw");

    return (NSInteger)self.sections.count;
}

- (NSInteger)                               tableView:(UITableView*)tableView
                                numberOfRowsInSection:(NSInteger)section
{
    NSAssert(tableView == self.tableView,
             @"tableView:numberOfRowsInSection: Invalid tableView, expected binding targettableView");

    return (NSInteger)[self tableView:tableView infoForSection:section].rows.count;
}

- (UITableViewCell*)                        tableView:(UITableView*)tableView
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

- (NSString*)                              tableView:(UITableView*)tableView
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

- (NSString*)                              tableView:(UITableView*)tableView
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)                                    tableView:(UITableView*)tableView
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

- (void)                                    tableView:(UITableView*)tableView
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

@end
