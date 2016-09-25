//
//  AKAArrayPropertyBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 06.01.16.
//  Copyright © 2016 Michael Utech & AKA Sarl. All rights reserved.
//

@import Foundation;
@import CoreData;

#import "AKAArrayPropertyBinding.h"
#import "AKABinding_Protected.h"
#import "AKABinding+SubclassInitialization.h"
#import "AKABinding+BindingOwner.h"
#import "AKABinding+DelegateSupport.h"
#import "AKABinding+SubclassObservationEvents.h"
#import "AKABinding_BindingOwnerProperties.h"

#import "AKABindingErrors.h"
#import "AKAArrayComparer.h"
#import "AKADelegateDispatcher.h"


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


@interface AKAArrayPropertyBinding() <NSFetchedResultsControllerDelegate>

@property(nonatomic)           BOOL usesDynamicSource;

@property(nonatomic)           BOOL isObservingChanges;

/**
 If usesDynamicSource, this is either an AKAArrayComparer or an NSFetchedResultsController.
 */
@property(nonatomic)           id collectionController;

@end

@implementation AKAArrayPropertyBinding

- (instancetype)init
{
    if (self = [super init])
    {
        self.generateContentChangeEventsForSourceArrayChanges = NO;
    }
    return self;
}

+ (AKABindingSpecification*)                         specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        NSDictionary* spec =
        @{ @"bindingType":                  [AKAArrayPropertyBinding class],
           @"targetType":                   [AKAProperty class],
           @"expressionType":               @((AKABindingExpressionTypeArray |
                                               AKABindingExpressionTypeAnyKeyPath))
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}


- (opt_AKAProperty)bindingSourceForExpression:(req_AKABindingExpression)bindingExpression
                                      context:(req_AKABindingContext)bindingContext
                               changeObserver:(opt_AKAPropertyChangeObserver)changeObserver
                                        error:(out_NSError)error
{
    // The base implementation of AKABinding already handles arrays resulting from array binding expressions
    // (which have a fixed count but array items might change if the array item expressions are not constant).

    // This binding also supports source collections (currently NSArray and NSFetchedResultsController)
    // which are converted to the target array (if necessary) by convertSourceValue:toTargetValue:error:.

    self.usesDynamicSource = (bindingExpression.expressionType != AKABindingExpressionTypeArray);

    return [super bindingSourceForExpression:bindingExpression
                                     context:bindingContext
                              changeObserver:changeObserver
                                       error:error];
}

- (void)setCollectionController:(id)collectionController
{
    if (_collectionController != collectionController)
    {
        if ([_collectionController isKindOfClass:[NSFetchedResultsController class]])
        {
            [self uninstallFetchedResultsControllerDelegate];
        }

        _collectionController = collectionController;

        if ([_collectionController isKindOfClass:[NSFetchedResultsController class]] && self.isObservingChanges)
        {
            [self installFetchedResultsControllerDelegate];
        }
    }
}

- (BOOL)convertSourceValue:(id)sourceValue
             toTargetValue:(id _Nullable __autoreleasing*)targetValueStore
                     error:(NSError* __autoreleasing _Nullable*)error
{
    // Use default implementation for array binding expression source values.
    if (!self.usesDynamicSource)
    {
        return [super convertSourceValue:sourceValue toTargetValue:targetValueStore error:error];
    }

    BOOL result = (sourceValue == nil
                   || [sourceValue isKindOfClass:[NSArray class]]
                   || [sourceValue isKindOfClass:[NSFetchedResultsController class]]);

    NSArray* targetValue = nil;

    if (result)
    {
        if (sourceValue == nil || [sourceValue isKindOfClass:[NSArray class]])
        {
            self.collectionController = nil;

            if (self.generateContentChangeEventsForSourceArrayChanges)
            {
                if (self.syntheticTargetValue == nil)
                {
                    self.syntheticTargetValue = [NSMutableArray new];
                }

                self.collectionController = [[AKAArrayComparer alloc] initWithOldArray:(NSMutableArray*)self.syntheticTargetValue
                                                                              newArray:sourceValue];
                targetValue = self.syntheticTargetValue;
            }
            else
            {
                targetValue = sourceValue;
            }
        }
        else if ([sourceValue isKindOfClass:[NSFetchedResultsController class]])
        {
            self.collectionController = sourceValue;
            targetValue = ((NSFetchedResultsController*)sourceValue).fetchedObjects;
        }

        *targetValueStore = targetValue;
    }
    else
    {
        if (error)
        {
            *error = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                           sourceValue:sourceValue
                                    failedWithInvalidTypeExpectedTypes:@[ [NSArray class],
                                                                          [NSFetchedResultsController class] ]];
        }
    }

    return result;
}

#pragma mark - Delegate Support

- (void)willUpdateTargetValue:(id)oldTargetValue
                           to:(id)newTargetValue
{
    BOOL generateContentChangeEvents = (self.generateContentChangeEventsForSourceArrayChanges &&
                                        [self.collectionController isKindOfClass:[AKAArrayComparer class]]);

    if (generateContentChangeEvents)
    {
        [self propagateBindingDelegateMethod:@selector(binding:collectionControllerWillChangeContent:)
                                  usingBlock:
         ^(id<AKAArrayPropertyBindingDelegate> delegate, outreq_BOOL stop __unused)
         {
             [delegate binding:self collectionControllerWillChangeContent:self.collectionController];
         }];
    }

    [super willUpdateTargetValue:oldTargetValue to:newTargetValue];

    if (generateContentChangeEvents)
    {
        AKAArrayComparer* arrayComparer = self.collectionController;
        NSArray* oldTargetArray = arrayComparer.oldArray;
        NSArray* newTargetArray = arrayComparer.array;

        // Deletions
        [self propagateBindingDelegateMethod:@selector(binding:collectionController:didDeleteObject:atIndex:)
                                  usingBlock:
         ^(id<AKAArrayPropertyBindingDelegate> delegate, outreq_BOOL stop __unused)
         {
             [arrayComparer.deletedItemIndexes enumerateIndexesWithOptions:NSEnumerationReverse
                                                                usingBlock:
              ^(NSUInteger idx, BOOL * _Nonnull __unused localStop)
              {
                  [delegate          binding:self
                        collectionController:arrayComparer
                             didDeleteObject:oldTargetArray[idx]
                                     atIndex:idx];
              }];
         }];

        // Movements
        [self propagateBindingDelegateMethod:@selector(binding:collectionController:didMoveObject:fromIndex:toIndex:)
                                  usingBlock:
         ^(id<AKAArrayPropertyBindingDelegate> delegate, outreq_BOOL stop __unused)
         {
             NSArray* permutation = arrayComparer.movementsForTableViews;
             for (NSUInteger targetIndex=0;
                  targetIndex < permutation.count;
                  ++targetIndex)
             {
                 NSInteger offset = [permutation[targetIndex] integerValue];
                 if (offset != 0)
                 {
                     NSUInteger source = (NSUInteger)((NSInteger)targetIndex + offset);
                     NSUInteger target = targetIndex;

                     [delegate           binding:self
                            collectionController:arrayComparer
                                   didMoveObject:oldTargetArray[source]
                                       fromIndex:source
                                         toIndex:target];
                 }
             }
         }];

        // Insertions
        [self propagateBindingDelegateMethod:@selector(binding:collectionController:didInsertObject:atIndex:)
                                  usingBlock:
         ^(id<AKAArrayPropertyBindingDelegate> delegate, outreq_BOOL stop __unused)
         {
             [arrayComparer.insertedItemIndexes enumerateIndexesWithOptions:NSEnumerationReverse
                                                                 usingBlock:
              ^(NSUInteger idx, BOOL * _Nonnull __unused localStop)
              {
                  [delegate          binding:self
                        collectionController:arrayComparer
                             didInsertObject:newTargetArray[idx]
                                     atIndex:idx];
              }];
         }];

        NSMutableArray* targetArray = self.syntheticTargetValue;
        [targetArray removeAllObjects];
        [targetArray addObjectsFromArray:arrayComparer.array];
    }
}

- (void)didUpdateTargetValue:(id)oldTargetValue
                          to:(id)newTargetValue
              forSourceValue:(id)oldSourceValue
                    changeTo:(id)newSourceValue
{
    [super didUpdateTargetValue:oldTargetValue
                             to:newTargetValue
                 forSourceValue:oldSourceValue
                       changeTo:newSourceValue];

    if (self.generateContentChangeEventsForSourceArrayChanges &&
        [self.collectionController isKindOfClass:[AKAArrayComparer class]])
    {
        [self propagateBindingDelegateMethod:@selector(binding:collectionControllerDidChangeContent:)
                                  usingBlock:
         ^(id<AKAArrayPropertyBindingDelegate> delegate, outreq_BOOL stop __unused)
         {
             [delegate binding:self collectionControllerDidChangeContent:self.collectionController];
         }];

        self.collectionController = nil;
    }
}

#pragma mark - Observation

- (void)willStartObservingChanges
{
    self.isObservingChanges = YES;
}

- (void)didStartObservingBindingSource
{
    if ([self.collectionController isKindOfClass:[NSFetchedResultsController class]])
    {
        [self installFetchedResultsControllerDelegate];
    }
}

- (void)willStopObservingBindingSource
{
    if ([self.collectionController isKindOfClass:[NSFetchedResultsController class]])
    {
        [self uninstallFetchedResultsControllerDelegate];
    }
}

- (void)didStopObservingChanges
{
    self.isObservingChanges = NO;
}

#pragma mark - NSFetchedResultsController Source Value

- (void)installFetchedResultsControllerDelegate
{
    NSAssert([self.collectionController isKindOfClass:[NSFetchedResultsController class]],
             @"installFetchedResultsControllerDelegate can only be used if the source value is an instance of NSFetchedResultsController");

    // TODO: use delegate dispatcher
    NSFetchedResultsController* frc = self.collectionController;
    if (frc.delegate == nil)
    {
        frc.delegate = self;
    }
}

- (void)uninstallFetchedResultsControllerDelegate
{
    NSAssert([self.collectionController isKindOfClass:[NSFetchedResultsController class]],
             @"uninstallFetchedResultsControllerDelegate can only be used if the source value is an instance of NSFetchedResultsController");

    // TODO: use delegate dispatcher
    NSFetchedResultsController* frc = self.collectionController;
    if (frc.delegate == self)
    {
        frc.delegate = nil;
    }
}

#pragma mark - Fetch Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    NSParameterAssert(controller == self.collectionController);
    NSAssert([NSThread isMainThread], nil);

    id<AKAArrayPropertyBindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:collectionControllerWillChangeContent:)])
    {
        [delegate binding:self collectionControllerWillChangeContent:controller];
    }
}

- (void)controller:(NSFetchedResultsController*)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath*)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath*)newIndexPath
{
    NSParameterAssert(controller == self.collectionController);
    NSParameterAssert(indexPath.section == 0);
    NSParameterAssert(newIndexPath.section == 0);
    NSParameterAssert(indexPath.row >= 0);
    NSParameterAssert(newIndexPath.row >= 0);

    NSAssert([NSThread isMainThread], nil);


    id<AKAArrayPropertyBindingDelegate> delegate = self.delegate;
    NSUInteger oldRowIndex = (NSUInteger)indexPath.row;
    NSUInteger rowIndex = (NSUInteger)newIndexPath.row;

    if (type == NSFetchedResultsChangeInsert)
    {
        if ([delegate respondsToSelector:@selector(binding:collectionController:didInsertObject:atIndex:)])
        {
            [delegate binding:self collectionController:controller didInsertObject:anObject atIndex:rowIndex];
        }
    }
    else if (type == NSFetchedResultsChangeUpdate)
    {
        if ([delegate respondsToSelector:@selector(binding:collectionController:didUpdateObject:atIndex:)])
        {
            [delegate binding:self collectionController:controller didUpdateObject:anObject atIndex:rowIndex];
        }
    }
    else if (type == NSFetchedResultsChangeDelete)
    {
        if ([delegate respondsToSelector:@selector(binding:collectionController:didDeleteObject:atIndex:)])
        {
            [delegate binding:self collectionController:controller didDeleteObject:anObject atIndex:rowIndex];
        }
    }
    else if (type == NSFetchedResultsChangeMove)
    {
        if ([delegate respondsToSelector:@selector(binding:collectionController:didMoveObject:fromIndex:toIndex:)])
        {
            [delegate binding:self collectionController:controller didMoveObject:anObject fromIndex:oldRowIndex toIndex:rowIndex];
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    NSParameterAssert(controller == self.collectionController);
    NSAssert([NSThread isMainThread], nil);

    id<AKAArrayPropertyBindingDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(binding:collectionControllerDidChangeContent:)])
    {
        [delegate binding:self collectionControllerDidChangeContent:controller];
    }
}

#pragma mark - NSArray Source Value

- (void)updateMutableTargetArrayAndGenerateChangeNotifications
{
    id<AKAArrayPropertyBindingDelegate> delegate = self.delegate;

}

#pragma mark - Delegate Support

- (void)sourceArrayItemAtIndex:(NSUInteger)index
                         value:(opt_id)oldValue
                   didChangeTo:(opt_id)newValue
{
    if ([self.delegate conformsToProtocol:@protocol(AKAArrayPropertyBindingDelegate)])
    {
        id<AKAArrayPropertyBindingDelegate> delegate = (id)self.delegate;
        if ([delegate respondsToSelector:@selector(binding:sourceArrayItemAtIndex:value:didChangeTo:)])
        {
            [delegate binding:self
       sourceArrayItemAtIndex:index
                        value:oldValue
                  didChangeTo:newValue];
        }
    }
}

@end
