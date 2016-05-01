//
//  AKABinding_UISegmentedControl_valueBinding.m
//  AKABeacon
//
//  Created by Michael Utech on 20.11.15.
//  Copyright © 2015 Michael Utech & AKA Sarl. All rights reserved.
//

@import AKACommons.NSObject_AKAConcurrencyTools;
#import "AKABinding_UISegmentedControl_valueBinding.h"
#import "AKACollectionControlViewBinding.h"
#import "AKABindingErrors.h"

@interface AKABinding_UISegmentedControl_valueBinding() <AKACollectionControlViewBindingDelegate>

@property(nonatomic, readonly)       UISegmentedControl*                segmentedControl;

@property(nonatomic)                 NSArray*                           choices;
@property(nonatomic, readonly)       AKAUnboundProperty*                titleProperty;
@property(nonatomic, readonly)       AKAUnboundProperty*                imageProperty;
@property(nonatomic)                 NSInteger                          previouslySelectedRow;
@property(nonatomic)                 BOOL                               isObserving;

@end

@implementation AKABinding_UISegmentedControl_valueBinding

+ (AKABindingSpecification *)                   specification
{
    static AKABindingSpecification* result = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary* spec =
        @{ @"bindingType":              [AKABinding_UISegmentedControl_valueBinding class],
           @"targetType":               [UISegmentedControl class],
           };
        result = [[AKABindingSpecification alloc] initWithDictionary:spec basedOn:[super specification]];
    });

    return result;
}

- (void)                                    validateTargetView:(req_UIView)targetView
{
    (void)targetView;
    NSParameterAssert([targetView isKindOfClass:[UISegmentedControl class]]);
}

- (req_AKAProperty)         createBindingTargetPropertyForView:(req_UIView)view
{
    NSParameterAssert(view == nil || [view isKindOfClass:[UISegmentedControl class]]);

    UISegmentedControl* segmentedControl = (UISegmentedControl*)view;
    segmentedControl.selectedSegmentIndex = NSNotFound;
    [segmentedControl removeAllSegments];

    return [AKAProperty propertyOfWeakTarget:self
                                      getter:
            ^id (id target)
            {
                AKABinding_UISegmentedControl_valueBinding* binding = target;

                id result = @(binding.segmentedControl.selectedSegmentIndex);

                return result;
            }
                                      setter:
            ^(id target, id value)
            {
                AKABinding_UISegmentedControl_valueBinding* binding = target;

                NSInteger row = value ? [value integerValue] : NSNotFound;

                if (row != NSNotFound)
                {
                    id currentValue = nil;
                    [binding convertTargetValue:@(binding.segmentedControl.selectedSegmentIndex)
                                  toSourceValue:&currentValue
                                          error:nil];

                    if (currentValue == nil && currentValue != value)
                    {
                        currentValue = [NSNull null];
                    }

                    if (currentValue != value)
                    {
                        // Only update segmented control, if the value associated with
                        // the previously selected segment is different from the
                        // new value (selections, especially if undefined,
                        // may have the same associated values and in these
                        // cases we don't want to change the selection).
                        binding.segmentedControl.selectedSegmentIndex = row;
                        binding.previouslySelectedRow = row;
                    }
                }
            }

                          observationStarter:
            ^BOOL (id target)
            {
                AKABinding_UISegmentedControl_valueBinding* binding = target;

                if (!binding.isObserving)
                {
                    [binding.segmentedControl addTarget:binding
                                                 action:@selector(viewValueDidChange:)
                                       forControlEvents:UIControlEventValueChanged];
                }

                return binding.isObserving;
            }

                          observationStopper:
            ^BOOL (id target)
            {
                AKABinding_UISegmentedControl_valueBinding* binding = target;

                if (binding.isObserving)
                {
                    [binding.segmentedControl removeTarget:binding
                                                    action:@selector(viewValueDidChange:)
                                          forControlEvents:UIControlEventValueChanged];
                }

                return YES;
            }];
}

#pragma mark - Conversion

- (BOOL)convertTargetValue:(id)targetValue
             toSourceValue:(id  _Nullable __autoreleasing *)sourceValueStore
                     error:(NSError *__autoreleasing  _Nullable *)error
{
    BOOL result = YES;
    if (targetValue == nil)
    {
        *sourceValueStore = nil;
    }
    else if ([targetValue isKindOfClass:[NSNumber class]])
    {
        NSInteger index = [targetValue integerValue];
        if (index >= 0 && index < self.choices.count)
        {
            *sourceValueStore = self.choices[(NSUInteger)index];
        }
        else if (index == NSNotFound)
        {
            *sourceValueStore = nil;
        }
        else
        {
            *sourceValueStore = nil;
            [AKABindingErrors bindingErrorConversionOfBinding:self targetValue:targetValue failedWithRangeError:NSMakeRange(0, self.choices.count)];
        }
    }
    else
    {
        result = NO;
        if (error)
        {
            *error = [AKABindingErrors bindingErrorConversionOfBinding:self
                                                           targetValue:targetValue
                                         failedWithInvalidTypeExpected:[NSNumber class]];

        }
    }
    return result;
}

- (BOOL)convertSourceValue:(id)sourceValue
             toTargetValue:(id  _Nullable __autoreleasing *)targetValueStore
                     error:(NSError *__autoreleasing  _Nullable *)error
{
    (void)error;

    BOOL result = YES;
    if (sourceValue == nil)
    {
        *targetValueStore = nil;
    }
    else
    {
        NSUInteger index = [self.choices indexOfObject:sourceValue];

        *targetValueStore = index == NSNotFound ? nil : @((NSInteger)index);
    }
    return result;
}

#pragma mark - Change Tracking

- (BOOL)startObservingChanges
{
    BOOL result = [super startObservingChanges];

    return result;
}

- (BOOL)stopObservingChanges
{
    BOOL result = [super stopObservingChanges];

    return result;
}

- (IBAction)viewValueDidChange:(id)sender
{
    (void)sender;

    NSInteger row = self.segmentedControl.selectedSegmentIndex;

    [self targetValueDidChangeFromOldValue:@(self.previouslySelectedRow)
                                toNewValue:@(row)];

    _previouslySelectedRow = row;
}

- (void)binding:(req_AKABinding)binding didUpdateTargetValue:(id)oldTargetValue to:(id)newTargetValue
{
#if 0
    if (binding == (req_AKABinding)self.attributeBindings[@"choices"])
#else
    if (YES)
#endif
    {
        // TODO: This should be implemented as AKACollectionProperty or AKACollectionBinding or something else which is reusable, review later
        NSArray* items = nil;
        if ([newTargetValue isKindOfClass:[NSSet class]])
        {
            items = [((NSSet*)newTargetValue) allObjects];
        }
        else if ([newTargetValue isKindOfClass:[NSArray class]])
        {
            items = newTargetValue;
        }
        if (items == nil)
        {
            items = @[];
        }

        NSArray* actualItems = nil;
        if ([oldTargetValue isKindOfClass:[NSSet class]])
        {
            actualItems = [((NSSet*)oldTargetValue) allObjects];
        }
        else if ([oldTargetValue isKindOfClass:[NSArray class]])
        {
            actualItems = oldTargetValue;
        }
        if (actualItems == nil)
        {
            actualItems = @[];
        }

        [self binding:binding sourceControllerWillChangeContent:self.bindingSource];

        NSInteger placeholderContentSection = 0;

        // Remove items no longer in new items collection
        NSMutableArray* oldItems = nil;

        if (actualItems.count > 0)
        {
            oldItems = [NSMutableArray arrayWithArray:actualItems];
            for (NSInteger i = (NSInteger)oldItems.count - 1; i >= 0; --i)
            {
                id oldItem = oldItems[(NSUInteger)i];

                if ([items indexOfObject:oldItem] == NSNotFound)
                {
                    [oldItems removeObjectAtIndex:(NSUInteger)i];

                    NSIndexPath* oldItemIndexPath = [NSIndexPath indexPathForRow:i
                                                                       inSection:placeholderContentSection];
                    [self binding:binding sourceController:self.bindingSource
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
                [self binding:binding sourceController:self.bindingSource
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

                [self binding:binding sourceController:self.bindingSource
                    movedItem:item
                fromIndexPath:itemOldIndexPath
                  toIndexPath:itemIndexPath];
                ++insertedItemCount;
            }
            else
            {
                /*
                [self binding:binding sourceController:self.bindingSource
                  updatedItem:items[(NSUInteger)itemIndexPath.row]
                  atIndexPath:itemIndexPath];
                 */
            }
        }
        
        [self binding:binding sourceControllerDidChangeContent:self.bindingSource];
    }
}

- (void)binding:(req_AKACollectionControlViewBinding)binding sourceControllerWillChangeContent:(id)sourceDataController
{
    (void)binding;
    (void)sourceDataController;

    [UIView beginAnimations:nil context:nil];
}

- (void)binding:(req_AKACollectionControlViewBinding)binding sourceController:(id)sourceDataController insertedItem:(id)sourceCollectionItem atIndexPath:(NSIndexPath *)indexPath
{
    (void)binding;
    (void)sourceDataController;

    id context = sourceCollectionItem;

    id image = [self imageForItem:context];
    id title = [self titleForItem:context withDefault:image ? nil : context];

    if ([image isKindOfClass:[UIImage class]] && (![title length] || !self.preferTitleOverImage))
    {
        [self.segmentedControl insertSegmentWithImage:(UIImage*)image
                                              atIndex:(NSUInteger)indexPath.row
                                             animated:YES];
    }
    else
    {
        [self.segmentedControl insertSegmentWithTitle:title
                                              atIndex:(NSUInteger)indexPath.row
                                             animated:YES];
    }
}

- (void)binding:(req_AKACollectionControlViewBinding)binding sourceController:(id)sourceDataController deletedItem:(id)sourceCollectionItem atIndexPath:(NSIndexPath *)indexPath
{
    (void)binding;
    (void)sourceDataController;
    (void)sourceCollectionItem;

    [self.segmentedControl removeSegmentAtIndex:(NSUInteger)indexPath.row animated:YES];
}

- (void)binding:(req_AKACollectionControlViewBinding)binding sourceController:(id)sourceDataController updatedItem:(id)sourceCollectionItem atIndexPath:(NSIndexPath *)indexPath
{
    (void)binding;
    (void)sourceDataController;

    id context = sourceCollectionItem;

    id image = [self imageForItem:context];
    id title = [self titleForItem:context withDefault:image ? nil : context];

    if ([image isKindOfClass:[UIImage class]] && (![title length] || !self.preferTitleOverImage))
    {
        [self.segmentedControl setImage:image forSegmentAtIndex:(NSUInteger)indexPath.row];
    }
    else
    {
        [self.segmentedControl setTitle:title forSegmentAtIndex:(NSUInteger)indexPath.row];
    }
}

- (void)binding:(req_AKACollectionControlViewBinding)binding sourceController:(id)sourceDataController movedItem:(id)sourceCollectionItem fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    (void)binding;
    (void)sourceDataController;

    NSUInteger fromIndex = (NSUInteger)fromIndexPath.row;
    NSUInteger toIndex = (NSUInteger)toIndexPath.row;
    if (toIndex > fromIndex)
    {
        --toIndex;
    }

    id context = sourceCollectionItem;

    id title = [self.titleProperty valueForTarget:context];
    if (title != nil && ![title isKindOfClass:[NSString class]])
    {
        title = [NSString stringWithFormat:@"%@", title];
    }

    id image = [self.imageProperty valueForTarget:context];
    if (image != nil && ![image isKindOfClass:[UIImage class]])
    {
        if ([image isKindOfClass:[NSString class]])
        {
            image = [UIImage imageNamed:(NSString*)image];
        }
        else if ([image isKindOfClass:[NSData class]])
        {
            image = [UIImage imageWithData:(NSData*)image];
        }
        else
        {
            // TODO: something when we can't use the value as image
            image = nil;
        }
    }

    [self.segmentedControl removeSegmentAtIndex:fromIndex animated:YES];
    if ([image isKindOfClass:[UIImage class]] && (![title length] || !self.preferTitleOverImage))
    {
        [self.segmentedControl insertSegmentWithImage:(UIImage*)image
                                              atIndex:toIndex
                                             animated:YES];
    }
    else
    {
        [self.segmentedControl insertSegmentWithTitle:title
                                              atIndex:toIndex
                                             animated:YES];
    }
}

- (void)binding:(req_AKACollectionControlViewBinding)binding sourceControllerDidChangeContent:(id)sourceDataController
{
    (void)binding;
    (void)sourceDataController;

    [UIView commitAnimations];
    [self updateTargetValue];
}

#pragma mark - Properties

- (UISegmentedControl *)                     segmentedControl
{
    UIView* result = self.view;

    NSAssert([result isKindOfClass:[UISegmentedControl class]], @"Internal inconsistency, expected view %@ to be an instance of UISegmentedControl", result);

    return (UISegmentedControl*)result;
}

@synthesize titleProperty = _titleProperty;
- (AKAUnboundProperty*)                         titleProperty
{
    if (_titleProperty == nil && self.titleBindingExpression != nil)
    {
        id<AKABindingContextProtocol> context = self.bindingContext;

        if (context != nil)
        {
            _titleProperty = [self.titleBindingExpression bindingSourceUnboundPropertyInContext:context];
        }
    }

    return _titleProperty;
}

@synthesize imageProperty = _imageProperty;
- (AKAUnboundProperty*)                         imageProperty
{
    if (_imageProperty == nil && self.imageBindingExpression != nil)
    {
        id<AKABindingContextProtocol> context = self.bindingContext;

        if (context != nil)
        {
            _imageProperty = [self.imageBindingExpression bindingSourceUnboundPropertyInContext:context];
        }
    }

    return _imageProperty;
}

#pragma mark - Titles and Images

- (NSString*)titleForItem:(id)item withDefault:(id)defaultValue
{
    id title = [self.titleProperty valueForTarget:item];
    if (title == nil)
    {
        title = defaultValue;
    }
    if (title != nil && ![title isKindOfClass:[NSString class]])
    {
        title = [NSString stringWithFormat:@"%@", title];
    }
    return title;
}

- (UIImage*)imageForItem:(id)item
{
    id image = [self.imageProperty valueForTarget:item];
    if (image != nil && ![image isKindOfClass:[UIImage class]])
    {
        if ([image isKindOfClass:[NSString class]])
        {
            image = [UIImage imageNamed:(NSString*)image];
        }
        else if ([image isKindOfClass:[NSData class]])
        {
            image = [UIImage imageWithData:(NSData*)image];
        }
        else
        {
            // TODO: do something when we can't use the value as image
            image = nil;
        }
    }
    return image;
}

@end
