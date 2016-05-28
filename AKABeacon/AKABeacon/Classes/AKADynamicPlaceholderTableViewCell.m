//
//  AKADynamicPlaceholderTableViewCell.m
//  AKABeacon
//
//  Created by Michael Utech on 29.04.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

#import "AKAErrors.h"
#import "NSObject+AKAAssociatedValues.h"
#import "UIView+AKAHierarchyVisitor.h"
#import "AKATVMultiplexedDataSource.h"
#import "AKALog.h"

#import "AKADynamicPlaceholderTableViewCell.h"

#import "AKAViewBinding+IBPropertySupport.h"
#import "AKADynamicPlaceholderTableViewCellCompositeControl.h"
#import "AKAControl_Internal.h"
#import "AKABinding.h"

@implementation AKADynamicPlaceholderTableViewCell

#pragma mark - Interface Builder Properties

- (NSString*)collectionBinding
{
    return [AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding bindingExpressionTextForSelector:@selector(collectionBinding)
                                                                                                      inView:self];
}

- (void)setCollectionBinding:(NSString*)collectionBinding
{
    [AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding setBindingExpressionText:collectionBinding
                                                                                  forSelector:@selector(collectionBinding)
                                                                                       inView:self];
}

#pragma mark - Control Configuration

- (AKAMutableControlConfiguration*)aka_controlConfiguration
{
    NSString* key = NSStringFromSelector(@selector(aka_controlConfiguration));
    AKAMutableControlConfiguration* result = [self aka_associatedValueForKey:key];

    if (result == nil)
    {
        result = [AKAMutableControlConfiguration new];
        result[kAKAControlTypeKey] = [AKADynamicPlaceholderTableViewCellCompositeControl class];
        result[kAKAControlViewBinding] = NSStringFromSelector(@selector(collectionBinding));
        [self aka_setAssociatedValue:result forKey:key];
    }

    return result;
}

- (void)aka_setControlConfigurationValue:(id)value forKey:(NSString*)key
{
    AKAMutableControlConfiguration* mutableConfiguration = (AKAMutableControlConfiguration*)self.aka_controlConfiguration;

    if (value == nil)
    {
        [mutableConfiguration removeObjectForKey:key];
    }
    else
    {
        mutableConfiguration[key] = value;
    }
}

#pragma mark - Content Rendering

- (void)renderItem:(id)item
{
    // TODO: remove this method or better refactor the whole thing
    (void)item;
    AKAErrorAbstractMethodImplementationMissing();
}

@end


@interface AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding()

@property(nonatomic, readonly) NSArray* actualItems;

@end

@implementation AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding

+ (AKABindingSpecification*)specification
{
    static AKABindingSpecification* result;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":          [AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding class],
           @"targetType":           [AKADynamicPlaceholderTableViewCell class],
           @"expressionType":       @(AKABindingExpressionTypeAnyKeyPath),
           @"attributes":
               @{ @"dataSource":
                      @{ @"expressionType":  @(AKABindingExpressionTypeAnyKeyPath),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"placeholderDataSource" },
                  @"delegate":
                      @{ @"expressionType":  @(AKABindingExpressionTypeAnyKeyPath),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"placeholderDelegate" },
                  @"section":
                      @{ @"expressionType":  @(AKABindingExpressionTypeInteger),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"dataSourceSectionIndex" },
                  @"firstRow":
                      @{ @"expressionType":  @(AKABindingExpressionTypeInteger),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"dataSourceRowIndex" },
                  @"numberOfRows":
                      @{ @"expressionType":  @(AKABindingExpressionTypeInteger),
                         @"use":             @(AKABindingAttributeUseAssignValueToBindingProperty),
                         @"bindingProperty": @"dataSourceNumberOfRows" }, }
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });
    
    return result;
}

#pragma mark - Initialization

- (void)validateTarget:(req_id)target
{
    (void)target;
    NSParameterAssert([target isKindOfClass:[AKADynamicPlaceholderTableViewCell class]]);
}

#pragma mark - Binding Target

- (req_AKAProperty)createBindingTargetPropertyForTarget:(req_id)view
{
    (void)view;
    NSParameterAssert(view == nil || [view isKindOfClass:[AKADynamicPlaceholderTableViewCell class]]);

    AKAProperty* result =
        [AKAProperty propertyOfWeakTarget:self
                                   getter:
         ^opt_id (req_id target)
         {
             AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding* binding = target;
             return binding.actualItems;
         }
                                   setter:
         ^(req_id target, opt_id value)
         {
             (void)value;
             // TODO: see if setting the viewvalue can somehow be meaningfully implemented

             AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding* binding = target;
             //binding->_actualItems = value;
             [binding updateDynamicRows];
         }
                       observationStarter:^BOOL (req_id target)
         {
             AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding* binding = target;
             return [binding updateDynamicRows];
         }
                       observationStopper:
         ^BOOL (req_id target)
         {
             (void)target;
             return NO;
         }];
    return result;
}

#pragma mark - Properties

- (AKADynamicPlaceholderTableViewCell *)placeholderCell
{
    UIView* result = self.view;
    NSParameterAssert(result == nil || [result isKindOfClass:[AKADynamicPlaceholderTableViewCell class]]);

    return (AKADynamicPlaceholderTableViewCell*)result;
}

#pragma mark - Hacks, needs refactoring and cleanup

- (BOOL)               updateDynamicRows
{
    AKATVDataSourceSpecification* defaultDS = self.placeholderOriginDataSourceSpecification;


    NSIndexPath* targetIndexPath = [defaultDS tableViewMappedIndexPath:self.placeholderIndexPath];
    BOOL result = (targetIndexPath != nil);

    NSArray* items = self.bindingSource.value;
    if ([items isKindOfClass:[NSSet class]])
    {
        items = [((NSSet*)items) allObjects];
    }
    if (items == nil)
    {
        items = @[];
    }

    NSMutableArray* deferredReloadIndexes = NSMutableArray.new;

    [self sourceControllerWillChangeContent:self.bindingSource];

    NSInteger placeholderContentSection = 0;

    // Remove items no longer in new items collection
    NSMutableArray* oldItems = nil;

    if (self.actualItems.count > 0)
    {
        oldItems = [NSMutableArray arrayWithArray:self.actualItems];
        _actualItems = oldItems;
        for (NSInteger i = (NSInteger)oldItems.count - 1; i >= 0; --i)
        {
            id oldItem = oldItems[(NSUInteger)i];

            if ([items indexOfObject:oldItem] == NSNotFound)
            {
                [oldItems removeObjectAtIndex:(NSUInteger)i];

                NSIndexPath* oldItemIndexPath = [NSIndexPath indexPathForRow:i
                                                                   inSection:placeholderContentSection];
                [self  sourceController:self.bindingSource
                            deletedItem:oldItem
                            atIndexPath:oldItemIndexPath];
            }
        }
    }
    else
    {
        oldItems = NSMutableArray.new;
    }

    // Process insertions and movements
    NSUInteger insertedItemCount = 0;

    for (NSInteger i = 0; i < ((NSArray*)items).count; ++i)
    {
        id item = ((NSArray*)items)[(NSUInteger)i];
        NSUInteger oldIndex = [oldItems indexOfObject:item];

        NSIndexPath* itemIndexPath = [NSIndexPath indexPathForRow:i
                                                        inSection:placeholderContentSection];
        // TODO: consider manipulating oldItems to match changes
        if (oldIndex == NSNotFound)
        {
            [self      sourceController:self.bindingSource
                           insertedItem:item
                            atIndexPath:itemIndexPath];
            ++insertedItemCount;
        }
        else if (oldIndex + insertedItemCount != i)
        {
            NSAssert(oldIndex + insertedItemCount > i, @"");

            [oldItems removeObjectAtIndex:oldIndex];

            NSIndexPath* itemOldIndexPath =
                [NSIndexPath indexPathForRow:(NSInteger)(oldIndex + insertedItemCount)
                                   inSection:placeholderContentSection];

            [self      sourceController:self.bindingSource
                              movedItem:item
                          fromIndexPath:itemOldIndexPath
                            toIndexPath:itemIndexPath];
            ++insertedItemCount;
        }
        else
        {
            // Assume a content change for non-inserted/deleted/moved items

            // TODO: Both deferred and immediate reload mess up table view animations display, see what can be done about that

            //[deferredReloadIndexes addObject:itemIndexPath];

            //[self      sourceController:self.bindingSource
            //                updatedItem:items[(NSUInteger)itemIndexPath.row]
            //                atIndexPath:itemIndexPath];
        }
    }
    _actualItems = items;

    [self sourceControllerDidChangeContent:self.bindingSource];

    if (deferredReloadIndexes.count > 0)
    {
        for (NSIndexPath* itemIndexPath in deferredReloadIndexes)
        {
            [self      sourceController:self.bindingSource
                            updatedItem:items[(NSUInteger)itemIndexPath.row]
                            atIndexPath:itemIndexPath];
        }
    }

    return result;
}


- (NSIndexPath*)targetIndexPathForSourceIndexPath:(NSIndexPath*)sourceIndexPath
{
    AKATVDataSourceSpecification* defaultDS = self.placeholderOriginDataSourceSpecification;
    return [defaultDS tableViewMappedIndexPath:sourceIndexPath];
}

- (void)                   sourceControllerWillChangeContent:(req_id)sourceDataController
{
    (void)sourceDataController;

    [self.multiplexer beginUpdates];
}

- (void)                                    sourceController:(req_id)sourceDataController
                                                insertedItem:(opt_id)sourceCollectionItem
                                                 atIndexPath:(req_NSIndexPath)indexPath
{
    NSParameterAssert(indexPath != nil);
    NSParameterAssert(indexPath.section == 0 && indexPath.row >= 0 && indexPath.row != NSNotFound);

    if ([self.delegate respondsToSelector:@selector(binding:sourceController:insertedItem:atIndexPath:)])
    {
        [self.delegate binding:self sourceController:sourceDataController insertedItem:sourceCollectionItem atIndexPath:indexPath];
    }

    NSIndexPath* placeholderTargetIndexPath =
    [self targetIndexPathForSourceIndexPath:self.placeholderIndexPath];

    if (placeholderTargetIndexPath)
    {
        NSString*    key = self.multiplexedDataSourceKey;

        NSIndexPath* targetIndexPath =
        [NSIndexPath indexPathForRow:indexPath.row + placeholderTargetIndexPath.row
                           inSection:placeholderTargetIndexPath.section];

        AKATVMultiplexedDataSource* multiplexer = self.multiplexer;

        // Order is relevant, data source index paths have to be updated for insertion before
        // the new row is inserted
        [multiplexer dataSourceWithKey:key insertedRowAtIndexPath:indexPath];

        // TODO: honor dynamic placeholder configuration (number of rows, etc.) and only insert
        // if row is not excluded
        [multiplexer insertRowsFromDataSource:key
                              sourceIndexPath:indexPath
                                        count:1
                                  atIndexPath:targetIndexPath
                             withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)                                    sourceController:(req_id)sourceDataController
                                                 deletedItem:(opt_id)sourceCollectionItem
                                                 atIndexPath:(req_NSIndexPath)indexPath
{
    NSParameterAssert(indexPath != nil);
    NSParameterAssert(indexPath.section == 0 && indexPath.row >= 0 && indexPath.row != NSNotFound);

    if ([self.delegate respondsToSelector:@selector(binding:sourceController:deletedItem:atIndexPath:)])
    {
        [self.delegate binding:self sourceController:sourceDataController deletedItem:sourceCollectionItem atIndexPath:indexPath];
    }

    NSIndexPath* placeholderTargetIndexPath =
        [self targetIndexPathForSourceIndexPath:self.placeholderIndexPath];

    AKATVMultiplexedDataSource* multiplexer = self.multiplexer;

    if (placeholderTargetIndexPath != nil)
    {
        NSIndexPath* targetIndexPath =
        [NSIndexPath indexPathForRow:indexPath.row + placeholderTargetIndexPath.row
                           inSection:placeholderTargetIndexPath.section];

        [multiplexer removeUpTo:1
                   rowsFromIndexPath:targetIndexPath
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    // Order is relevant, row has to be removed before data source index paths get updated:
    NSString*    key = self.multiplexedDataSourceKey;
    [multiplexer dataSourceWithKey:key removedRowAtIndexPath:indexPath];
}

- (void)                                    sourceController:(req_id)sourceDataController
                                                 updatedItem:(opt_id)sourceCollectionItem
                                                 atIndexPath:(req_NSIndexPath)indexPath
{
    NSParameterAssert(indexPath != nil);
    NSParameterAssert(indexPath.section == 0 && indexPath.row >= 0 && indexPath.row != NSNotFound);

    if ([self.delegate respondsToSelector:@selector(binding:sourceController:updatedItem:atIndexPath:)])
    {
        [self.delegate binding:self sourceController:sourceDataController updatedItem:sourceCollectionItem atIndexPath:indexPath];
    }

    NSIndexPath* placeholderTargetIndexPath =
    [self targetIndexPathForSourceIndexPath:self.placeholderIndexPath];

    if (placeholderTargetIndexPath)
    {
        NSIndexPath* targetIndexPath =
        [NSIndexPath indexPathForRow:indexPath.row + placeholderTargetIndexPath.row
                           inSection:placeholderTargetIndexPath.section];

        [self.multiplexer reloadRowsAtIndexPaths:@[ targetIndexPath ]
                                withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)                                    sourceController:(req_id)sourceDataController
                                                   movedItem:(opt_id)sourceCollectionItem
                                               fromIndexPath:(req_NSIndexPath)fromIndexPath
                                                 toIndexPath:(req_NSIndexPath)toIndexPath
{
    NSParameterAssert(fromIndexPath != nil && toIndexPath != nil);
    NSParameterAssert(fromIndexPath.section == 0 && toIndexPath.section == 0);
    NSParameterAssert(fromIndexPath.row >= 0 && fromIndexPath.row != NSNotFound);
    NSParameterAssert(toIndexPath.row >= 0 && toIndexPath.row != NSNotFound);

    if ([self.delegate respondsToSelector:@selector(binding:sourceController:movedItem:fromIndexPath:toIndexPath:)])
    {
        [self.delegate binding:self sourceController:sourceDataController movedItem:sourceCollectionItem fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }

    AKATVDataSourceSpecification* defaultDS = self.placeholderOriginDataSourceSpecification;

    NSIndexPath* placeholderTargetIndexPath =
        [defaultDS tableViewMappedIndexPath:self.placeholderIndexPath];

    if (placeholderTargetIndexPath)
    {
        NSIndexPath* fromTargetIndexPath =
        [NSIndexPath indexPathForRow:fromIndexPath.row + placeholderTargetIndexPath.row
                           inSection:placeholderTargetIndexPath.section];
        NSIndexPath* toTargetIndexPath =
        [NSIndexPath indexPathForRow:toIndexPath.row + placeholderTargetIndexPath.row
                           inSection:placeholderTargetIndexPath.section];

        [self.multiplexer rowAtIndexPath:fromTargetIndexPath
                      didMoveToIndexPath:toTargetIndexPath];
    }
}

- (void)                    sourceControllerDidChangeContent:(req_id)sourceDataController
{
    if ([self.delegate respondsToSelector:@selector(binding:sourceControllerDidChangeContent:)])
    {
        [self.delegate binding:self sourceControllerDidChangeContent:sourceDataController];
    }

    [self.multiplexer endUpdates];
}

@end
