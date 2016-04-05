//
//  AKADynamicPlaceholderTableViewCellCompositeControl.m
//  AKABeacon
//
//  Created by Michael Utech on 05.09.15.
//  Copyright (c) 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAAssociatedValues;
@import AKACommons.AKALog;

#import "AKADynamicPlaceholderTableViewCellCompositeControl.h"
#import "AKADynamicPlaceholderTableViewCell.h"
#import "AKACompositeControl+BindingDelegatePropagation.h"
#import "AKABindingExpression+Accessors.h"

#import "AKAControl_Internal.h" // TODO: expose constructors and remove this import


@implementation AKADynamicPlaceholderTableViewCellCompositeControl

#pragma mark - Configuration

- (NSUInteger)autoAddControlsForControlViewSubviewsInViewHierarchy:(UIView *)controlView
                                                      excludeViews:(NSArray * _Nullable)childControllerViews
{
    // Do not automatically add controls in the cells contentView hierarchy, because
    // this is only a placeholder (prototype) cell. Adding controlls will be done
    // (dynamically) when the placeholder is connected to its data source.
    (void)controlView;
    (void)childControllerViews;
    return 0;
}

// TODO: pull up to AKACollectionControl once implemented:
#pragma mark - Bindings Owner

- (AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding *)collectionBinding
{
    AKAControlViewBinding* result = self.controlViewBinding;
    
    NSParameterAssert(result == nil || [result isKindOfClass:[AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding class]]);

    return (AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding*)result;
}

@end


@interface AKADynamicPlaceholderTableViewCellCompositeControl(CollectionControlViewBindingDelegate)<AKACollectionControlViewBindingDelegate>
@end


@implementation AKADynamicPlaceholderTableViewCellCompositeControl(CollectionControlViewBindingDelegate)

- (NSUInteger)                  indexForBinding:(req_AKACollectionControlViewBinding)binding
                                    atIndexPath:(req_NSIndexPath)indexPath
{
    (void)binding;

    NSInteger result = indexPath.row;
    NSParameterAssert(result >= 0 && result <= self.countOfControls);

    return (NSUInteger)((result >= 0 && result <= self.countOfControls) ? result : NSNotFound);
}

- (AKACompositeControl*)       memberForBinding:(req_AKACollectionControlViewBinding)binding
                                           item:(opt_id)sourceCollectionItem
                                    atIndexPath:(req_NSIndexPath)indexPath
                                    memberIndex:(NSUInteger* _Nullable)indexStorage
{
    (void)sourceCollectionItem;

    NSUInteger index =
        [self indexForBinding:binding atIndexPath:indexPath];

    AKAControl* control = [self objectInControlsAtIndex:index];
    NSAssert([control isKindOfClass:[AKACompositeControl class]],
             @"Invalid member control %@, expected an instance of AKACompositeControl", control);

    AKACompositeControl* member = (AKACompositeControl*)control;
    id dataContext = member.dataContext;
    if (sourceCollectionItem == dataContext)
    {
        AKALogError(@"Member %@ at index %lu for indexPath %@ does not refer to %@ as data context, "
                    @"found %@ instead",
                    member, (unsigned long)index, indexPath, sourceCollectionItem, dataContext);
    }
    (void)dataContext;

    if (indexStorage != nil)
    {
        *indexStorage = index;
    }
    return member;
}

- (void)                                binding:(req_AKACollectionControlViewBinding)binding
              sourceControllerWillChangeContent:(req_id)sourceDataController
{
    [self.owner control:self binding:binding sourceControllerWillChangeContent:sourceDataController];
}

- (void)                                binding:(req_AKACollectionControlViewBinding)binding
                               sourceController:(req_id)sourceDataController
                                      movedItem:(opt_id)sourceCollectionItem
                                  fromIndexPath:(req_NSIndexPath)fromIndexPath
                                    toIndexPath:(req_NSIndexPath)toIndexPath
{
    NSUInteger fromIndex = NSNotFound;
    AKACompositeControl* member = [self memberForBinding:binding
                                                    item:sourceCollectionItem
                                             atIndexPath:fromIndexPath
                                             memberIndex:&fromIndex];
    NSAssert(member != nil, @"Failed to locate member control for collection item %@ at index path %@", sourceCollectionItem, fromIndexPath);
    if (member)
    {
        NSUInteger toIndex =
            [self indexForBinding:binding atIndexPath:fromIndexPath];

        [self moveControlFromIndex:fromIndex toIndex:toIndex];
    }

    [self.owner control:self binding:binding sourceController:sourceDataController movedItem:sourceCollectionItem fromIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

- (void)                                binding:(req_AKACollectionControlViewBinding)binding
                               sourceController:(req_id)sourceDataController
                                   insertedItem:(opt_id)sourceCollectionItem
                                    atIndexPath:(req_NSIndexPath)indexPath
{
    NSUInteger index = [self indexForBinding:binding atIndexPath:indexPath];

    AKACompositeControl* composite = [[AKACompositeControl alloc] initWithDataContext:sourceCollectionItem configuration:nil];
    // keep a strong reference to the item
    [composite aka_setAssociatedValue:sourceCollectionItem forKey:@"data_item"];

    [self insertControl:composite atIndex:index];

    [self.owner control:self binding:binding sourceController:sourceDataController insertedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                binding:(req_AKACollectionControlViewBinding)binding
                               sourceController:(req_id)sourceDataController
                                    updatedItem:(opt_id)sourceCollectionItem
                                    atIndexPath:(req_NSIndexPath)indexPath
{
    [self.owner control:self binding:binding sourceController:sourceDataController updatedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                binding:(req_AKACollectionControlViewBinding)binding
                               sourceController:(req_id)sourceDataController
                                    deletedItem:(opt_id)sourceCollectionItem
                                    atIndexPath:(req_NSIndexPath)indexPath
{
    NSUInteger index = NSNotFound;
    AKACompositeControl* member = [self memberForBinding:binding
                                                    item:sourceCollectionItem
                                             atIndexPath:indexPath
                                             memberIndex:&index];
    NSAssert(member != nil && index != NSNotFound, @"Failed to locate member control for deleted collection item %@ at index path %@", sourceCollectionItem, indexPath);
    if (member)
    {
        [self removeControl:member];
    }

    [self.owner control:self binding:binding sourceController:sourceDataController deletedItem:sourceCollectionItem atIndexPath:indexPath];
}

- (void)                                binding:(req_AKACollectionControlViewBinding)binding
               sourceControllerDidChangeContent:(req_id)sourceDataController
{
    [self.owner control:self binding:binding sourceControllerDidChangeContent:sourceDataController];
}

@end

@implementation AKADynamicPlaceholderTableViewCellCompositeControl(UITableViewDataSourceAndDelegate)


#pragma mark - UITableViewDataSource Implementation


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    (void)tableView;

    return 1;
}

- (NSInteger)           tableView:(UITableView*)tableView
            numberOfRowsInSection:(NSInteger)section
{
    (void)tableView;
    (void)section;
    NSParameterAssert(section == 0);

    return (NSInteger)[self countOfControls];
}

- (UITableViewCell*)   tableView:(UITableView*)tableView
           cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    (void)tableView;

    NSAssert(indexPath.row >= 0, nil);
    AKACompositeControl* memberControl = [self objectInControlsAtIndex:(NSUInteger)indexPath.row];

    UITableViewCell* result = [memberControl aka_associatedValueForKey:@"strongCellReference"];

    AKABinding_AKADynamicPlaceholderTableViewCell_collectionBinding* collectionBinding = self.collectionBinding;

    if (result == nil)
    {
        opt_NSString reuseIdentifier = collectionBinding.placeholderCell.reuseIdentifier;

        if (reuseIdentifier.length > 0)
        {
            result = [tableView dequeueReusableCellWithIdentifier:(req_NSString)reuseIdentifier];
        }

        if (result == nil)
        {
            // TODO: this is probably not a good idea, however I didn't find a better way yet to use the
            // placeholder cell as a prototype for instances.
            NSData* archived = [NSKeyedArchiver archivedDataWithRootObject:collectionBinding.placeholderCell];
            result = [NSKeyedUnarchiver unarchiveObjectWithData:archived];

            [self copyBindingExpressionsAndControlConfigurationFromView:collectionBinding.placeholderCell.contentView
                                          toView:result.contentView
                                     recursively:YES];

            //AKALogDebug(@"Cloned placeholder cell %@ for row at index path %@: %@", self.placeholderCell, indexPath, result);
            [memberControl aka_setAssociatedValue:result forKey:@"strongCellReference"];
        }

        if ([result isKindOfClass:[AKADynamicPlaceholderTableViewCell class]])
        {
            memberControl.view = result;
            // TODO: get exclusion views from delegate?
            [memberControl addControlsForControlViewsInViewHierarchy:result.contentView
                                                        excludeViews:[AKACompositeControl viewsToExcludeFromScanningViewController:nil]];
            [memberControl startObservingChanges];
        }
    }

    return result;
}

- (void)copyBindingExpressionsAndControlConfigurationFromView:(UIView*)prototype
                                toView:(UIView*)view
                           recursively:(BOOL)recursively
{
    [AKABindingExpression enumerateBindingExpressionsForTarget:prototype
                                                     withBlock:
     ^(SEL  _Nonnull property, req_AKABindingExpression expression, BOOL * _Nonnull stop)
     {
         (void)stop;
         if (![AKABindingExpression bindingExpressionForTarget:view property:property])
         {
             [AKABindingExpression setBindingExpression:expression forTarget:view property:property];
         }
     }];

    if ([prototype conformsToProtocol:@protocol(AKAControlViewProtocol)] &&
        [view conformsToProtocol:@protocol(AKAControlViewProtocol)])
    {
        UIView<AKAControlViewProtocol>* cvPrototype = (id)prototype;
        UIView<AKAControlViewProtocol>* cvView = (id)view;
        [cvPrototype.aka_controlConfiguration enumerateKeysAndObjectsUsingBlock:
         ^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop)
         {
             (void)stop;
             if (!cvView.aka_controlConfiguration[key])
             {
                 [cvView aka_setControlConfigurationValue:obj forKey:key];
             }
         }];
    }
    if (recursively)
    {
        NSParameterAssert(prototype.subviews.count == view.subviews.count);
        for (NSUInteger i = 0; i < prototype.subviews.count; ++i)
        {
            [self copyBindingExpressionsAndControlConfigurationFromView:prototype.subviews[i]
                                                                 toView:view.subviews[i]
                                                            recursively:recursively];
        }
    }
}

#pragma mark - UITableViewDelegate Implementation

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Override static table view controller implementation for dynamic row height
    (void)tableView;
    (void)indexPath;

    return 44.0;
}

- (CGFloat)             tableView:tableView
          heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Override static table view controller implementation for dynamic row height
    (void)tableView;
    (void)indexPath;

    return UITableViewAutomaticDimension;
}

- (CGFloat)             tableView:(UITableView*)tableView
         heightForHeaderInSection:(NSInteger)section
{
    // Override static table view controller implementation for dynamic row height
    (void)tableView;
    (void)section;

    return UITableViewAutomaticDimension;
}

- (CGFloat)             tableView:(UITableView*)tableView
         heightForFooterInSection:(NSInteger)section
{
    // Override static table view controller implementation for dynamic row height
    (void)tableView;
    (void)section;

    return UITableViewAutomaticDimension;
}

- (NSIndexPath*)       tableView:(UITableView*)tableView
        willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    (void)tableView;

    return indexPath;
}

@end
