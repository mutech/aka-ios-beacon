//
//  AKABinding_UITableView_dataSourceBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 03.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKABinding_UITableView_dataSourceBinding.h"
#import "AKATableViewCellFactoryArrayPropertyBinding.h"
#import "AKATableViewCellFactory.h"
#import "AKAPredicatePropertyBinding.h"
#import "AKADelegateDispatcher.h"
#import "AKABindingErrors.h"

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


@class AKATableViewSectionDataSourceInfoPropertyBinding;
@protocol AKATableViewSectionDataSourceInfoPropertyBindingDelegate <AKABindingDelegate>

- (void)                     binding:(AKATableViewSectionDataSourceInfoPropertyBinding*)binding
            dataSourceInfoForSection:(NSUInteger)section
                     rowsDidChangeTo:(NSArray*)newRows;

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

- (void)                binding:(AKAArrayPropertyBinding*)binding
         sourceArrayItemAtIndex:(NSUInteger)arrayItemIndex
                          value:(id)oldValue
                    didChangeTo:(id)newValue
{
    (void)binding; // not used
    (void)oldValue; // not used

    if ([self.delegate conformsToProtocol:@protocol(AKATableViewSectionDataSourceInfoPropertyBindingDelegate)])
    {
        id<AKATableViewSectionDataSourceInfoPropertyBindingDelegate> delegate = (id)self.delegate;

        if ([delegate respondsToSelector:@selector(binding:dataSourceInfoForSection:rowsDidChangeTo:)])
        {
            [delegate binding:self dataSourceInfoForSection:arrayItemIndex rowsDidChangeTo:[newValue rows]];
        }
    }
}

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
    AKATableViewSectionDataSourceInfoPropertyBindingDelegate,
    AKAArrayPropertyBindingDelegate
    >
@property(nonatomic, readonly) BOOL isObserving;
@property(nonatomic, readonly) UITableView*                                 tableView;
@property(nonatomic, readonly) AKATableViewDataSourceAndDelegateDispatcher* delegateDispatcher;
@property(nonatomic) NSMutableArray<AKATableViewCellFactory*>*              defaultCellMapping;
@property(nonatomic) NSArray<AKATableViewSectionDataSourceInfo*>*           sections;

@end


#pragma mark - AKABinding_UITableView_dataSourceBinding Implementation
#pragma mark -

@implementation AKABinding_UITableView_dataSourceBinding

@dynamic delegate;

+ (AKABindingSpecification*)            specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec = @{
            @"bindingType":          [AKABinding_UITableView_dataSourceBinding class],
            @"targetType":           [UITableView class],
            @"expressionType":       @(AKABindingExpressionTypeNone),
            @"attributes":           @{
                @"sections":             @{
                    @"bindingType":          [AKAArrayPropertyBinding class],
                    @"arrayItemBindingType": [AKATableViewSectionDataSourceInfoPropertyBinding class],
                    @"use":                  @(AKABindingAttributeUseBindToBindingProperty)
                },
                @"defaultCellMapping":   @{
                    @"bindingType":          [AKATableViewCellFactoryArrayPropertyBinding class],
                    @"use":                  @(AKABindingAttributeUseBindToBindingProperty)
                },
            }
        };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

- (BOOL)                                  isObserving
{
    return self.delegateDispatcher != nil;
}

- (void)binding:(AKATableViewSectionDataSourceInfoPropertyBinding*)binding dataSourceInfoForSection:(NSUInteger)section rowsDidChangeTo:(NSArray*)newRows
{
    (void)binding;
    (void)section;
    (void)newRows;

    [self reloadTableViewData];
}

- (void)binding:(AKAArrayPropertyBinding*)binding sourceArrayItemAtIndex:(NSUInteger)arrayItemIndex value:(id)oldValue didChangeTo:(id)newValue
{
    (void)binding;
    (void)arrayItemIndex;
    (void)oldValue;
    (void)newValue;
    [self reloadTableViewData];
}

- (void)                          reloadTableViewData
{
    // TODO: change management, also remember possibly invalid selections
    [self.tableView reloadData];
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

                if (binding.delegateDispatcher == nil)
                {
                    binding->_delegateDispatcher = [[AKATableViewDataSourceAndDelegateDispatcher alloc] initWithTableView:binding.tableView
                                                                                                     dataSourceOverwrites:binding
                                                                                                       delegateOverwrites:binding];
                    // TODO: deselect currently selected rows, may save them
                    [binding.tableView reloadData];
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

                    // TODO: deselect currently selected rows, maybe restore previously selected
                    [binding.tableView reloadData];
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
             @"Invalid tableView %@, expected binding target %@", tableView, self.tableView);

    return (NSInteger)self.sections.count;
}

- (NSInteger)                               tableView:(UITableView*)tableView
                                numberOfRowsInSection:(NSInteger)section
{
    NSAssert(tableView == self.tableView,
             @"Invalid tableView %@, expected binding target %@", tableView, self.tableView);

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
