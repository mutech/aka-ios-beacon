//
//  AKATableViewSectionDataSourceInfo.m
//  AKABeacon
//
//  Created by Michael Utech on 21.02.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import CoreData;

@import AKACommons.AKAArrayComparer;
#import "AKADelegateDispatcher.h"
#import "AKATableViewSectionDataSourceInfo.h"

@interface AKAFetchedResultsControllerDelegateDispatcher: AKADelegateDispatcher<NSFetchedResultsControllerDelegate>

- (instancetype)initWithOriginalDelegate:(id<NSFetchedResultsControllerDelegate>)originalDelegate
                      overridingDelegate:(id<NSFetchedResultsControllerDelegate>)delegate;

@property(nonatomic) id<NSFetchedResultsControllerDelegate> originalDelegate;
@property(nonatomic) id<NSFetchedResultsControllerDelegate> overridingDelegate;

@end

@implementation AKAFetchedResultsControllerDelegateDispatcher

- (instancetype)initWithOriginalDelegate:(id<NSFetchedResultsControllerDelegate>)originalDelegate
                      overridingDelegate:(id<NSFetchedResultsControllerDelegate>)delegate
{
    if (self = [self initWithProtocols:@[ @protocol(NSFetchedResultsControllerDelegate) ]
                         delegates:@[ delegate, originalDelegate ]])
    {
        self.originalDelegate = originalDelegate;
        self.overridingDelegate = delegate;
    }
    return self;
}

@end

@interface AKATableViewSectionDataSourceInfo() <NSFetchedResultsControllerDelegate>

@property(nonatomic) AKAFetchedResultsControllerDelegateDispatcher* fetchedResultsControllerDelegateDispatcher;

@end


#pragma mark - AKATableViewSectionDataSourceInfo Implementation
#pragma mark -

@implementation AKATableViewSectionDataSourceInfo

- (void)dealloc
{
    [self stopObservingChanges];
}

- (BOOL)usesFetchedResultsController
{
    return [self.rowsSource isKindOfClass:[NSFetchedResultsController class]];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    return (self.usesFetchedResultsController
            ? self.rowsSource
            : nil);
}

- (NSArray *)rows
{
    return (self.usesFetchedResultsController
            ? self.fetchedResultsController.fetchedObjects
            : self.rowsSource);
}

- (void)setRowsSource:(id)rowsSource
{
    NSParameterAssert(rowsSource == nil
                      || [rowsSource isKindOfClass:[NSArray class]]
                      || [rowsSource isKindOfClass:[NSFetchedResultsController class]]);

    if (rowsSource != _rowsSource)
    {
        [self stopObservingChanges];
        _rowsSource = rowsSource;
    }

    id<AKATableViewSectionDataSourceInfoDelegate> delegate = self.delegate;
    if (delegate)
    {
        [self startObservingChanges];
    }
}

- (void)setDelegate:(id<AKATableViewSectionDataSourceInfoDelegate>)delegate
{
    id<AKATableViewSectionDataSourceInfoDelegate> current = self.delegate;
    if (delegate != current)
    {
        _delegate = delegate;
    }

    if (delegate)
    {
        [self startObservingChanges];
    }
    else
    {
        [self stopObservingChanges];
    }
}

- (void)startObservingChanges
{
    NSFetchedResultsController* controller = self.fetchedResultsController;
    if (controller)
    {
        if (controller.delegate == nil)
        {
            controller.delegate = self;
        }
        else if (controller.delegate != self.fetchedResultsControllerDelegateDispatcher
                 && controller.delegate != self)
        {
            self.fetchedResultsControllerDelegateDispatcher = [[AKAFetchedResultsControllerDelegateDispatcher alloc] initWithOriginalDelegate:controller.delegate overridingDelegate:self];
            controller.delegate = self.fetchedResultsControllerDelegateDispatcher;
        }
    }
}

- (void)stopObservingChanges
{
    NSFetchedResultsController* controller = self.fetchedResultsController;
    if (controller)
    {
        if (controller.delegate == self.fetchedResultsControllerDelegateDispatcher)
        {
            controller.delegate = self.fetchedResultsControllerDelegateDispatcher.originalDelegate;
            self.fetchedResultsControllerDelegateDispatcher = nil;
        }
        else if (controller.delegate == self)
        {
            controller.delegate = nil;
        }
    }
}

- (BOOL)isObservingChanges
{
    BOOL result = NO;
    NSFetchedResultsController* controller = self.fetchedResultsController;
    if (controller)
    {
        result = controller.delegate == self || (controller.delegate == self.fetchedResultsControllerDelegateDispatcher
                                                 && controller.delegate);
    }
    return result;
}

- (BOOL)willSendDelegateChangeNotifications
{
    return [self isObservingChanges];
}

#pragma mark - ArrayComparer Support

- (void)generateChangeNotificationsForOldRows:(NSArray*)oldRows
{
    id<AKATableViewSectionDataSourceInfoDelegate> delegate = self.delegate;

    if (delegate)
    {
        AKAArrayComparer* arrayComparer = [[AKAArrayComparer alloc] initWithOldArray:oldRows
                                                                            newArray:self.rows];
        
        if ([delegate respondsToSelector:@selector(sectionInfoWillChangeContent:)])
        {
            [delegate sectionInfoWillChangeContent:self];
        }

        if ([delegate respondsToSelector:@selector(sectionInfo:didDeleteObject:atRowIndex:)])
        {
            // Deletions
            [arrayComparer.deletedItemIndexes enumerateIndexesWithOptions:NSEnumerationReverse
                                                               usingBlock:
             ^(NSUInteger idx, BOOL * _Nonnull __unused stop)
             {
                 [delegate sectionInfo:self
                       didDeleteObject:oldRows[idx]
                            atRowIndex:(NSInteger)idx];
             }];
        }

        if ([delegate respondsToSelector:@selector(sectionInfo:didMoveObject:fromRowIndex:toRowIndex:)])
        {
            // Movements
            NSArray* permutation = arrayComparer.movementsForTableViews;
            for (NSUInteger targetIndex=0;
                 targetIndex < permutation.count;
                 ++targetIndex)
            {
                NSInteger offset = [permutation[targetIndex] integerValue];
                if (offset != 0)
                {
                    NSInteger source = (NSInteger)targetIndex + offset;
                    NSInteger target = (NSInteger)targetIndex;

                    [delegate sectionInfo:self
                            didMoveObject:oldRows[(NSUInteger)source]
                             fromRowIndex:source
                               toRowIndex:target];
                }
            }
        }

        if ([delegate respondsToSelector:@selector(sectionInfo:didInsertObject:atRowIndex:)])
        {
            // Insertions
            [arrayComparer.insertedItemIndexes enumerateIndexesWithOptions:NSEnumerationReverse
                                                                usingBlock:
             ^(NSUInteger idx, BOOL * _Nonnull __unused stop)
             {
                 [delegate sectionInfo:self
                       didInsertObject:self.rows[idx]
                            atRowIndex:(NSInteger)idx];
             }];
        }
        
        if ([delegate respondsToSelector:@selector(sectionInfoDidChangeContent:)])
        {
            [delegate sectionInfoDidChangeContent:self];
        }
    }
}

#pragma mark - Core Data Support

- (NSInteger)rowIndexForController:(NSFetchedResultsController*)controller
                      dataIndexPath:(NSIndexPath*)indexPath
{
    NSParameterAssert(controller == self.rowsSource);
    NSParameterAssert(indexPath.section == 0);

    return indexPath.row;
}

#pragma mark - Fetch Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    NSParameterAssert(controller == self.rowsSource);
    NSAssert([NSThread isMainThread], nil);

    id<AKATableViewSectionDataSourceInfoDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(sectionInfoWillChangeContent:)])
    {
        [delegate sectionInfoWillChangeContent:self];
    }
}

- (void)controller:(NSFetchedResultsController*)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath*)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath*)newIndexPath
{
    NSParameterAssert(controller == self.rowsSource);
    NSAssert([NSThread isMainThread], nil);


    id<AKATableViewSectionDataSourceInfoDelegate> delegate = self.delegate;
    NSInteger oldRowIndex = [self rowIndexForController:controller
                                          dataIndexPath:indexPath];
    NSInteger rowIndex = [self rowIndexForController:controller
                                       dataIndexPath:newIndexPath];

    if (type == NSFetchedResultsChangeInsert)
    {
        if ([delegate respondsToSelector:@selector(sectionInfo:didInsertObject:atRowIndex:)])
        {
            [delegate sectionInfo:self didInsertObject:anObject atRowIndex:rowIndex];
        }
    }
    else if (type == NSFetchedResultsChangeUpdate)
    {
        if ([delegate respondsToSelector:@selector(sectionInfo:didUpdateObject:atRowIndex:)])
        {
            [delegate sectionInfo:self didUpdateObject:anObject atRowIndex:rowIndex];
        }
    }
    else if (type == NSFetchedResultsChangeDelete)
    {
        if ([delegate respondsToSelector:@selector(sectionInfo:didDeleteObject:atRowIndex:)])
        {
            [delegate sectionInfo:self didDeleteObject:anObject atRowIndex:rowIndex];
        }
    }
    else if (type == NSFetchedResultsChangeMove)
    {
        if ([delegate respondsToSelector:@selector(sectionInfo:didMoveObject:fromRowIndex:toRowIndex:)])
        {
            [delegate sectionInfo:self
                    didMoveObject:anObject
                     fromRowIndex:oldRowIndex
                       toRowIndex:rowIndex];
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    NSParameterAssert(controller == self.rowsSource);
    NSAssert([NSThread isMainThread], nil);

    id<AKATableViewSectionDataSourceInfoDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(sectionInfoDidChangeContent:)])
    {
        [delegate sectionInfoDidChangeContent:self];
    }
}

@end
